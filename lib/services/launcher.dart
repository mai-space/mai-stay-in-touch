import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/phone.dart';

/// Öffnet Wähl-App und WhatsApp (Kanal `mai/launch`). Die App selbst
/// telefoniert nicht und braucht dafür keine Berechtigung: Die Wähl-App
/// öffnet sich mit der Nummer, gewählt wird dort.
class Launcher {
  const Launcher();

  static const _channel = MethodChannel('mai/launch');

  static bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<bool> dial(String number) => _invoke('dial', Phone.dialable(number));

  /// Chat in WhatsApp über `https://wa.me/<nummer>`; `false`, wenn die Nummer
  /// unbrauchbar ist oder nichts den Link öffnen kann.
  Future<bool> whatsapp(String number, String countryCode) async {
    final intl = Phone.international(number, countryCode);
    if (intl == null) return false;
    return _invoke('whatsapp', intl);
  }

  Future<bool> _invoke(String method, String number) async {
    if (!supported || number.isEmpty) return false;
    try {
      return await _channel.invokeMethod<bool>(method, number) ?? false;
    } on PlatformException catch (e) {
      debugPrint('Öffnen fehlgeschlagen: $e');
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
