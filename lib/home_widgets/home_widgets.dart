import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/app_database.dart';
import '../data/repositories/suggestion_repository.dart';
import '../domain/days.dart';
import '../l10n/l10n.dart';
import 'widget_snapshot.dart';

/// Tipp auf das Widget (`mairuf-widget://<ziel>?d=<tag>&c=<kontakt>`).
class WidgetLink {
  const WidgetLink(this.action, {this.day, this.personId});

  /// `null` = nur die App öffnen.
  final SuggestionAction? action;
  final DateTime? day;
  final String? personId;

  static const scheme = 'mairuf-widget';

  static WidgetLink? parse(String? link) {
    if (link == null) return null;
    final uri = Uri.tryParse(link);
    if (uri == null || uri.scheme != scheme) return null;
    if (uri.host == 'open') return const WidgetLink(null);
    final action = SuggestionAction.parse(uri.host);
    final day = Days.parse(uri.queryParameters['d']);
    final person = uri.queryParameters['c'];
    if (action == null || day == null || person == null || person.isEmpty) {
      return const WidgetLink(null);
    }
    return WidgetLink(action, day: day, personId: person);
  }
}

/// Brücke zu Homescreen-Widget und Uhr (Kanal `mai/widgets`).
///
/// Nach jeder Änderung an der Datenbank geht ein neuer Stand an die native
/// Seite; Tipps auf das Widget kommen über [links].
class HomeWidgets {
  HomeWidgets(this.db);

  final AppDatabase db;

  static const _channel = MethodChannel('mai/widgets');

  final links = StreamController<WidgetLink>.broadcast();

  StreamSubscription<void>? _sub;
  Timer? _debounce;
  bool _started = false;

  /// Android: Widget und Wear OS; iOS: Apple Watch.
  static bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> start() async {
    if (!supported || _started) return;
    _started = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'open') {
        final link = WidgetLink.parse(call.arguments as String?);
        if (link != null) links.add(link);
      }
      return null;
    });
    _sub = db.tableUpdates().listen((_) => schedulePublish());
    AppLocale.changes.addListener(schedulePublish);
    try {
      final initial = WidgetLink.parse(
        await _channel.invokeMethod<String>('initialLink'),
      );
      if (initial != null) links.add(initial);
    } on PlatformException {
      // Widgets sind Beiwerk — die App muss trotzdem starten.
    } on MissingPluginException {
      return;
    }
    await publish();
  }

  void schedulePublish() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      publish().catchError((_) {});
    });
  }

  Future<void> publish() async {
    if (!supported) return;
    _debounce?.cancel();
    final snapshot = await WidgetSnapshot.build(db, AppLocale.strings);
    try {
      await _channel.invokeMethod<void>('update', jsonEncode(snapshot));
    } on PlatformException {
      // Nächster Versuch bei der nächsten Änderung.
    } on MissingPluginException {
      // Keine native Seite (Tests).
    }
  }

  Future<void> dispose() async {
    _debounce?.cancel();
    if (_started) AppLocale.changes.removeListener(schedulePublish);
    await _sub?.cancel();
    await links.close();
  }
}
