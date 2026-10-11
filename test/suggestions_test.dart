import 'package:flutter_test/flutter_test.dart';
import 'package:mai_stay_in_touch/domain/days.dart';
import 'package:mai_stay_in_touch/domain/importance.dart';
import 'package:mai_stay_in_touch/domain/suggestions.dart';

final _created = DateTime(2026, 1, 1);
final _day = DateTime(2026, 10, 12);

ContactFacts _c(
  String id,
  Importance? importance, {
  int? daysSinceContact,
  int? daysSinceSuggested,
  int declines = 0,
  int suggested = 0,
  int accepted = 0,
  DateTime? pausedUntil,
}) => ContactFacts(
  id: id,
  importance: importance,
  createdAt: _created,
  lastContact: daysSinceContact == null
      ? null
      : Days.add(_day, -daysSinceContact),
  lastSuggested: daysSinceSuggested == null
      ? null
      : Days.add(_day, -daysSinceSuggested),
  declinesSinceContact: declines,
  suggested: suggested,
  accepted: accepted,
  pausedUntil: pausedUntil,
);

void main() {
  group('Gewicht', () {
    test('nicht eingeordnet und „nie“ werden nicht vorgeschlagen', () {
      expect(Suggestions.weight(_c('a', null), _day), 0);
      expect(Suggestions.weight(_c('a', Importance.never), _day), 0);
    });

    test('pausiert bis einschließlich Enddatum', () {
      final paused = _c('a', Importance.often, pausedUntil: _day);
      expect(Suggestions.weight(paused, _day), 0);
      expect(Suggestions.weight(paused, Days.add(_day, 1)), greaterThan(0));
    });

    test('Abklingzeit nach einem Vorschlag', () {
      expect(
        Suggestions.weight(_c('a', Importance.often, daysSinceSuggested: 2), _day),
        0,
      );
      expect(
        Suggestions.weight(_c('a', Importance.often, daysSinceSuggested: 3), _day),
        greaterThan(0),
      );
      // Auch gelockert nie zweimal am selben Tag.
      expect(
        Suggestions.weight(
          _c('a', Importance.often, daysSinceSuggested: 0),
          _day,
          relaxed: true,
        ),
        0,
      );
    });

    test('gerade erst gesprochen → erst einmal nicht', () {
      // Oft (14 Tage): unter 4 Tagen nicht.
      expect(
        Suggestions.weight(_c('a', Importance.often, daysSinceContact: 3), _day),
        0,
      );
      expect(
        Suggestions.weight(_c('a', Importance.often, daysSinceContact: 4), _day),
        greaterThan(0),
      );
    });

    test('überfälliger wiegt mehr, wichtiger wiegt mehr', () {
      final due = Suggestions.weight(
        _c('a', Importance.often, daysSinceContact: 28),
        _day,
      );
      final fresh = Suggestions.weight(
        _c('a', Importance.often, daysSinceContact: 7),
        _day,
      );
      expect(due, greaterThan(fresh * 4));
      final veryOften = Suggestions.weight(
        _c('a', Importance.veryOften, daysSinceContact: 7),
        _day,
      );
      final rarely = Suggestions.weight(
        _c('a', Importance.rarely, daysSinceContact: 7),
        _day,
      );
      expect(veryOften, greaterThan(rarely * 10));
    });

    test('„Heute nicht“ dämpft, mit Untergrenze', () {
      double w(int declines) => Suggestions.weight(
        _c('a', Importance.often, daysSinceContact: 20, declines: declines),
        _day,
      );
      expect(w(1), closeTo(w(0) * 0.6, 1e-9));
      expect(w(2), lessThan(w(1)));
      expect(w(10), closeTo(w(0) * Suggestions.minDeclineFactor, 1e-9));
    });

    test('wer Vorschläge oft annimmt, kommt eher dran', () {
      final taker = Suggestions.weight(
        _c('a', Importance.often, daysSinceContact: 20, suggested: 10, accepted: 10),
        _day,
      );
      final decliner = Suggestions.weight(
        _c('a', Importance.often, daysSinceContact: 20, suggested: 10, accepted: 0),
        _day,
      );
      expect(taker, greaterThan(decliner * 1.8));
    });
  });

  group('Auslosung', () {
    final pool = [
      _c('anna', Importance.veryOften, daysSinceContact: 10),
      _c('ben', Importance.often),
      _c('cem', Importance.sometimes, daysSinceContact: 40),
      _c('dora', Importance.rarely, daysSinceContact: 200),
    ];

    test('gleicher Tag und Stand → gleicher Vorschlag', () {
      final a = Suggestions.draw(pool, _day, salt: 7);
      final b = Suggestions.draw(pool.reversed, _day, salt: 7);
      expect(a, isNotNull);
      expect(a, b);
    });

    test('niemand vorschlagbar → null', () {
      expect(Suggestions.draw([_c('a', null)], _day), isNull);
      expect(Suggestions.draw(const [], _day), isNull);
    });

    test('ausgeschlossene werden nicht gezogen', () {
      for (var i = 0; i < 30; i++) {
        final day = Days.add(_day, i);
        final id = Suggestions.draw(pool, day, exclude: {'anna', 'ben', 'cem'});
        expect(id, 'dora');
      }
    });

    test('niemand fällig → kein Vorschlag, gelockert doch', () {
      final only = [_c('a', Importance.often, daysSinceSuggested: 1)];
      expect(Suggestions.draw(only, _day), isNull);
      expect(Suggestions.draw(only, _day, relaxed: true), 'a');
    });

    test('Häufigkeit folgt der Wichtigkeit (Vorschau über ein Jahr)', () {
      final people = [
        for (var i = 0; i < 2; i++) _c('sehr$i', Importance.veryOften),
        for (var i = 0; i < 4; i++) _c('oft$i', Importance.often),
        for (var i = 0; i < 8; i++) _c('mal$i', Importance.sometimes),
        for (var i = 0; i < 10; i++) _c('selten$i', Importance.rarely),
        _c('nie', Importance.never),
        _c('offen', null),
      ];
      final picks = Suggestions.forecast(
        contacts: people,
        from: _day,
        days: 364,
        salt: 42,
      );
      expect(picks, hasLength(364));
      final count = <String, int>{};
      for (final p in picks) {
        final group = p.contactId.replaceAll(RegExp(r'\d'), '');
        count[group] = (count[group] ?? 0) + 1;
      }
      double perPerson(String g, int n) => (count[g] ?? 0) / n;
      expect(count['nie'], isNull);
      expect(count['offen'], isNull);
      expect(perPerson('sehr', 2), greaterThan(perPerson('oft', 4)));
      expect(perPerson('oft', 4), greaterThan(perPerson('mal', 8)));
      expect(perPerson('mal', 8), greaterThan(perPerson('selten', 10)));
      // Jeder kommt im Jahr mindestens einmal dran.
      for (final p in people.where((p) => p.importance != null && p.importance != Importance.never)) {
        expect(picks.any((x) => x.contactId == p.id), isTrue, reason: p.id);
      }
    });

    test('Vorschau: keine Wiederholung innerhalb der Abklingzeit', () {
      final picks = Suggestions.forecast(contacts: pool, from: _day, days: 60);
      expect(picks.length, greaterThan(20));
      final last = <String, DateTime>{};
      for (final p in picks) {
        final prev = last[p.contactId];
        if (prev != null) {
          expect(
            Days.between(prev, p.day),
            greaterThanOrEqualTo(Suggestions.cooldownDays),
          );
        }
        last[p.contactId] = p.day;
      }
    });

    test('Vorschau: nur gewählte Wochentage, feste Tage bleiben', () {
      final picks = Suggestions.forecast(
        contacts: pool,
        from: _day, // Montag
        days: 14,
        weekdays: {1, 4},
        fixed: {Days.key(_day): 'dora'},
      );
      expect(picks.first, DayPick(_day, 'dora'));
      expect(picks.every((p) => p.day.weekday == 1 || p.day.weekday == 4), isTrue);
      expect(picks, hasLength(4));
    });
  });

  group('Tage', () {
    test('über die Zeitumstellung hinweg', () {
      expect(Days.between(DateTime(2026, 10, 24), DateTime(2026, 10, 26)), 2);
      expect(Days.between(DateTime(2026, 3, 28), DateTime(2026, 3, 30)), 2);
    });

    test('Schlüssel und Wochentage', () {
      expect(Days.key(DateTime(2026, 1, 5)), '2026-01-05');
      expect(Days.parse('2026-01-05'), DateTime(2026, 1, 5));
      expect(Days.parse('kaputt'), isNull);
      expect(Days.parseWeekdays(null), Days.allWeekdays);
      expect(Days.parseWeekdays('1, 3,9,x'), {1, 3});
      expect(Days.formatWeekdays({5, 1}), '1,5');
    });
  });
}
