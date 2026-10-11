import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mai_stay_in_touch/app/services.dart';
import 'package:mai_stay_in_touch/data/app_database.dart';
import 'package:mai_stay_in_touch/data/settings.dart';
import 'package:mai_stay_in_touch/domain/importance.dart';
import 'package:mai_stay_in_touch/main.dart';

import 'helpers.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Tippt und lässt echte DB-Arbeit laufen (drift arbeitet außerhalb der
/// Fake-Zeit).
Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.runAsync(() async {
    await tester.tap(f);
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  await _settle(tester);
}

/// Echte Zeit für DB-Arbeit, dann Frames.
Future<void> _wait(WidgetTester tester, [int ms = 300]) async {
  await tester.runAsync(() => Future<void>.delayed(Duration(milliseconds: ms)));
  await _settle(tester);
}

/// Wartet (echte Zeit), bis [f] etwas findet.
Future<void> _until(WidgetTester tester, Finder f) async {
  for (var i = 0; i < 20 && f.evaluate().isEmpty; i++) {
    await _wait(tester, 200);
  }
}

void main() {
  testWidgets('Einrichtung → Kontakt anlegen → einordnen → Vorschlag', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final services = AppServices(testDb());
    await tester.pumpWidget(RufDurchApp(services: services));
    await _wait(tester);

    // Einrichtung: drei Schritte.
    expect(find.text('Bleib in Kontakt'), findsOneWidget);
    await _tap(tester, find.text('Weiter'));
    expect(find.text('Kontakte holen'), findsOneWidget);
    await _tap(tester, find.text('Weiter'));
    expect(find.text('Wann passt es dir?'), findsOneWidget);
    await _tap(tester, find.text('Los geht’s'));
    await _wait(tester, 600);
    expect(await services.settings.get(SettingKeys.onboarded), '1');
    expect(find.text('Noch niemand zum Vorschlagen'), findsOneWidget);

    // Kontakte von Hand anlegen (Import braucht das Adressbuch des Geräts).
    await _tap(tester, find.text('Kontakte'));
    await _wait(tester);
    for (final (name, phone) in [
      ('Alex Beispiel', '0171 1111111'),
      ('Sam Muster', '0172 2222222'),
    ]) {
      await _tap(tester, find.text('Kontakt hinzufügen').last);
      await tester.enterText(find.byType(TextFormField).at(0), name);
      await tester.enterText(find.byType(TextFormField).at(1), phone);
      await _tap(tester, find.text('Speichern'));
      await _wait(tester, 600);
      // Kontaktseite: einordnen.
      await _until(tester, find.text('Kontakt eintragen'));
      expect(find.text(name), findsWidgets);
      await _tap(tester, find.text('Sehr wichtig'));
      await _wait(tester);
      await _tap(tester, find.byType(BackButton));
      await _wait(tester);
    }
    final people = await tester.runAsync(services.people.active);
    expect(people!.map((p) => p.importance).toSet(), {Importance.veryOften});

    // Heute: Vorschlag mit Aktionen.
    await _tap(tester, find.text('Heute').last);
    await _wait(tester, 600);
    expect(find.text('Heute melden bei'), findsOneWidget);
    expect(find.text('Anrufen'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Demnächst'), findsOneWidget);

    await _tap(tester, find.text('Heute nicht'));
    await _wait(tester, 600);
    expect(find.textContaining('morgen gibt es einen neuen Vorschlag'), findsOneWidget);

    // Verlauf zeigt die Ablehnung.
    await _tap(tester, find.text('Verlauf'));
    await _wait(tester, 600);
    expect(find.text('Heute nicht'), findsWidgets);
    final events = await tester.runAsync(
      () => services.db.select(services.db.contactEvents).get(),
    );
    expect(events!.single.kind, EventKind.declined);

    await tester.runAsync(services.dispose);
  });
}
