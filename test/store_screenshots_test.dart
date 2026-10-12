// Erzeugt die Bildschirmfotos für den Play Store (store/android/…).
//
//   STORE_SCREENSHOTS=1 flutter test test/store_screenshots_test.dart
//
// Rendert die echten Seiten der App mit frei erfundenen Beispielkontakten
// in einer In-Memory-Datenbank (Roboto und Material-Symbole aus dem
// Flutter-SDK). Ohne STORE_SCREENSHOTS wird der Test übersprungen — in der
// CI läuft er also nicht mit.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mai_stay_in_touch/app/services.dart';
import 'package:mai_stay_in_touch/data/app_database.dart';
import 'package:mai_stay_in_touch/data/settings.dart';
import 'package:mai_stay_in_touch/domain/days.dart';
import 'package:mai_stay_in_touch/domain/importance.dart';
import 'package:mai_stay_in_touch/l10n/l10n.dart';
import 'package:mai_stay_in_touch/main.dart';

import 'helpers.dart';

final _enabled = Platform.environment['STORE_SCREENSHOTS'] != null;

/// 1080 × 1920 Pixel (9:16), wie ein übliches Telefon.
const _physical = Size(1080, 1920);
const _ratio = 2.625;

Future<void> _loadFonts() async {
  // flutter_tester liegt in <sdk>/bin/cache/artifacts/engine/<os>/.
  final root = Platform.environment['FLUTTER_ROOT'];
  final fonts = Directory(
    root != null
        ? '$root/bin/cache/artifacts/material_fonts'
        : '${File(Platform.resolvedExecutable).parent.parent.parent.path}/material_fonts',
  );
  final roboto = FontLoader('Roboto');
  for (final f in fonts.listSync().whereType<File>()) {
    final name = f.uri.pathSegments.last;
    if (name.startsWith('Roboto-') && name.endsWith('.ttf')) {
      roboto.addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
    }
  }
  await roboto.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(
      Future.value(
        ByteData.sublistView(
          File('${fonts.path}/MaterialIcons-Regular.otf').readAsBytesSync(),
        ),
      ),
    );
  await icons.load();
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Echte Zeit für DB-Arbeit, dann Frames.
Future<void> _wait(WidgetTester tester, [int ms = 400]) async {
  await tester.runAsync(() => Future<void>.delayed(Duration(milliseconds: ms)));
  await _settle(tester);
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.runAsync(() async {
    await tester.tap(f);
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  await _settle(tester);
  await _wait(tester);
}

Future<void> _shoot(WidgetTester tester, GlobalKey key, String path) async {
  await _wait(tester);
  final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: _ratio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(path)..createSync(recursive: true);
    file.writeAsBytesSync(data!.buffer.asUint8List());
  });
}

/// Frei erfundene Beispielkontakte (keine echten Personen oder Nummern).
const _people = [
  ('Alex Beispiel', '0151 2345678', Importance.veryOften, 3, EventKind.called),
  ('Oma Hilde', '06221 123456', Importance.veryOften, 9, EventKind.called),
  ('Sam Muster', '0160 9876543', Importance.often, 16, EventKind.messaged),
  ('Kim Lorenz', '0176 5554433', Importance.often, 6, EventKind.messaged),
  ('Robin Probe', '0152 1112223', Importance.sometimes, 41, EventKind.noted),
  ('Jona Weber', '0157 3332221', Importance.sometimes, 12, EventKind.called),
  ('Mia Sommer', '0171 4445556', Importance.rarely, 75, EventKind.called),
  ('Lea Brandt', '0162 7778889', Importance.sometimes, 27, EventKind.messaged),
  ('Noah Kaiser', '0170 6665554', Importance.rarely, 120, EventKind.noted),
];

/// Noch nicht eingeordnet (für „Einordnen“).
const _unrated = [
  ('Charlie Neumann', '0173 2223334'),
  ('Toni Wagner', '0159 8887776'),
  ('Elif Yilmaz', '0177 1231231'),
];

/// Legt die Beispieldaten an; liefert die ID der heutigen Person.
Future<String> _seed(AppServices s, DateTime now) async {
  final db = s.db;
  final today = Days.of(now);
  final ids = <String, String>{};
  for (final (name, phone, importance, daysAgo, kind) in _people) {
    final id = await s.people.add(
      name: name,
      phone: phone,
      importance: importance,
      now: Days.add(today, -200),
    );
    ids[name] = id;
    await db
        .into(db.contactEvents)
        .insert(
          ContactEventsCompanion.insert(
            id: '$id-1',
            personId: id,
            kind: kind,
            at: Days.add(today, -daysAgo).add(const Duration(hours: 18, minutes: 20)),
          ),
        );
  }
  // Etwas mehr Verlauf für die Detailseite und die Statistik.
  final more = [
    ('Sam Muster', 2, EventKind.declined, 19, 5),
    ('Kim Lorenz', 1, EventKind.called, 12, 40),
    ('Alex Beispiel', 10, EventKind.called, 20, 15),
    ('Alex Beispiel', 17, EventKind.messaged, 8, 50),
    ('Alex Beispiel', 24, EventKind.called, 19, 30),
    ('Oma Hilde', 23, EventKind.called, 17, 0),
    ('Lea Brandt', 4, EventKind.called, 18, 45),
  ];
  var n = 0;
  for (final (name, daysAgo, kind, h, m) in more) {
    await db
        .into(db.contactEvents)
        .insert(
          ContactEventsCompanion.insert(
            id: 'extra-${n++}',
            personId: ids[name]!,
            kind: kind,
            at: Days.add(today, -daysAgo).add(Duration(hours: h, minutes: m)),
          ),
        );
  }
  await s.people.update(
    ids['Oma Hilde']!,
    note: const Value('Sonntags nach dem Mittagessen'),
  );
  // Heutiger Vorschlag: fest, damit das Bild stabil bleibt.
  final pick = ids['Sam Muster']!;
  await db
      .into(db.dailySuggestions)
      .insert(
        DailySuggestionsCompanion.insert(
          id: 'today',
          day: Days.key(today),
          personId: pick,
          status: SuggestionStatus.open,
          createdAt: now,
        ),
      );
  await s.settings.set(SettingKeys.onboarded, '1');
  return pick;
}

/// Telefonformat, Schriften, Schatten und Sprache für ein Bild.
Future<void> _prepare(WidgetTester tester, Locale locale) async {
  await tester.runAsync(_loadFonts);
  debugDisableShadows = false;
  tester.view.physicalSize = _physical;
  tester.view.devicePixelRatio = _ratio;
  tester.platformDispatcher.localesTestValue = [locale];
  tester.platformDispatcher.localeTestValue = locale;
  AppLocale.update(locale);
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearAllTestValues();
    AppLocale.update(AppLocale.german);
  });
}

