import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/days.dart';
import '../../domain/importance.dart';
import '../app_database.dart';

const _uuid = Uuid();

/// Kontakt aus dem Adressbuch des Geräts (Kanal `mai/contacts`).
class DeviceContact {
  const DeviceContact({
    required this.systemId,
    required this.name,
    required this.phones,
  });

  final String systemId;
  final String name;

  /// Nummern, bevorzugte (Mobil) zuerst.
  final List<String> phones;

  static DeviceContact? fromMap(Map<Object?, Object?> m) {
    final id = m['id'];
    final name = (m['name'] as String?)?.trim();
    if (id is! String || name == null || name.isEmpty) return null;
    final phones = [
      for (final p in (m['phones'] as List<Object?>? ?? const []))
        if (p is String && p.trim().isNotEmpty) p.trim(),
    ];
    return DeviceContact(systemId: id, name: name, phones: phones);
  }
}

/// Ergebnis eines Imports.
class ImportResult {
  const ImportResult({required this.added, required this.updated});

  final int added;
  final int updated;
}

/// Kontakt mit dem, was die Listen anzeigen.
class PersonView {
  const PersonView(this.person, {this.lastContact, this.lastKind});

  final Person person;
  final DateTime? lastContact;
  final EventKind? lastKind;
}

class PeopleRepository {
  PeopleRepository(this.db);

  final AppDatabase db;

  /// Alle aktiven Kontakte (alphabetisch) mit letztem Kontakt.
  Stream<List<PersonView>> watchAll() {
    final people = (db.select(db.people)
          ..where((t) => t.archived.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.name.collate(Collate.noCase))]))
        .watch();
    return people.asyncMap((list) async {
      final last = await lastContacts();
      return [
        for (final p in list)
          PersonView(p, lastContact: last[p.id]?.$1, lastKind: last[p.id]?.$2),
      ];
    });
  }

  Future<List<Person>> active() =>
      (db.select(db.people)..where((t) => t.archived.equals(false))).get();

  Stream<Person?> watch(String id) =>
      (db.select(db.people)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<Person?> byId(String id) =>
      (db.select(db.people)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Noch nicht eingeordnete Kontakte (für „Einordnen“).
  Stream<List<Person>> watchUnrated() =>
      (db.select(db.people)
            ..where((t) => t.archived.equals(false) & t.importance.isNull())
            ..orderBy([(t) => OrderingTerm(expression: t.name.collate(Collate.noCase))]))
          .watch();

  /// Letzter Kontakt je Person (Anruf, Nachricht, eingetragen).
  Future<Map<String, (DateTime, EventKind)>> lastContacts() async {
    final rows = await (db.select(db.contactEvents)
          ..where((t) => t.kind.isNotValue(EventKind.declined.index))
          ..orderBy([(t) => OrderingTerm(expression: t.at)]))
        .get();
    return {for (final e in rows) e.personId: (e.at, e.kind)};
  }

  /// Übernimmt Kontakte aus dem Adressbuch: neue werden angelegt (noch nicht
  /// eingeordnet), bekannte (gleicher Schlüssel) aktualisieren Name und
  /// Nummer. Aus der App entfernte bleiben entfernt.
  Future<ImportResult> import(List<DeviceContact> contacts, {DateTime? now}) {
    final t = now ?? DateTime.now();
    return db.transaction(() async {
      final existing = {
        for (final p in await (db.select(
          db.people,
        )..where((t) => t.systemId.isNotNull())).get())
          p.systemId!: p,
      };
      var added = 0;
      var updated = 0;
      // Doppelte Einträge im Adressbuch nur einmal übernehmen.
      final seen = <String>{};
      for (final c in contacts) {
        if (seen.contains(c.systemId)) continue;
        final phone = c.phones.isEmpty ? null : c.phones.first;
        final known = existing[c.systemId];
        if (known == null) {
          await db
              .into(db.people)
              .insert(
                PeopleCompanion.insert(
                  id: _uuid.v4(),
                  systemId: Value(c.systemId),
                  name: c.name,
                  phone: Value(phone),
                  createdAt: t,
                  updatedAt: t,
                ),
              );
          seen.add(c.systemId);
          added++;
        } else {
          // Eigene Nummer behalten, wenn sie im Adressbuch noch vorkommt.
          final keepPhone = known.phone != null && c.phones.contains(known.phone);
          final newPhone = keepPhone ? known.phone : phone;
          if (known.name != c.name || known.phone != newPhone) {
            await (db.update(db.people)..where((p) => p.id.equals(known.id)))
                .write(
                  PeopleCompanion(
                    name: Value(c.name),
                    phone: Value(newPhone),
                    updatedAt: Value(t),
                  ),
                );
            updated++;
          }
          seen.add(c.systemId);
        }
      }
      return ImportResult(added: added, updated: updated);
    });
  }

  /// Systemschlüssel, die schon in der App sind (auch entfernte).
  Future<Set<String>> knownSystemIds() async => {
    for (final p in await (db.select(
      db.people,
    )..where((t) => t.systemId.isNotNull())).get())
      p.systemId!,
  };

  Future<String> add({
    required String name,
    String? phone,
    Importance? importance,
    DateTime? now,
  }) async {
    final t = now ?? DateTime.now();
    final id = _uuid.v4();
    await db
        .into(db.people)
        .insert(
          PeopleCompanion.insert(
            id: id,
            name: name.trim(),
            phone: Value(_clean(phone)),
            importance: Value(importance),
            createdAt: t,
            updatedAt: t,
          ),
        );
    return id;
  }

  Future<void> update(
    String id, {
    Value<String> name = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<bool> whatsapp = const Value.absent(),
    Value<Importance?> importance = const Value.absent(),
    Value<DateTime?> pausedUntil = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => (db.update(db.people)..where((t) => t.id.equals(id))).write(
    PeopleCompanion(
      name: name,
      phone: phone.present ? Value(_clean(phone.value)) : phone,
      whatsapp: whatsapp,
      importance: importance,
      pausedUntil: pausedUntil,
      note: note,
      updatedAt: Value(DateTime.now()),
    ),
  );

  Future<void> setImportance(String id, Importance? importance) =>
      update(id, importance: Value(importance));

  /// Pausiert für [days] Tage ab heute (`null` hebt die Pause auf).
  Future<void> pause(String id, int? days, {DateTime? now}) => update(
    id,
    pausedUntil: Value(
      days == null ? null : Days.add(Days.of(now ?? DateTime.now()), days),
    ),
  );

  /// Aus der App entfernen (Verlauf bleibt; erneuter Import bringt ihn nicht
  /// zurück).
  Future<void> archive(String id) =>
      (db.update(db.people)..where((t) => t.id.equals(id))).write(
        PeopleCompanion(
          archived: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Zählt eingeordnete (vorschlagbare) Kontakte je Wichtigkeit.
  Stream<Map<Importance?, int>> watchCounts() =>
      (db.select(db.people)..where((t) => t.archived.equals(false)))
          .watch()
          .map((list) {
            final out = <Importance?, int>{};
            for (final p in list) {
              out[p.importance] = (out[p.importance] ?? 0) + 1;
            }
            return out;
          });

  static String? _clean(String? phone) {
    final v = phone?.trim();
    return v == null || v.isEmpty ? null : v;
  }
}
