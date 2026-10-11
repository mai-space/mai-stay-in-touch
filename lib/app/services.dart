import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../data/app_database.dart';
import '../data/repositories/people_repository.dart';
import '../data/repositories/suggestion_repository.dart';
import '../data/settings.dart';
import '../domain/phone.dart';
import '../home_widgets/home_widgets.dart';
import '../services/daily_notifications.dart';
import '../services/device_contacts.dart';
import '../services/launcher.dart';
import '../services/pending_actions.dart';

/// Ergebnis einer Reaktion auf einen Vorschlag.
enum ActionOutcome { done, noNumber, launchFailed }

/// Alle Dienste der App an einem Ort (ohne zusätzliches State-Paket).
class AppServices {
  AppServices(
    this.db, {
    this.launcher = const Launcher(),
    this.contacts = const DeviceContacts(),
  }) : settings = Settings(db),
       people = PeopleRepository(db),
       suggestions = SuggestionRepository(db),
       notifications = DailyNotifications(db),
       widgets = HomeWidgets(db);

  final AppDatabase db;
  final Settings settings;
  final PeopleRepository people;
  final SuggestionRepository suggestions;
  final DailyNotifications notifications;
  final HomeWidgets widgets;
  final Launcher launcher;
  final DeviceContacts contacts;

  Timer? _rescheduleTimer;
  StreamSubscription<void>? _sub;

  /// Benachrichtigungen nach Änderungen neu planen — gebündelt.
  void watchForNotifications() {
    _sub ??= suggestions.changes().listen((_) => scheduleNotifications());
  }

  void scheduleNotifications() {
    _rescheduleTimer?.cancel();
    _rescheduleTimer = Timer(const Duration(seconds: 2), () {
      notifications.reschedule().catchError((Object e) {
        debugPrint('Planen fehlgeschlagen: $e');
      });
    });
  }

  /// Ländervorwahl (Einstellung, sonst aus der Region des Geräts).
  Future<String> countryCode() async {
    final stored = await settings.get(SettingKeys.countryCode);
    if (stored != null && stored.trim().isNotEmpty) return stored.trim();
    return Phone.countryCodeFor(kIsWeb ? null : Platform.localeName);
  }

  /// Reaktion auf den Vorschlag für [day] — speichert sie und öffnet bei
  /// „Anrufen“/„WhatsApp“ die Wähl-App bzw. WhatsApp.
  Future<ActionOutcome> act(
    DateTime day,
    String personId,
    SuggestionAction action,
  ) async {
    if (!action.launches) {
      await suggestions.act(day, personId, action);
      return ActionOutcome.done;
    }
    final person = await people.byId(personId);
    final phone = person?.phone;
    if (phone == null) return ActionOutcome.noNumber;
    final ok = action == SuggestionAction.call
        ? await launcher.dial(phone)
        : await launcher.whatsapp(phone, await countryCode());
    // Gezählt wird der Versuch — auch wenn danach niemand abhebt.
    if (ok) await suggestions.act(day, personId, action);
    return ok ? ActionOutcome.done : ActionOutcome.launchFailed;
  }

  /// Direkt anrufen/schreiben ohne Vorschlag (Kontaktseite): wird als
  /// Kontakt eingetragen.
  Future<ActionOutcome> reach(String personId, SuggestionAction action) async {
    final person = await people.byId(personId);
    final phone = person?.phone;
    if (phone == null) return ActionOutcome.noNumber;
    final ok = action == SuggestionAction.call
        ? await launcher.dial(phone)
        : await launcher.whatsapp(phone, await countryCode());
    if (!ok) return ActionOutcome.launchFailed;
    // Ist die Person heute vorgeschlagen, zählt es für den Vorschlag.
    final today = DateTime.now();
    final current = await suggestions.current(today);
    if (current != null && current.personId == personId) {
      await suggestions.act(today, personId, action);
    } else {
      await suggestions.note(personId);
    }
    return ActionOutcome.done;
  }

  /// Reaktionen aus der Warteschlange übernehmen („Heute nicht“ in der
  /// Benachrichtigung ohne geöffnete App).
  Future<int> applyPending() async {
    if (!DailyNotifications.supported) return 0;
    final String path;
    try {
      path = await DailyNotifications.queuePath();
    } catch (_) {
      return 0;
    }
    final pending = await PendingActions(path).take();
    for (final a in pending) {
      if (await people.byId(a.personId) == null) continue;
      await suggestions.act(a.day, a.personId, a.action, now: a.at);
    }
    return pending.length;
  }

  Future<void> dispose() async {
    _rescheduleTimer?.cancel();
    await _sub?.cancel();
    await widgets.dispose();
    await notifications.dispose();
    await db.close();
  }
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  /// Dienste ändern sich nie — daher ohne Abhängigkeit (auch in
  /// `initState` nutzbar).
  static AppServices of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.services;

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      services != oldWidget.services;
}

extension AppScopeContext on BuildContext {
  AppServices get services => AppScope.of(this);
}
