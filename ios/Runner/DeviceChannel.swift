import Flutter
import Foundation

/// Kanal „mai/device“ (Gegenstück zu MainActivity.kt).
final class DeviceChannel {
  static let name = "mai/device"

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    // IANA-Zeitzone des Geräts (z. B. „Europe/Berlin“).
    case "timeZone":
      result(TimeZone.current.identifier)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
