import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/app_database.dart';
import '../data/repositories/people_repository.dart';
import '../data/repositories/suggestion_repository.dart';
import '../data/settings.dart';
import '../domain/days.dart';
import '../l10n/l10n.dart';
import 'pending_actions.dart';

/// Inhalt einer Benachrichtigung: Tag, Kontakt (interne ID) und wohin
/// Hintergrund-Reaktionen geschrieben werden.
class NotificationPayload {
  const NotificationPayload({
    required this.day,
    required this.personId,
    this.queuePath,
  });

  final DateTime day;
  final String personId;
  final String? queuePath;

  String encode() => jsonEncode({
    'd': Days.key(day),
    'c': personId,
    if (queuePath != null) 'q': queuePath,
  });

  static NotificationPayload? parse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map) return null;
      final day = Days.parse(json['d'] as String?);
      final person = json['c'];
      if (day == null || person is! String) return null;
      final queue = json['q'];
      return NotificationPayload(
        day: day,
        personId: person,
        queuePath: queue is String ? queue : null,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Tipp auf eine Benachrichtigung bei geöffneter App ([action] `null` =
/// Benachrichtigung selbst angetippt).
class NotificationTap {
  const NotificationTap(this.payload, this.action);

  final NotificationPayload payload;
  final SuggestionAction? action;
}

/// „Heute nicht“ ohne geöffnete App: läuft in einem eigenen Isolat und
/// schreibt nur in die Warteschlange (keine Datenbank, kein Schlüssel).
@pragma('vm:entry-point')
Future<void> notificationBackgroundHandler(NotificationResponse response) async {
  final payload = NotificationPayload.parse(response.payload);
  final action = SuggestionAction.parse(response.actionId);
  if (payload == null || action == null) return;
  var path = payload.queuePath;
  if (path == null) {
    try {
      path = await DailyNotifications.queuePath();
    } catch (_) {
      return;
    }
  }
  await PendingActions(path).add(
    PendingAction(
      day: payload.day,
      personId: payload.personId,
      action: action,
      at: DateTime.now(),
    ),
  );
}

/// Tägliche Benachrichtigung mit dem Vorschlag — lokal geplant, kein
/// Server, kein Push. Geplant werden die nächsten Tage aus der Vorschau,
/// neu bei jeder Änderung. Aktionen: „Heute nicht“, „Anrufen“, „WhatsApp“.
class DailyNotifications {
  DailyNotifications(this.db);

  final AppDatabase db;
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  /// Tipps bei laufender App (und der Start über eine Benachrichtigung).
  final taps = StreamController<NotificationTap>.broadcast();

  static const _deviceChannel = MethodChannel('mai/device');
  static const daysAhead = 14;
  static const _channelId = 'daily_suggestion';

  /// iOS-Kategorien je nach verfügbaren Aktionen.
  static const _categoryAll = 'ruf_all';
  static const _categoryCall = 'ruf_call';
  static const _categoryLater = 'ruf_later';

  static bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static Future<String> queuePath() async => p.join(
    (await getApplicationSupportDirectory()).path,
    PendingActions.fileName,
  );

  Future<void> init() async {
    if (_ready || !supported) return;
    tz.initializeTimeZones();
    try {
      final zone = await _deviceChannel.invokeMethod<String>('timeZone');
      tz.setLocalLocation(tz.getLocation(zone ?? 'Europe/Berlin'));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
    }
    final strings = AppLocale.strings;
    DarwinNotificationAction later() => DarwinNotificationAction.plain(
      'later',
      strings.actionLater,
    );
    DarwinNotificationAction call() => DarwinNotificationAction.plain(
      'call',
      strings.actionCall,
      options: {DarwinNotificationActionOption.foreground},
    );
    final settings = InitializationSettings(
      android: const AndroidInitializationSettings('@drawable/ic_notification'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        notificationCategories: [
          DarwinNotificationCategory(
            _categoryAll,
            actions: [
              later(),
              call(),
              DarwinNotificationAction.plain(
                'whatsapp',
                strings.actionWhatsApp,
                options: {DarwinNotificationActionOption.foreground},
              ),
            ],
          ),
          DarwinNotificationCategory(_categoryCall, actions: [later(), call()]),
          DarwinNotificationCategory(_categoryLater, actions: [later()]),
        ],
      ),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onResponse,
      onDidReceiveBackgroundNotificationResponse: notificationBackgroundHandler,
    );
    _ready = true;
    // App über eine Benachrichtigung (oder deren Aktion) gestartet.
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final response = launch?.notificationResponse;
    if (launch?.didNotificationLaunchApp == true && response != null) {
      _onResponse(response);
    }
  }

  void _onResponse(NotificationResponse response) {
    final payload = NotificationPayload.parse(response.payload);
    if (payload == null) return;
    taps.add(NotificationTap(payload, SuggestionAction.parse(response.actionId)));
  }

  Future<bool> requestPermission() async {
    if (!supported) return false;
    try {
      await init();
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(alert: true, sound: true) ?? false;
    } catch (e) {
      // Ohne Erlaubnis läuft die App normal weiter (auch in Tests ohne Plugin).
      debugPrint('Benachrichtigungen nicht verfügbar: $e');
      return false;
    }
  }

  /// Zeitpunkte für die Vorschläge ab heute (für Tests ohne Plugin): nur
  /// in der Zukunft, heute nur bei offenem Vorschlag.
  static List<(DateTime, String)> plannedTimes({
    required List<(DateTime, String)> picks,
    required int minutes,
    required DateTime now,
  }) => [
    for (final (day, id) in picks)
      if (DateTime(day.year, day.month, day.day, minutes ~/ 60, minutes % 60)
          .isAfter(now))
        (DateTime(day.year, day.month, day.day, minutes ~/ 60, minutes % 60), id),
  ];

  /// Alles neu planen.
  Future<void> reschedule() async {
    if (!supported) return;
    await init();
    await _plugin.cancelAll();
    final settings = Settings(db);
    if (!await settings.flag(SettingKeys.notificationsEnabled)) return;
    final minutes = await settings.number(
      SettingKeys.notificationMinutes,
      Settings.defaultNotificationMinutes,
    );
    final now = DateTime.now();
    final plan = await SuggestionRepository(db).plan(now: now, days: daysAhead);
    final picks = <(DateTime, String)>[
      if (plan.today case final t? when t.open) (t.day, t.personId),
      for (final u in plan.upcoming) (u.day, u.contactId),
    ];
    final last = await PeopleRepository(db).lastContacts();
    final queue = await queuePath();
    final strings = AppLocale.strings;
    var id = 100;
    for (final (at, personId) in plannedTimes(
      picks: picks,
      minutes: minutes,
      now: now,
    )) {
      final person = plan.people[personId];
      if (person == null) continue;
      final since = last[personId] == null
          ? null
          : Days.between(last[personId]!.$1, at);
      final hasPhone = person.phone != null;
      final canMessage = hasPhone && person.whatsapp;
      await _plugin.zonedSchedule(
        id: id++,
        scheduledDate: tz.TZDateTime.from(at, tz.local),
        title: strings.notificationTitle(person.name),
        body: since == null || since <= 0
            ? strings.notificationBodyNew
            : strings.notificationBodySince(since),
        payload: NotificationPayload(
          day: Days.of(at),
          personId: personId,
          queuePath: queue,
        ).encode(),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            strings.notificationChannel,
            channelDescription: strings.notificationChannelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            category: AndroidNotificationCategory.reminder,
            // Sperrbildschirm: Inhalt nur nach Systemeinstellung.
            visibility: NotificationVisibility.private,
            actions: [
              AndroidNotificationAction('later', strings.actionLater),
              if (hasPhone)
                AndroidNotificationAction(
                  'call',
                  strings.actionCall,
                  showsUserInterface: true,
                ),
              if (canMessage)
                AndroidNotificationAction(
                  'whatsapp',
                  strings.actionWhatsApp,
                  showsUserInterface: true,
                ),
            ],
          ),
          iOS: DarwinNotificationDetails(
            categoryIdentifier: canMessage
                ? _categoryAll
                : hasPhone
                ? _categoryCall
                : _categoryLater,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> dispose() => taps.close();
}
