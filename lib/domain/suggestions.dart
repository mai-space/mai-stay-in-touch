import 'dart:math';

import 'days.dart';
import 'importance.dart';

/// Was die Auslosung über einen Kontakt wissen muss — aus dem lokalen
/// Verlauf abgeleitet (siehe `SuggestionRepository.facts`).
class ContactFacts {
  const ContactFacts({
    required this.id,
    required this.importance,
    required this.createdAt,
    this.lastContact,
    this.lastSuggested,
    this.pausedUntil,
    this.declinesSinceContact = 0,
    this.suggested = 0,
    this.accepted = 0,
  });

  final String id;

  /// `null` = noch nicht eingeordnet → wird nicht vorgeschlagen.
  final Importance? importance;
  final DateTime createdAt;

  /// Letzter Anruf, letzte Nachricht oder eingetragener Kontakt.
  final DateTime? lastContact;

  /// Tag des letzten Vorschlags.
  final DateTime? lastSuggested;

  /// Pausiert bis einschließlich diesem Tag.
  final DateTime? pausedUntil;

  /// „Heute nicht“ seit dem letzten Kontakt.
  final int declinesSinceContact;

  /// Vorschläge insgesamt und davon angenommen (Anruf oder Nachricht).
  final int suggested;
  final int accepted;

  ContactFacts copyWith({
    DateTime? lastContact,
    DateTime? lastSuggested,
    int? declinesSinceContact,
    int? suggested,
    int? accepted,
  }) => ContactFacts(
    id: id,
    importance: importance,
    createdAt: createdAt,
    lastContact: lastContact ?? this.lastContact,
    lastSuggested: lastSuggested ?? this.lastSuggested,
    pausedUntil: pausedUntil,
    declinesSinceContact: declinesSinceContact ?? this.declinesSinceContact,
    suggested: suggested ?? this.suggested,
    accepted: accepted ?? this.accepted,
  );
}

/// Vorschlag für einen Tag.
class DayPick {
  const DayPick(this.day, this.contactId);

  final DateTime day;
  final String contactId;

  @override
  bool operator ==(Object other) =>
      other is DayPick && other.day == day && other.contactId == contactId;

  @override
  int get hashCode => Object.hash(day, contactId);

  @override
  String toString() => 'DayPick(${Days.key(day)}, $contactId)';
}

/// Tägliche Auslosung: gewichteter Zufall nach Wichtigkeit und
/// Überfälligkeit, gedämpft durch „Heute nicht“ und angepasst an das, was
/// der Nutzer bisher angenommen hat.
///
/// Der Zufall ist je Tag fest (Startwert aus Datum und einem Salz pro
/// Installation): Gleicher Stand → gleicher Vorschlag. So stimmen Vorschau,
/// geplante Benachrichtigung und App überein.
abstract final class Suggestions {
  /// So lange nach einem Vorschlag kommt derselbe Kontakt nicht wieder.
  static const cooldownDays = 3;

  /// Gerade erst gesprochen: Anteil des Zielabstands ohne neuen Vorschlag.
  static const recentShare = 0.25;

  /// Jedes „Heute nicht“ seit dem letzten Kontakt senkt das Gewicht.
  static const declineFactor = 0.6;
  static const minDeclineFactor = 0.15;

  /// Noch nie kontaktiert: so überfällig wie anderthalb Zielabstände.
  static const neverContactedOverdue = 1.5;

