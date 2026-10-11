/// Wie wichtig ein Kontakt ist. Gespeichert wird der Index (`intEnum`):
/// neue Werte nur hinten anhängen, nie umsortieren oder löschen.
enum Importance {
  /// Nie vorschlagen (bleibt in der Liste, z. B. für „Kontakt eingetragen“).
  never,

  /// Selten — etwa alle drei Monate.
  rarely,

  /// Ab und zu — etwa einmal im Monat.
  sometimes,

  /// Oft — etwa alle zwei Wochen.
  often,

  /// Sehr wichtig — etwa jede Woche.
  veryOften;

  /// Angestrebter Abstand zwischen zwei Kontakten in Tagen; `null` = nie.
  int? get targetDays => switch (this) {
    Importance.never => null,
    Importance.rarely => 90,
    Importance.sometimes => 30,
    Importance.often => 14,
    Importance.veryOften => 7,
  };

  /// Leichter Vorrang wichtiger Kontakte bei gleicher Überfälligkeit.
  double get boost => switch (this) {
    Importance.never => 0,
    Importance.rarely => 0.8,
    Importance.sometimes => 1,
    Importance.often => 1.25,
    Importance.veryOften => 1.5,
  };

  /// Reihenfolge für Anzeige und Auswahl: wichtigste zuerst.
  static const ranked = [
    Importance.veryOften,
    Importance.often,
    Importance.sometimes,
    Importance.rarely,
    Importance.never,
  ];
}
