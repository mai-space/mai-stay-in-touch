import Flutter
import Foundation
import Security

/// Schlüssel der verschlüsselten Datenbank (Gegenstück zu DatabaseKeyChannel.kt).
///
/// Ein zufälliger 256-Bit-Schlüssel liegt im Schlüsselbund mit
/// `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`: nie in iCloud-/
/// Finder-Backups, nie auf einem anderen Gerät. Ohne ihn ist die Datenbank
/// nicht lesbar. Gleiches Format wie Android: 64 Hex-Zeichen (Kleinbuchstaben).
final class DatabaseKeyChannel {
  static let name = "mai/db_key"

  /// Schlüssel endgültig verloren — Datenbank ist nicht mehr lesbar.
  static let keyLost = "KEY_LOST"

  /// Vorübergehender Fehler (z. B. Gerät seit dem Neustart noch nicht
  /// entsperrt) — nichts verwerfen.
  static let keyUnavailable = "KEY_UNAVAILABLE"

  private static let service = "space.mai.maiStayInTouch.database"
  private static let account = "db.key"
  private static let keyLength = 32

  private enum KeyError: Error {
    case lost(String)
    case unavailable(String)
  }

  /// Seriell: kein doppeltes Anlegen bei gleichzeitigen Aufrufen.
  private let queue = DispatchQueue(label: "space.mai.db_key")

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getOrCreate":
      run(result) { try Self.getOrCreate() }
    // Nur wenn die Datenbank ohnehin unlesbar ist. Der alte Eintrag wird
    // nicht gelöscht, sondern unter neuem Namen beiseitegelegt.
    case "reset":
      run(result) {
        try Self.reset()
        return nil
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func run(_ result: @escaping FlutterResult, _ task: @escaping () throws -> Any?) {
    queue.async {
      let value: Any?
      do {
        value = try task()
      } catch KeyError.lost(let message) {
        value = FlutterError(code: Self.keyLost, message: message, details: nil)
      } catch KeyError.unavailable(let message) {
        value = FlutterError(code: Self.keyUnavailable, message: message, details: nil)
      } catch {
        value = FlutterError(
          code: Self.keyUnavailable, message: error.localizedDescription, details: nil)
      }
      DispatchQueue.main.async { result(value) }
    }
  }

  private static func baseQuery() -> [String: Any] {
    return [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
    ]
  }

  private static func getOrCreate() throws -> String {
    if let stored = try read() {
      // Andere Länge = beschädigter Eintrag, nicht rekonstruierbar.
      guard stored.count == keyLength else {
        throw KeyError.lost("Schlüssel beschädigt (\(stored.count) Bytes)")
      }
      return hex(stored)
    }
    var key = Data(count: keyLength)
    let random = key.withUnsafeMutableBytes { buffer -> OSStatus in
      guard let base = buffer.baseAddress else { return errSecAllocate }
      return SecRandomCopyBytes(kSecRandomDefault, keyLength, base)
    }
    guard random == errSecSuccess else {
      throw KeyError.unavailable("Zufallszahlen nicht verfügbar (OSStatus \(random))")
    }
    var attributes = baseQuery()
    attributes[kSecValueData as String] = key
    attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    let status = SecItemAdd(attributes as CFDictionary, nil)
    switch status {
    case errSecSuccess:
      return hex(key)
    case errSecDuplicateItem:
      // Zwischenzeitlich angelegt: den gespeicherten verwenden.
      guard let stored = try read(), stored.count == keyLength else {
        throw KeyError.unavailable("Schlüssel nicht lesbar")
      }
      return hex(stored)
    default:
      throw KeyError.unavailable("Schlüssel nicht gespeichert (OSStatus \(status))")
    }
  }

  /// `nil` nur, wenn es keinen Eintrag gibt. Jeder andere Fehler (z. B.
  /// `errSecInteractionNotAllowed` vor dem ersten Entsperren) ist vorübergehend.
  private static func read() throws -> Data? {
    var query = baseQuery()
    query[kSecReturnData as String] = true
    query[kSecMatchLimit as String] = kSecMatchLimitOne
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    switch status {
    case errSecSuccess:
      guard let data = item as? Data else {
        throw KeyError.unavailable("Schlüsselbund lieferte keine Daten")
      }
      return data
    case errSecItemNotFound:
      return nil
    default:
      throw KeyError.unavailable("Schlüsselbund nicht lesbar (OSStatus \(status))")
    }
  }

  private static func reset() throws {
    let stamp = Int64(Date().timeIntervalSince1970 * 1000)
    let update: [String: Any] = [kSecAttrAccount as String: "\(account).\(stamp).bak"]
    let status = SecItemUpdate(baseQuery() as CFDictionary, update as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw KeyError.unavailable("Schlüssel nicht gesichert (OSStatus \(status))")
    }
  }

  private static func hex(_ data: Data) -> String {
    return data.map { String(format: "%02x", $0) }.joined()
  }
}
