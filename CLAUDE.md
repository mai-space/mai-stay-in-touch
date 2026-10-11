# Ruf durch (mai-stay-in-touch) — Hinweise für Änderungen

Lokale App für den täglichen Anruf-Vorschlag (Flutter, Android; iOS mit
Apple Watch vorbereitet). Gleiche Prinzipien und gleicher Stack wie die
anderen Mai-Apps. Angezeigter Name „Ruf durch“ (ohne „Mai“), Paket
`space.mai.mai_stay_in_touch`, CI-Artefakte `mai-stay-in-touch.apk` und
`mai-stay-in-touch-wear.apk`. UI Deutsch/Englisch nach Systemsprache.
Konzept: `docs/KONZEPT.md`.

## Datenschutz (Pflicht)

- Keine echten Kontakte, Nummern oder Verläufe ins Repo (Sicherungen,
  Exporte, Screenshots). Testdaten frei erfunden („Alex“, „Sam“).
  `.gitignore` blockt `*.mairuf`, `*.csv`, `*.vcf` — nicht aufweichen.
- Keine INTERNET-Berechtigung im Manifest, kein Android-Backup
  (`allowBackup=false`, `data_extraction_rules.xml`), keine Analytics.
- Nur `READ_CONTACTS` (lesen, auf Wunsch). Keine Telefon-Berechtigung:
  Anrufen nur über die Wähl-App (`ACTION_DIAL`), WhatsApp über `wa.me`.
- Widget/Uhr bekommen keine Telefonnummern; im diskreten Modus nur
  Initialen.

## Rückwärtskompatibilität (ab dem ersten verteilten Build Pflicht)

- **Datenbank (drift, `lib/data/app_database.dart`)**
  - Nur additive Migrationen: neue Tabellen, neue Spalten *nullable oder mit
    Default*. Niemals Spalten/Tabellen löschen, umbenennen oder Typ ändern.
  - Jede Änderung: `schemaVersion` +1 und ein eigener Block `if (from < n)`
    in `onUpgrade` (strikt aufsteigend, alte Blöcke nie ändern).
  - Vor der Änderung das alte Schema als `test/migrations/v<alt>.sql`
    sichern (= `test/schema/current.sql`) und einen Migrationstest
    `v<alt> → v<neu>` mit Bestandsdaten ergänzen.
  - Enums (`intEnum`: `Importance`, `EventKind`, `SuggestionStatus`) nur
    am Ende erweitern — gespeichert wird der Index.
  - Danach: `dart run build_runner build --delete-conflicting-outputs` und
    `UPDATE_SCHEMA=1 flutter test test/schema_contract_test.dart`.
- **Auslosung (`lib/domain/suggestions.dart`)** — der Zufall ist je Tag fest
  (Datum + Salz der Installation). Änderungen an Gewichten verschieben
  künftige Vorschläge; bereits gezogene Tage stehen in `daily_suggestions`
  und bleiben.
- **Sicherungen (`packages/mai_backup_format`, `backup_service_io.dart`)** —
  ältere Sicherungen müssen wiederherstellbar bleiben (Restore migriert).
  Manifest nur erweitern; `app` bleibt `mai_stay_in_touch`.
- **Widget-/Uhr-Stand (`lib/home_widgets/widget_snapshot.dart`,
  `WearSync.kt`)** — JSON nur erweitern (`v` bleibt 1); native Seiten
  ignorieren Unbekanntes. Links `mairuf-widget://…` nur erweitern.
- **Warteschlange (`pending_actions.jsonl`)** — Format nur erweitern; wird
  auch von der Benachrichtigung (Hintergrund-Isolat) und dem Android-Widget
  (`TodayWidget.kt`) geschrieben.
- **Einstellungen/Benachrichtigungs-Payload** — tolerant lesen.

## Arbeitsweise

- Rechenlogik (Auslosung, Vorschau, Nummern) ist reines Dart in
  `lib/domain/` und vollständig getestet — neue Regeln immer mit Test.
- Strings: `lib/l10n/parts/<bereich>.<de|en>.json` (neue Schlüssel anhängen),
  dann `python3 tool/merge_arb.py && flutter gen-l10n`.
- Prüfen vor jedem Commit: `flutter analyze` (sauber) und `flutter test`
  (komplett grün); bei Änderungen an `packages/mai_backup_format` dort
  `dart analyze --fatal-infos && dart test`.
- Kein `dart format` auf ganze bestehende Dateien (erzeugt fremde Diffs).
- Release-Builds laufen mit R8: neue native Bibliotheken ggf. in
  `android/app/proguard-rules.pro` (anlegen und in `build.gradle.kts`
  eintragen) absichern.
- Kommentare im Code auf Deutsch.
