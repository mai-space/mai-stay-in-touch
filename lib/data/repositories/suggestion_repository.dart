import 'dart:math';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/days.dart';
import '../../domain/suggestions.dart';
import '../app_database.dart';
import '../settings.dart';

const _uuid = Uuid();

/// Was der Nutzer mit einem Vorschlag macht.
enum SuggestionAction {
  call,
  whatsapp,

  /// „Heute nicht“.
  later,

  /// „Kontakt eintragen“ (auf anderem Weg gesprochen).
  noted;

  static SuggestionAction? parse(String? id) => switch (id) {
    'call' => SuggestionAction.call,
    'whatsapp' => SuggestionAction.whatsapp,
    'later' => SuggestionAction.later,
    'noted' => SuggestionAction.noted,
    _ => null,
  };

  /// Öffnet Wähl-App bzw. WhatsApp.
  bool get launches =>
      this == SuggestionAction.call || this == SuggestionAction.whatsapp;

  EventKind get event => switch (this) {
    SuggestionAction.call => EventKind.called,
    SuggestionAction.whatsapp => EventKind.messaged,
    SuggestionAction.later => EventKind.declined,
    SuggestionAction.noted => EventKind.noted,
  };

  SuggestionStatus get status => switch (this) {
    SuggestionAction.call => SuggestionStatus.called,
    SuggestionAction.whatsapp => SuggestionStatus.messaged,
    SuggestionAction.later => SuggestionStatus.declined,
    SuggestionAction.noted => SuggestionStatus.noted,
  };
}

/// Vorschlag für heute.
class TodayPick {
  const TodayPick({
    required this.day,
    required this.personId,
    required this.status,
    this.suggestionId,
  });

  final DateTime day;
  final String personId;
  final SuggestionStatus status;

  /// `null`: noch nicht gespeichert (nur berechnet).
  final String? suggestionId;

  bool get open => status == SuggestionStatus.open;
}

/// Heute und die nächsten Tage.
class Plan {
  const Plan({
    required this.today,
    required this.upcoming,
    required this.people,
    required this.isSuggestionDay,
  });

  final TodayPick? today;
  final List<DayPick> upcoming;
  final Map<String, Person> people;

  /// Heute ist ein gewählter Vorschlagstag.
  final bool isSuggestionDay;
}

/// Eintrag im Verlauf.
class HistoryEntry {
  const HistoryEntry(this.event, this.person);

  final ContactEvent event;
  final Person? person;
}

class SuggestionRepository {
  SuggestionRepository(this.db, {Random? random})
    : _random = random ?? Random.secure();

  final AppDatabase db;
  final Random _random;

  Settings get _settings => Settings(db);

  /// Zufälliges Salz der Auslosung (einmal pro Installation).
  Future<int> salt() async {
    final stored = int.tryParse(await _settings.get(SettingKeys.drawSalt) ?? '');
    if (stored != null) return stored;
    final value = _random.nextInt(1 << 30);
    await _settings.set(SettingKeys.drawSalt, '$value');
    return value;
  }

  Future<Set<int>> weekdays() async =>
      Days.parseWeekdays(await _settings.get(SettingKeys.suggestionDays));

  /// Fakten aller aktiven Kontakte aus dem Verlauf.
  Future<List<ContactFacts>> facts() async {
    final people = await (db.select(
      db.people,
    )..where((t) => t.archived.equals(false))).get();
    final events = await (db.select(
      db.contactEvents,
    )..orderBy([(t) => OrderingTerm(expression: t.at)])).get();
    final suggestions = await db.select(db.dailySuggestions).get();

    final last = <String, DateTime>{};
    for (final e in events) {
      if (e.kind != EventKind.declined) last[e.personId] = e.at;
    }
    final declines = <String, int>{};
    for (final e in events) {
      if (e.kind != EventKind.declined) continue;
      final l = last[e.personId];
      if (l == null || e.at.isAfter(l)) {
        declines[e.personId] = (declines[e.personId] ?? 0) + 1;
      }
    }
    final lastSuggested = <String, DateTime>{};
    final suggested = <String, int>{};
    final accepted = <String, int>{};
    for (final s in suggestions) {
      final day = Days.parse(s.day);
      if (day == null) continue;
      final prev = lastSuggested[s.personId];
      if (prev == null || day.isAfter(prev)) lastSuggested[s.personId] = day;
      suggested[s.personId] = (suggested[s.personId] ?? 0) + 1;
      if (s.status.accepted) {
        accepted[s.personId] = (accepted[s.personId] ?? 0) + 1;
      }
    }
    return [
      for (final p in people)
        ContactFacts(
          id: p.id,
          importance: p.importance,
          createdAt: p.createdAt,
          lastContact: last[p.id],
          lastSuggested: lastSuggested[p.id],
          pausedUntil: p.pausedUntil,
          declinesSinceContact: declines[p.id] ?? 0,
          suggested: suggested[p.id] ?? 0,
          accepted: accepted[p.id] ?? 0,
        ),
    ];
  }

