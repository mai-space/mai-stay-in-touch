import 'package:drift/drift.dart';
import 'package:intl/intl.dart';

import '../data/app_database.dart';
import '../domain/importance.dart';

/// Tabellen zum Weitergeben (z. B. Excel): Kontakte mit Einordnung und der
/// Verlauf. Trennzeichen „;“ (deutsches Excel), Texte in Anführungszeichen.
abstract final class CsvExport {
  static String people(
    List<Person> people, {
    required List<String> header,
    required String Function(Importance?) importanceLabel,
    required Map<String, DateTime> lastContact,
  }) {
    final date = DateFormat('yyyy-MM-dd');
    final rows = <List<String>>[header];
    for (final p in people) {
      final last = lastContact[p.id];
      rows.add([
        p.name,
        p.phone ?? '',
        importanceLabel(p.importance),
        last == null ? '' : date.format(last),
        p.pausedUntil == null ? '' : date.format(p.pausedUntil!),
        p.note ?? '',
      ]);
    }
    return encode(rows);
  }

  static Future<String> history(
    AppDatabase db, {
    required List<String> header,
    required String Function(EventKind) kindLabel,
  }) async {
    final people = {
      for (final p in await db.select(db.people).get()) p.id: p.name,
    };
    final events = await (db.select(
      db.contactEvents,
    )..orderBy([(t) => OrderingTerm(expression: t.at)])).get();
    final date = DateFormat('yyyy-MM-dd HH:mm');
    return encode([
      header,
      for (final e in events)
        [date.format(e.at), people[e.personId] ?? '', kindLabel(e.kind)],
    ]);
  }

  static String encode(List<List<String>> rows) => rows
      .map((r) => r.map(_cell).join(';'))
      .join('\r\n');

  static String _cell(String v) {
    // Formel-Einschleusung in Tabellenprogrammen verhindern.
    final safe = RegExp(r'^[=+\-@\t\r]').hasMatch(v) && !RegExp(r'^\+?[0-9 ()/-]+$').hasMatch(v)
        ? "'$v"
        : v;
    return '"${safe.replaceAll('"', '""')}"';
  }
}
