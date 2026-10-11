import Flutter
import Foundation

/// Kanal „mai/widgets“ (`home_widgets.dart`). Unter iOS gibt es (noch) keine
/// Startbildschirm-Widgets — der Stand geht an die Uhr-App.
final class HomeWidgetChannel {
  static let name = "mai/widgets"

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "update":
      guard let snapshot = call.arguments as? String else {
        result(FlutterError(code: "ARG", message: "Stand fehlt", details: nil))
        return
      }
      WatchSync.shared.update(snapshot: snapshot)
      result(nil)
    case "initialLink":
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
