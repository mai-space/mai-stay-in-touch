import 'app_database.dart';

/// Schlüssel der Einstellungen (Werte als Text, tolerant gelesen).
abstract final class SettingKeys {
  static const onboarded = 'onboarded';

  /// Tägliche Benachrichtigung mit dem Vorschlag.
  static const notificationsEnabled = 'notifications_enabled';

  /// Uhrzeit der Benachrichtigung, Minuten nach Mitternacht.
  static const notificationMinutes = 'notification_minutes';

  /// Tage mit Vorschlag „1,2,3,4,5,6,7“ (1 = Montag); fehlt = alle.
  static const suggestionDays = 'suggestion_days';

  /// Ländervorwahl für nationale Nummern (WhatsApp), z. B. „49“.
  static const countryCode = 'country_code';

  /// Widget und Uhr zeigen nur Initialen statt Namen.
  static const discreet = 'discreet';

  /// Salz der täglichen Auslosung (pro Installation zufällig).
  static const drawSalt = 'draw_salt';
}

/// Lesen/Schreiben der Einstellungen.
class Settings {
  Settings(this.db);

  final AppDatabase db;

  static const defaultNotificationMinutes = 18 * 60;

  Future<String?> get(String key) async {
    final row = await (db.select(
      db.localSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> set(String key, String value) => db
      .into(db.localSettings)
      .insertOnConflictUpdate(LocalSetting(key: key, value: value));

  Stream<String?> watch(String key) =>
      (db.select(db.localSettings)..where((t) => t.key.equals(key)))
          .watchSingleOrNull()
          .map((r) => r?.value);

  Future<bool> flag(String key, {bool fallback = false}) async {
    final v = await get(key);
    return v == null ? fallback : v == '1';
  }

  Future<void> setFlag(String key, bool value) => set(key, value ? '1' : '0');

  Future<int> number(String key, int fallback) async =>
      int.tryParse(await get(key) ?? '') ?? fallback;

  /// Alle Einstellungen auf einmal (für Seiten, die mehrere brauchen).
  Stream<Map<String, String>> watchAll() => db
      .select(db.localSettings)
      .watch()
      .map((rows) => {for (final r in rows) r.key: r.value});
}

extension SettingsMap on Map<String, String> {
  bool flag(String key, {bool fallback = false}) {
    final v = this[key];
    return v == null ? fallback : v == '1';
  }

  int number(String key, int fallback) => int.tryParse(this[key] ?? '') ?? fallback;
}