/// Baum abbauen und offene Timer (Neuplanung der Benachrichtigungen)
/// ablaufen lassen. Die Dienste bleiben offen: ihr dispose() wartet in der
/// Testumgebung auf Streams, die niemand mehr liest (In-Memory-DB).
Future<void> _finish(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 3));
  // Vor der Invariantenprüfung zurücksetzen (nicht erst im tearDown).
  debugDisableShadows = true;
}

void main() {
  for (final locale in AppLocale.supported) {
    final lang = locale.languageCode;
    final dir = 'store/android/$lang/screenshots';

    testWidgets('Store: Einrichtung ($lang)', skip: !_enabled, (tester) async {
      await _prepare(tester, locale);
      final key = GlobalKey();
      final services = AppServices(testDb());
      await tester.pumpWidget(
        RepaintBoundary(key: key, child: RufDurchApp(services: services)),
      );
      await _wait(tester);
      await _shoot(tester, key, '$dir/06_onboarding.png');
      await _finish(tester);
    });

    /// Startet die App mit Beispieldaten (optional mit noch nicht
    /// eingeordneten Kontakten).
    Future<GlobalKey> start(WidgetTester tester, {bool unrated = false}) async {
      await _prepare(tester, locale);
      final key = GlobalKey();
      final services = AppServices(testDb());
      await tester.runAsync(() async {
        await _seed(services, DateTime.now());
        if (unrated) {
          for (final (name, phone) in _unrated) {
            await services.people.add(name: name, phone: phone);
          }
        }
      });
      await tester.pumpWidget(
        RepaintBoundary(key: key, child: RufDurchApp(services: services)),
      );
      await _wait(tester, 800);
      return key;
    }

    final l10n = lookupAppLocalizations(locale);

    testWidgets('Store: Heute, Kontakte, Verlauf ($lang)', skip: !_enabled, (
      tester,
    ) async {
      final key = await start(tester);
      await _shoot(tester, key, '$dir/01_today.png');

      await _tap(tester, find.text(l10n.tabContacts).last);
      await _shoot(tester, key, '$dir/02_contacts.png');

      await _tap(tester, find.text('Alex Beispiel').last);
      await _shoot(tester, key, '$dir/04_contact.png');
      await _tap(tester, find.byType(BackButton));

      await _tap(tester, find.text(l10n.tabHistory).last);
      await _shoot(tester, key, '$dir/05_history.png');
      await _finish(tester);
    });

    testWidgets('Store: Einordnen ($lang)', skip: !_enabled, (tester) async {
      final key = await start(tester, unrated: true);
      await _tap(tester, find.text(l10n.tabContacts).last);
      await _tap(tester, find.byTooltip(l10n.triageTitle));
      await _shoot(tester, key, '$dir/03_triage.png');
      await _finish(tester);
    });

    testWidgets('Store: Einstellungen ($lang)', skip: !_enabled, (tester) async {
      final key = await start(tester);
      await _tap(tester, find.byTooltip(l10n.settingsTitle));
      await _shoot(tester, key, '$dir/07_settings.png');
      await _finish(tester);
    });
  }
}
