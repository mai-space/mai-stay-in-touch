/// Kalendertage ohne Uhrzeit — unabhängig von Sommer-/Winterzeit.
abstract final class Days {
  static DateTime of(DateTime t) => DateTime(t.year, t.month, t.day);

  static DateTime add(DateTime day, int days) =>
      DateTime(day.year, day.month, day.day + days);

  /// Ganze Tage von [from] bis [to] (negativ, wenn [to] davor liegt).
  static int between(DateTime from, DateTime to) => DateTime.utc(
    to.year,
    to.month,
    to.day,
  ).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

  /// „2026-10-11“ — Schlüssel für gespeicherte Tagesvorschläge.
  static String key(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static DateTime? parse(String? key) {
    if (key == null) return null;
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(key);
    if (m == null) return null;
    return DateTime(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
    );
  }

  /// Wochentage „1,3,5“ (1 = Montag); leer/ungültig → alle Tage.
  static Set<int> parseWeekdays(String? raw) {
    final out = <int>{};
    for (final part in (raw ?? '').split(',')) {
      final v = int.tryParse(part.trim());
      if (v != null && v >= 1 && v <= 7) out.add(v);
    }
    return out.isEmpty ? allWeekdays : out;
  }

  static String formatWeekdays(Set<int> days) =>
      (days.toList()..sort()).join(',');

  static const allWeekdays = {1, 2, 3, 4, 5, 6, 7};
}