  /// Gewicht für [day]; 0 = an diesem Tag nicht vorschlagen. [relaxed]
  /// ignoriert Abklingzeit und „gerade erst gesprochen“ (wenige Kontakte).
  static double weight(ContactFacts c, DateTime day, {bool relaxed = false}) {
    final importance = c.importance;
    final target = importance?.targetDays;
    if (importance == null || target == null) return 0;
    if (c.pausedUntil != null && Days.between(day, c.pausedUntil!) >= 0) {
      return 0;
    }
    if (c.lastSuggested != null && Days.between(c.lastSuggested!, day) <= 0) {
      return 0; // heute schon vorgeschlagen
    }
    final since = c.lastContact == null
        ? null
        : Days.between(c.lastContact!, day);
    if (!relaxed) {
      if (c.lastSuggested != null &&
          Days.between(c.lastSuggested!, day) < cooldownDays) {
        return 0;
      }
      if (since != null && since < max(1, (target * recentShare).round())) {
        return 0;
      }
    }
    final overdue = since == null
        ? neverContactedOverdue
        : max(0, since) / target;
    final due = overdue < 1
        ? max(0.05, overdue * overdue)
        : pow(min(overdue, 4), 1.5).toDouble();
    final penalty = max(
      minDeclineFactor,
      pow(declineFactor, c.declinesSinceContact).toDouble(),
    );
    // Annahmequote mit Vorwissen 1/2 → Faktor 0,6 … 1,4.
    final rate = (c.accepted + 1) / (c.suggested + 2);
    final responsiveness = 0.6 + 0.8 * rate;
    return importance.boost * due * penalty * responsiveness;
  }

  /// Zieht einen Kontakt für [day]; `null`, wenn gerade niemand fällig
  /// ist. [relaxed]: notfalls auch kürzlich Vorgeschlagene oder Gesprochene
  /// („Trotzdem jemanden vorschlagen“, „Jemand anderen“).
  static String? draw(
    Iterable<ContactFacts> contacts,
    DateTime day, {
    int salt = 0,
    Set<String> exclude = const {},
    bool relaxed = false,
  }) {
    final pool = contacts.where((c) => !exclude.contains(c.id)).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    final random = Random(seed(day, salt, exclude.length));
    for (final loose in [false, if (relaxed) true]) {
      final weights = [for (final c in pool) weight(c, day, relaxed: loose)];
      final total = weights.fold<double>(0, (a, b) => a + b);
      if (total <= 0) continue;
      var r = random.nextDouble() * total;
      for (var i = 0; i < pool.length; i++) {
        if (weights[i] <= 0) continue;
        r -= weights[i];
        if (r <= 0) return pool[i].id;
      }
      return pool.lastWhere((c) => weight(c, day, relaxed: loose) > 0).id;
    }
    return null;
  }

  /// Fester Startwert je Tag (und je Neuversuch am selben Tag).
  static int seed(DateTime day, int salt, [int attempt = 0]) {
    var h = 0x2545F491 ^ salt;
    for (final v in [day.year, day.month, day.day, attempt]) {
      h = (h * 31 + v) & 0x3fffffff;
      h ^= h >> 13;
    }
    return h;
  }

  /// Vorschau ab [from] für [days] Tage an den gewählten [weekdays].
  /// [fixed]: schon feststehende Vorschläge (Tagesschlüssel → Kontakt).
  /// Für jeden Vorschlag wird angenommen, dass der Kontakt zustande kommt.
  static List<DayPick> forecast({
    required Iterable<ContactFacts> contacts,
    required DateTime from,
    int days = 14,
    Set<int> weekdays = Days.allWeekdays,
    int salt = 0,
    Map<String, String> fixed = const {},
  }) {
    final state = {for (final c in contacts) c.id: c};
    final out = <DayPick>[];
    for (var i = 0; i < days; i++) {
      final day = Days.add(Days.of(from), i);
      final pinned = fixed[Days.key(day)];
      if (pinned == null && !weekdays.contains(day.weekday)) continue;
      final id = pinned ?? draw(state.values, day, salt: salt);
      if (id == null) continue;
      out.add(DayPick(day, id));
      final c = state[id];
      if (c != null) {
        state[id] = c.copyWith(
          lastContact: day,
          lastSuggested: day,
          declinesSinceContact: 0,
        );
      }
    }
    return out;
  }
}
