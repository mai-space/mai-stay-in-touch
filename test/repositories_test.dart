import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mai_stay_in_touch/data/app_database.dart';
import 'package:mai_stay_in_touch/data/repositories/people_repository.dart';
import 'package:mai_stay_in_touch/data/repositories/suggestion_repository.dart';
import 'package:mai_stay_in_touch/data/settings.dart';
import 'package:mai_stay_in_touch/domain/days.dart';
import 'package:mai_stay_in_touch/domain/importance.dart';

import 'helpers.dart';

/// Erfundene Beispielkontakte.
const _book = [
  DeviceContact(systemId: 'k1', name: 'Alex Beispiel', phones: ['0171 1111111']),
  DeviceContact(systemId: 'k2', name: 'Sam Muster', phones: ['+49 172 2222222', '030 123']),
  DeviceContact(systemId: 'k3', name: 'Kim Test', phones: ['0173 3333333']),
];

void main() {
  late AppDatabase db;
  late PeopleRepository people;
  late SuggestionRepository suggestions;
  final now = DateTime(2026, 10, 12, 9); // Montag

  setUp(() {
    db = testDb();
    people = PeopleRepository(db);
    suggestions = SuggestionRepository(db);
  });
  tearDown(() => db.close());

  Future<Map<String, String>> importRated() async {
    await people.import(_book, now: DateTime(2026, 1, 1));
    final all = await people.active();
    for (final p in all) {
      await people.setImportance(p.id, Importance.often);
    }
    return {for (final p in all) p.name: p.id};
  }

  group('Import', () {
    test('legt neu an, gleicht ab und übernimmt Doppelte einmal', () async {
      var r = await people.import([..._book, _book.first], now: now);
      expect((r.added, r.updated), (3, 0));
      final sam = (await people.active()).firstWhere((p) => p.systemId == 'k2');
      expect(sam.phone, '+49 172 2222222');
      expect(sam.importance, isNull);

      // Eigene Wahl der Nummer bleibt, Name wird aktualisiert.
      await people.update(sam.id, phone: const Value('030 123'));
      r = await people.import([
        const DeviceContact(systemId: 'k2', name: 'Sam M.', phones: ['+49 172 2222222', '030 123']),
      ], now: now);
      expect((r.added, r.updated), (0, 1));
      final again = await people.byId(sam.id);
      expect(again!.name, 'Sam M.');
      expect(again.phone, '030 123');
    });

    test('entfernte bleiben beim erneuten Import draußen', () async {
      await people.import(_book, now: now);
      final alex = (await people.active()).firstWhere((p) => p.systemId == 'k1');
      await people.archive(alex.id);
      final r = await people.import(_book, now: now);
      expect(r.added, 0);
      expect((await people.active()).map((p) => p.name), isNot(contains('Alex Beispiel')));
      expect(await people.knownSystemIds(), containsAll(['k1', 'k2', 'k3']));
    });
  });

  group('Vorschläge', () {
    test('ohne eingeordnete Kontakte kein Vorschlag', () async {
      await people.import(_book, now: now);
      final plan = await suggestions.plan(now: now);
      expect(plan.today, isNull);
      expect(plan.upcoming, isEmpty);
      expect(await suggestions.ensureToday(now: now), isNull);
    });

    test('heutiger Vorschlag bleibt stabil und passt zur Vorschau', () async {
      await importRated();
      final before = await suggestions.plan(now: now);
      expect(before.today, isNotNull);
      expect(before.today!.suggestionId, isNull);
      final stored = await suggestions.ensureToday(now: now);
      expect(stored!.personId, before.today!.personId);
      expect((await suggestions.ensureToday(now: now))!.id, stored.id);
      final after = await suggestions.plan(now: now);
      expect(after.today!.suggestionId, stored.id);
      // Vorschau beginnt morgen und nennt heute nicht noch einmal.
      expect(after.upcoming.first.day, Days.add(Days.of(now), 1));
      expect(after.upcoming.first.contactId, isNot(stored.personId));
    });

    test('Anrufen zählt einmal, „Heute nicht“ danach ändert nichts', () async {
      await importRated();
      final s = (await suggestions.ensureToday(now: now))!;
      await suggestions.act(now, s.personId, SuggestionAction.call, now: now);
      await suggestions.act(now, s.personId, SuggestionAction.call, now: now);
      await suggestions.act(now, s.personId, SuggestionAction.later, now: now);
      final events = await db.select(db.contactEvents).get();
      expect(events.map((e) => e.kind), [EventKind.called]);
      expect((await suggestions.current(now))!.status, SuggestionStatus.called);
      final facts = (await suggestions.facts()).firstWhere((f) => f.id == s.personId);
      expect(facts.lastContact, now);
      expect((facts.suggested, facts.accepted), (1, 1));
    });

    test('Reaktion auf einen Tag ohne gespeicherten Vorschlag legt ihn an', () async {
      final ids = await importRated();
      final tomorrow = Days.add(Days.of(now), 1);
      await suggestions.act(tomorrow, ids['Kim Test']!, SuggestionAction.later, now: now);
      final s = await suggestions.current(tomorrow);
      expect(s!.personId, ids['Kim Test']);
      expect(s.status, SuggestionStatus.declined);
      final facts = (await suggestions.facts()).firstWhere((f) => f.id == ids['Kim Test']);
      expect(facts.declinesSinceContact, 1);
    });

    test('„Jemand anderen“ zieht eine andere Person und lehnt die erste ab', () async {
      await importRated();
      final first = (await suggestions.ensureToday(now: now))!;
      final next = await suggestions.another(now: now);
      expect(next, isNotNull);
      expect(next, isNot(first.personId));
      expect((await suggestions.current(now))!.personId, next);
      final plan = await suggestions.plan(now: now);
      expect(plan.today!.personId, next);
      // Alle drei durch → niemand mehr.
      await suggestions.another(now: now);
      expect(await suggestions.another(now: now), isNull);
    });

    test('nur an gewählten Tagen', () async {
      await importRated();
      await Settings(db).set(SettingKeys.suggestionDays, '2,3'); // Di, Mi
      final plan = await suggestions.plan(now: now, days: 7);
      expect(plan.isSuggestionDay, isFalse);
      expect(plan.today, isNull);
      expect(plan.upcoming.map((u) => u.day.weekday).toSet(), {2, 3});
    });

    test('Eintrag löschen öffnet den Vorschlag wieder', () async {
      await importRated();
      final s = (await suggestions.ensureToday(now: now))!;
      await suggestions.act(now, s.personId, SuggestionAction.whatsapp, now: now);
      final event = (await db.select(db.contactEvents).get()).single;
      await suggestions.deleteEvent(event.id);
      expect(await db.select(db.contactEvents).get(), isEmpty);
      expect((await suggestions.current(now))!.status, SuggestionStatus.open);
    });

    test('Salz wird einmal gezogen und bleibt', () async {
      final a = await suggestions.salt();
      expect(await SuggestionRepository(db).salt(), a);
    });

    test('Verlauf mit Namen, neueste zuerst', () async {
      final ids = await importRated();
      await suggestions.note(ids['Alex Beispiel']!, at: DateTime(2026, 10, 1));
      await suggestions.note(ids['Sam Muster']!, at: DateTime(2026, 10, 5));
      final history = await suggestions.watchHistory().first;
      expect(history.map((h) => h.person!.name), ['Sam Muster', 'Alex Beispiel']);
      expect(await suggestions.contactsSince(DateTime(2026, 10, 3)), 1);
      final last = await people.lastContacts();
      expect(last[ids['Sam Muster']]!.$1, DateTime(2026, 10, 5));
    });
  });
}
