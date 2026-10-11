import Flutter
import UIKit

/// Kanal „mai/launch“ (Gegenstück zu LauncherChannel.kt): Telefon-App und
/// WhatsApp öffnen. Gewählt wird nach Rückfrage des Systems.
final class LauncherChannel {
  static let name = "mai/launch"

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let number = call.arguments as? String, !number.isEmpty else {
      result(false)
      return
    }
    let url: URL?
    switch call.method {
    case "dial":
      let allowed = CharacterSet(charactersIn: "+0123456789*#")
      url = URL(string: "tel:" + String(number.unicodeScalars.filter { allowed.contains($0) }))
    case "whatsapp":
      // Nur Ziffern (international ohne „+“), siehe lib/domain/phone.dart.
      url = URL(string: "https://wa.me/" + number.filter(\.isNumber))
    default:
      result(FlutterMethodNotImplemented)
      return
    }
    guard let target = url else {
      result(false)
      return
    }
    UIApplication.shared.open(target, options: [:]) { ok in result(ok) }
  }
}
