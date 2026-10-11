import Flutter
import UIKit

/// Registriert die eigenen Methodenkanäle — gleiche Namen, Methoden,
/// Argumente und Fehlercodes wie unter Android (MainActivity.kt), damit der
/// Dart-Code plattformunabhängig bleibt.
final class MaiChannels {
  private let device = DeviceChannel()
  private let databaseKey = DatabaseKeyChannel()
  private let contacts = ContactsChannel()
  private let launcher = LauncherChannel()
  private let homeWidgets = HomeWidgetChannel()
  private var methodChannels: [FlutterMethodChannel] = []

  init(registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    bind(DeviceChannel.name, messenger) { [device] call, result in
      device.handle(call, result: result)
    }
    bind(DatabaseKeyChannel.name, messenger) { [databaseKey] call, result in
      databaseKey.handle(call, result: result)
    }
    bind(ContactsChannel.name, messenger) { [contacts] call, result in
      contacts.handle(call, result: result)
    }
    bind(LauncherChannel.name, messenger) { [launcher] call, result in
      launcher.handle(call, result: result)
    }
    bind(HomeWidgetChannel.name, messenger) { [homeWidgets] call, result in
      homeWidgets.handle(call, result: result)
    }
  }

  private func bind(
    _ name: String,
    _ messenger: FlutterBinaryMessenger,
    _ handler: @escaping FlutterMethodCallHandler
  ) {
    let channel = FlutterMethodChannel(name: name, binaryMessenger: messenger)
    channel.setMethodCallHandler(handler)
    methodChannels.append(channel)
  }
}
