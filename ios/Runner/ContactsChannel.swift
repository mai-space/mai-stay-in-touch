import Contacts
import Flutter
import UIKit

/// Kanal „mai/contacts“ (Gegenstück zu ContactsChannel.kt). Gelesen werden
/// nur Name und Telefonnummern, und nur auf Wunsch (Import). Die App
/// schreibt nie ins Adressbuch.
final class ContactsChannel {
  static let name = "mai/contacts"

  private let store = CNContactStore()
  private let queue = DispatchQueue(label: "space.mai.contacts", qos: .userInitiated)

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "requestPermission":
      requestPermission(result)
    case "list":
      list(result)
    case "openSettings":
      if let url = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func requestPermission(_ result: @escaping FlutterResult) {
    switch CNContactStore.authorizationStatus(for: .contacts) {
    case .authorized:
      result("granted")
    case .denied, .restricted:
      result("permanentlyDenied")
    case .notDetermined:
      store.requestAccess(for: .contacts) { granted, _ in
        DispatchQueue.main.async { result(granted ? "granted" : "denied") }
      }
    default:
      // iOS 18: „eingeschränkt“ (nur ausgewählte Kontakte) — reicht zum Import.
      result("granted")
    }
  }

  private func list(_ result: @escaping FlutterResult) {
    queue.async {
      let keys: [CNKeyDescriptor] = [
        CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
        CNContactPhoneNumbersKey as CNKeyDescriptor,
      ]
      let request = CNContactFetchRequest(keysToFetch: keys)
      var out: [[String: Any]] = []
      do {
        try self.store.enumerateContacts(with: request) { contact, _ in
          let name = (CNContactFormatter.string(from: contact, style: .fullName) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
          // Mobilnummern zuerst.
          let phones = contact.phoneNumbers
            .sorted { ContactsChannel.rank($0.label) < ContactsChannel.rank($1.label) }
            .map { $0.value.stringValue.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
          if name.isEmpty || phones.isEmpty { return }
          out.append(["id": contact.identifier, "name": name, "phones": phones])
        }
        DispatchQueue.main.async { result(out) }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "READ", message: error.localizedDescription, details: nil))
        }
      }
    }
  }

  private static func rank(_ label: String?) -> Int {
    switch label {
    case CNLabelPhoneNumberMain: return 0
    case CNLabelPhoneNumberMobile, CNLabelPhoneNumberiPhone: return 1
    default: return 2
    }
  }
}
