import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/repositories/people_repository.dart';

/// Ergebnis der Kontakte-Berechtigung.
enum ContactsPermission { granted, denied, permanentlyDenied, unsupported }

/// Adressbuch des Geräts (Kanal `mai/contacts`). Gelesen wird nur auf
/// Wunsch des Nutzers (Import); übernommen werden Name und Nummern, sonst
/// nichts. Die App schreibt nie ins Adressbuch.
class DeviceContacts {
  const DeviceContacts();

  static const _channel = MethodChannel('mai/contacts');

  static bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<ContactsPermission> requestPermission() async {
    if (!supported) return ContactsPermission.unsupported;
    try {
      final result = await _channel.invokeMethod<String>('requestPermission');
      return switch (result) {
        'granted' => ContactsPermission.granted,
        'permanentlyDenied' => ContactsPermission.permanentlyDenied,
        _ => ContactsPermission.denied,
      };
    } on MissingPluginException {
      return ContactsPermission.unsupported;
    } on PlatformException {
      return ContactsPermission.denied;
    }
  }

  /// Kontakte mit mindestens einer Telefonnummer, alphabetisch.
  Future<List<DeviceContact>> load() async {
    final raw = await _channel.invokeMethod<List<Object?>>('list') ?? const [];
    final out = <DeviceContact>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final c = DeviceContact.fromMap(item);
      if (c != null && c.phones.isNotEmpty) out.add(c);
    }
    out.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return out;
  }

  /// Öffnet die App-Einstellungen (Berechtigung dauerhaft verweigert).
  Future<void> openSettings() async {
    try {
      await _channel.invokeMethod<void>('openSettings');
    } on PlatformException {
      // Nichts zu tun.
    } on MissingPluginException {
      // Nichts zu tun.
    }
  }
}
