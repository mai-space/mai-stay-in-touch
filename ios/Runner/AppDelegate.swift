import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Eigene Kanäle (Gegenstück zu MainActivity.kt) — müssen so lange leben
  /// wie die Engine.
  private var channels: MaiChannels?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // flutter_local_notifications: Benachrichtigungen auch im Vordergrund
    // zeigen und Antippen an Dart weiterreichen.
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    AppDelegate.excludeDataFromBackup()
    // Uhr-App: Sitzung früh aktivieren, damit der Stand die Uhr erreicht.
    WatchSync.shared.activate()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Kontakte und Verlauf nie in iCloud-/Finder-Backups — wie unter Android
  /// (`allowBackup="false"`). Der Datenbankschlüssel verlässt das Gerät ohnehin
  /// nicht; Umzug nur über die verschlüsselte .mairuf-Sicherung.
  private static func excludeDataFromBackup() {
    let manager = FileManager.default
    let directories: [FileManager.SearchPathDirectory] = [
      .documentDirectory, .applicationSupportDirectory,
    ]
    for directory in directories {
      guard
        var url = try? manager.url(
          for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
      else { continue }
      var values = URLResourceValues()
      values.isExcludedFromBackup = true
      try? url.setResourceValues(values)
    }
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "MaiStayInTouchChannels") {
      channels = MaiChannels(registrar: registrar)
    }
  }
}
