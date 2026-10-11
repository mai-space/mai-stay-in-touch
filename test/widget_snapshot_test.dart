import 'dart:convert';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mai_stay_in_touch/data/repositories/people_repository.dart';
import 'package:mai_stay_in_touch/data/repositories/suggestion_repository.dart';
import 'package:mai_stay_in_touch/data/settings.dart';
import 'package:mai_stay_in_touch/domain/importance.dart';
import 'package:mai_stay_in_touch/home_widgets/home_widgets.dart';
import 'package:mai_stay_in_touch/home_widgets/widget_snapshot.dart';
import 'package:mai_stay_in_touch/l10n/l10n.dart';

import 'helpers.dart';

void main() {
  final de = lookupAppLocalizations(const Locale('de'));
  final en = lookupAppLocalizations(const Locale('en'));
  final now = DateTime(2026, 10, 12, 9);

  test('ohne Kontakte: leerer, aber gültiger Stand', () async {
    final db = testDb();
    addTearDown(db.close);
    final snap = await WidgetSnapshot.build(db, de, now: now);
    expect(snap['v'], 1);
    expect(snap['today'], isNull);
    expect(snap['upcoming'], isEmpty);
    expect((snap['labels'] as Map)['title'], 'Heute anrufen');
    expect(((snap['labels'] as Map)['weekdays'] as List), hasLength(7));
    expect(jsonDecode(jsonEncode(snap)), isA<Map>());
  });

  test('Vorschlag und Vorschau; diskret nur Initialen', () async {
    final db = testDb();
    addTearDown(db.close);
    final people = PeopleRepository(db);
    for (final name in ['Alex Beispiel', 'Sam Muster', 'Kim Test', 'Robin Probe']) {
      await people.add(name: name, phone: '0171 1234567', importance: Importance.often);
    }
    await SuggestionRepository(db).ensureToday(now: now);
    var snap = await WidgetSnapshot.build(db, en, now: now);
    final today = snap['today'] as Map;
    expect(today['day'], '2026-10-12');
    expect(today['status'], 'open');
    expect(today['phone'], isTrue);
    expect(today['detail'], 'No contact logged yet');
    expect((snap['upcoming'] as List), isNotEmpty);
    expect((snap['labels'] as Map)['call'], 'Call');

    await Settings(db).setFlag(SettingKeys.discreet, true);
    snap = await WidgetSnapshot.build(db, de, now: now);
    final text = jsonEncode(snap);
    for (final name in ['Alex', 'Sam', 'Kim', 'Robin']) {
      expect(text, isNot(contains(name)));
    }
    expect((snap['today'] as Map)['name'], hasLength(2));
  });

  test('Widget-Links', () {
    final call = WidgetLink.parse('mairuf-widget://call?d=2026-10-12&c=p1')!;
    expect(call.action, SuggestionAction.call);
    expect(call.day, DateTime(2026, 10, 12));
    expect(call.personId, 'p1');
    expect(WidgetLink.parse('mairuf-widget://open')!.action, isNull);
    expect(WidgetLink.parse('mairuf-widget://call')!.action, isNull);
    expect(WidgetLink.parse('https://example.com'), isNull);
    expect(WidgetLink.parse(null), isNull);
  });
}