  /// Gültiger Vorschlag für [day] (zuletzt angelegter).
  Future<DailySuggestion?> current(DateTime day) =>
      (db.select(db.dailySuggestions)
            ..where((t) => t.day.equals(Days.key(day)))
            ..orderBy([
              (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
            ])
            ..limit(1))
          .getSingleOrNull();

  Stream<void> changes() => db.tableUpdates(
    TableUpdateQuery.onAllTables([
      db.people,
      db.contactEvents,
      db.dailySuggestions,
      db.localSettings,
    ]),
  );

  /// Heute und Vorschau. Speichert nichts; der heutige Vorschlag ist der
  /// gespeicherte oder — gleich gezogen wie später gespeichert — berechnet.
  Future<Plan> plan({DateTime? now, int days = 14}) async {
    final today = Days.of(now ?? DateTime.now());
    final all = await facts();
    final weekdays = await this.weekdays();
    final s = await salt();
    final people = {
      for (final p in await (db.select(db.people)).get()) p.id: p,
    };
    final stored = await current(today);
    final isDay = weekdays.contains(today.weekday);

    TodayPick? pick;
    if (stored != null && people[stored.personId]?.archived != true) {
      pick = TodayPick(
        day: today,
        personId: stored.personId,
        status: stored.status,
        suggestionId: stored.id,
      );
    } else if (isDay && stored == null) {
      final id = Suggestions.draw(all, today, salt: s);
      if (id != null) {
        pick = TodayPick(day: today, personId: id, status: SuggestionStatus.open);
      }
    }

    // Vorschau ab heute (heutigen Vorschlag festhalten), heute weglassen.
    final fixed = <String, String>{};
    if (pick != null && pick.status != SuggestionStatus.declined) {
      fixed[Days.key(today)] = pick.personId;
    }
    final upcoming = Suggestions.forecast(
      contacts: all,
      from: fixed.isEmpty ? Days.add(today, 1) : today,
      days: fixed.isEmpty ? days : days + 1,
      weekdays: weekdays,
      salt: s,
      fixed: fixed,
    ).where((p) => p.day.isAfter(today)).toList();
    return Plan(
      today: pick,
      upcoming: upcoming,
      people: people,
      isSuggestionDay: isDay,
    );
  }

  /// Speichert den heutigen Vorschlag, falls noch keiner feststeht (beim
  /// Öffnen der App, damit er sich danach nicht mehr ändert).
  Future<DailySuggestion?> ensureToday({DateTime? now}) async {
    final today = Days.of(now ?? DateTime.now());
    final stored = await current(today);
    if (stored != null) return stored;
    final plan = await this.plan(now: today, days: 0);
    final pick = plan.today;
    if (pick == null) return null;
    return _insert(today, pick.personId, SuggestionStatus.open, now: now);
  }

  Future<DailySuggestion> _insert(
    DateTime day,
    String personId,
    SuggestionStatus status, {
    DateTime? now,
  }) async {
    final row = DailySuggestionsCompanion.insert(
      id: _uuid.v4(),
      day: Days.key(day),
      personId: personId,
      status: status,
      createdAt: now ?? DateTime.now(),
    );
    await db.into(db.dailySuggestions).insert(row);
    return (await (db.select(
      db.dailySuggestions,
    )..where((t) => t.id.equals(row.id.value))).getSingle());
  }

  /// Reaktion auf den Vorschlag für [day] (aus App, Benachrichtigung oder
  /// Widget). Gibt es für den Tag noch keinen gespeicherten Vorschlag mit
  /// dieser Person, wird er angelegt. Doppelte Reaktionen zählen einmal.
  Future<void> act(
    DateTime day,
    String personId,
    SuggestionAction action, {
    DateTime? now,
  }) async {
    final t = now ?? DateTime.now();
    await db.transaction(() async {
      final rows = await (db.select(db.dailySuggestions)
            ..where(
              (s) => s.day.equals(Days.key(day)) & s.personId.equals(personId),
            )
            ..orderBy([
              (s) => OrderingTerm(expression: s.createdAt, mode: OrderingMode.desc),
            ]))
          .get();
      var suggestion = rows.isEmpty ? null : rows.first;
      if (suggestion != null && suggestion.status == action.status) return;
      // „Heute nicht“ nach einem Anruf ändert nichts mehr.
      if (suggestion != null &&
          action == SuggestionAction.later &&
          suggestion.status != SuggestionStatus.open) {
        return;
      }
      if (suggestion == null) {
        suggestion = await _insert(day, personId, action.status, now: t);
      } else {
        await (db.update(db.dailySuggestions)
              ..where((s) => s.id.equals(suggestion!.id)))
            .write(DailySuggestionsCompanion(status: Value(action.status)));
      }
      await db
          .into(db.contactEvents)
          .insert(
            ContactEventsCompanion.insert(
              id: _uuid.v4(),
              personId: personId,
              kind: action.event,
              at: t,
              suggestionId: Value(suggestion.id),
            ),
          );
    });
  }

  /// „Jemand anderen“ bzw. „Trotzdem jemanden vorschlagen“: heutigen
  /// Vorschlag ablehnen und neu ziehen (ohne die heute schon
  /// Vorgeschlagenen, notfalls auch nicht ganz Fällige). Liefert die neue
  /// Person oder `null`.
  Future<String?> another({DateTime? now}) async {
    final t = now ?? DateTime.now();
    final today = Days.of(t);
    final stored = await current(today) ?? await ensureToday(now: t);
    if (stored != null && stored.status == SuggestionStatus.open) {
      await act(today, stored.personId, SuggestionAction.later, now: t);
    }
    final todays = await (db.select(
      db.dailySuggestions,
    )..where((s) => s.day.equals(Days.key(today)))).get();
    final exclude = {for (final s in todays) s.personId};
    final facts = await this.facts();
    final id = Suggestions.draw(
      facts,
      today,
      salt: await salt(),
      exclude: exclude,
      relaxed: true,
    );
    if (id == null) return null;
    await _insert(today, id, SuggestionStatus.open, now: t);
    return id;
  }

  /// Von Hand: „Wir hatten Kontakt“ (z. B. getroffen, selbst angerufen).
  Future<void> note(String personId, {DateTime? at}) => db
      .into(db.contactEvents)
      .insert(
        ContactEventsCompanion.insert(
          id: _uuid.v4(),
          personId: personId,
          kind: EventKind.noted,
          at: at ?? DateTime.now(),
        ),
      );

  /// Verlauf, neueste zuerst.
  Stream<List<HistoryEntry>> watchHistory({String? personId, int? limit}) {
    final query = db.select(db.contactEvents)
      ..orderBy([(t) => OrderingTerm(expression: t.at, mode: OrderingMode.desc)]);
    if (personId != null) query.where((t) => t.personId.equals(personId));
    if (limit != null) query.limit(limit);
    return query.watch().asyncMap((events) async {
      final people = {
        for (final p in await db.select(db.people).get()) p.id: p,
      };
      return [for (final e in events) HistoryEntry(e, people[e.personId])];
    });
  }

  /// Eintrag löschen (Rückgängig); ein zugehöriger Vorschlag wird wieder
  /// offen.
  Future<void> deleteEvent(String id) => db.transaction(() async {
    final event = await (db.select(
      db.contactEvents,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (event == null) return;
    await (db.delete(db.contactEvents)..where((t) => t.id.equals(id))).go();
    final sid = event.suggestionId;
    if (sid != null) {
      await (db.update(db.dailySuggestions)..where((t) => t.id.equals(sid)))
          .write(const DailySuggestionsCompanion(status: Value(SuggestionStatus.open)));
    }
  });

  /// Kontakte (Anrufe, Nachrichten, eingetragen) seit [since].
  Future<int> contactsSince(DateTime since) async {
    final rows = await (db.select(db.contactEvents)
          ..where(
            (t) =>
                t.kind.isNotValue(EventKind.declined.index) &
                t.at.isBiggerOrEqualValue(since),
          ))
        .get();
    return rows.length;
  }
}
