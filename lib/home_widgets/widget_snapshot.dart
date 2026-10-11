import '../data/app_database.dart';
import '../data/repositories/people_repository.dart';
import '../data/repositories/suggestion_repository.dart';
import '../data/settings.dart';
import '../domain/days.dart';
import '../domain/phone.dart';
import '../l10n/l10n.dart';
import '../widgets/labels.dart';

/// Stand für das Homescreen-Widget „Heute anrufen“ (und, daraus abgeleitet,
/// für die Uhr) — ein JSON-Dokument, das die native Seite ohne Flutter
/// anzeigt.
///
/// „Heute/Morgen“ entscheidet die native Seite anhand von `day` selbst; ist
/// der gespeicherte Tag vorbei, nimmt sie den passenden Eintrag aus
/// `upcoming`. Im diskreten Modus stehen statt Namen nur Initialen drin.
///
/// Format nur erweitern (`v` bleibt 1); die native Seite ignoriert
/// unbekannte Felder.
abstract final class WidgetSnapshot {
  static const version = 1;
  static const maxUpcoming = 6;

  static Future<Map<String, Object?>> build(
    AppDatabase db,
    AppLocalizations l10n, {
    DateTime? now,
  }) async {
    final t = now ?? DateTime.now();
    final settings = Settings(db);
    final discreet = await settings.flag(SettingKeys.discreet);
    final plan = await SuggestionRepository(db).plan(now: t, days: 10);
    final last = await PeopleRepository(db).lastContacts();

    String name(Person p) => discreet ? Phone.initials(p.name) : p.name;

    String detail(Person p, DateTime day) {
      final since = last[p.id] == null
          ? null
          : Days.between(last[p.id]!.$1, day);
      return since == null || since < 0
          ? l10n.lastContactNever
          : l10n.lastContactDays(since);
    }

    Map<String, Object?>? entry(DateTime day, String id, {String? status}) {
      final p = plan.people[id];
      if (p == null) return null;
      return {
        'day': Days.key(day),
        'id': id,
        'name': name(p),
        'detail': detail(p, day),
        'phone': p.phone != null,
        'whatsapp': p.phone != null && p.whatsapp,
        'status': ?status,
      };
    }

    final today = plan.today;
    return {
      'v': version,
      'generatedAt': t.millisecondsSinceEpoch,
      'discreet': discreet,
      'labels': {
        'title': l10n.widgetTitle,
        'today': l10n.commonToday,
        'tomorrow': l10n.commonTomorrow,
        'call': l10n.actionCall,
        'whatsapp': l10n.actionWhatsApp,
        'later': l10n.actionLater,
        'done': l10n.widgetDone,
        'declined': l10n.widgetDeclined,
        'free': l10n.widgetFree,
        'empty': l10n.widgetEmpty,
        'upcoming': l10n.upcomingTitle,
        'weekdays': [for (var i = 1; i <= 7; i++) l10n.weekdayShort(i)],
      },
      'today': today == null
          ? null
          : entry(today.day, today.personId, status: today.status.name),
      'upcoming': [
        for (final u in plan.upcoming.take(maxUpcoming))
          ?entry(u.day, u.contactId),
      ],
    };
  }
}
