# Ruf durch (mai-stay-in-touch)

Jeden Tag ein Mensch, den du anrufen könntest — **lokal, ohne Konto**, auf
Deutsch und Englisch. Gleiche Prinzipien und gleicher Stack wie die anderen
Mai-Apps (Haushalt, Budget, Ärzte, Fitness).

> Erste Version (v0.1). Konzept und Roadmap: [`docs/KONZEPT.md`](docs/KONZEPT.md)

## Features

- **Kontakte übernehmen:** Import aus dem Adressbuch (Name und Nummern, nur
  auf Wunsch, nur lesend), Abgleich bei erneutem Import; Kontakte auch von
  Hand anlegen.
- **Einordnen:** pro Person ein Tipp — „Sehr wichtig“ (etwa wöchentlich), „Oft“
  (alle zwei Wochen), „Ab und zu“ (monatlich), „Selten“ (vierteljährlich)
  oder „Nie vorschlagen“. Pausieren und Archivieren möglich.
- **Tägliche Auslosung:** gewichteter Zufall nach Wichtigkeit und
  Überfälligkeit; wer gerade dran war oder kürzlich gesprochen wurde, kommt
  nicht sofort wieder. Fest je Tag — App, Widget und Benachrichtigung zeigen
  denselben Vorschlag.
- **Lernt mit:** „Heute nicht“ senkt das Gewicht bis zum nächsten Kontakt,
  wer oft angenommen wird, kommt etwas häufiger. Alles aus dem lokalen
  Verlauf.
- **Benachrichtigung** zur gewählten Uhrzeit an den gewählten Wochentagen
  mit **„Heute nicht“**, **„Anrufen“** und **„WhatsApp“** (`wa.me`-Link).
  „Heute nicht“ wirkt auch ohne geöffnete App.
- **Vorschau:** die nächsten zwei Wochen, „Jemand anderen“ und „Trotzdem
  jemanden vorschlagen“, Kontakt von Hand eintragen.
- **Verlauf** mit Wochen-/Monatsstatistik; Einträge per Wischen löschen.
- **Widget „Heute anrufen“:** frei skalierbar — von 1×1 (Name) über die
  breite Zeile mit Anrufen-Knopf bis zur Karte mit allen drei Knöpfen und
  den nächsten Vorschlägen.
- **Wear OS:** Begleit-App mit Kachel „Heute anrufen“ und Komplikation.
  Eigenes APK `mai-stay-in-touch-wear.apk`, gleicher Schlüssel wie die
  Telefon-App.
- **iOS** (vorbereitet) mit **Apple-Watch-App** und Komplikation.
- **Diskreter Modus:** Widget und Uhr zeigen nur Initialen.
- **Daten:** verschlüsselte Sicherung `.mairuf` (Export/Import), Kontakte
  und Verlauf als CSV.

## Datenschutz

- Alle Daten nur auf dem Gerät, Datenbank verschlüsselt (SQLite3 Multiple
  Ciphers), Schlüssel im Android Keystore bzw. iOS-Schlüsselbund.
- Keine INTERNET-Berechtigung, kein Android-Backup, keine Analytics. Die App
  telefoniert nicht selbst (keine Telefon-Berechtigung): Sie öffnet die
  Wähl-App bzw. WhatsApp mit der Nummer.
- Uhr: Nur wenn auf einer gekoppelten Uhr die Uhr-App installiert ist, geht
  ein knapper Stand (Name bzw. Initialen, Tag, „zuletzt vor …“ — keine
  Nummern) an die Uhr. Ohne Uhr-App verlässt nichts das Telefon.
- Weitergabe nur über die vom Nutzer erstellte, passwortgeschützte Sicherung
  (AES-256-GCM / PBKDF2, `packages/mai_backup_format`).

## Entwicklung

```bash
flutter pub get
flutter analyze
flutter test
(cd packages/mai_backup_format && dart test)

# nach Schema-Änderungen
dart run build_runner build --delete-conflicting-outputs
UPDATE_SCHEMA=1 flutter test test/schema_contract_test.dart

# nach Text-Änderungen
python3 tool/merge_arb.py && flutter gen-l10n

# App-Icon neu erzeugen (Android, iOS, Apple Watch)
pip install cairosvg pillow && python3 tool/generate_icons.py

flutter run -d android
flutter build apk --release
(cd android && ./gradlew :wear:assembleRelease)
```

Die CI baut bei jedem Push die Release-APK (`mai-stay-in-touch.apk`), die
Wear-OS-APK (`mai-stay-in-touch-wear.apk`) und die iOS-App ohne Signatur.

### iOS / Apple Watch

Bundle-IDs `space.mai.maiStayInTouch` (+ `.watchkitapp`,
`.watchkitapp.widgets`). Für signierte Builds muss in den App-IDs der Uhr
die App-Gruppe `group.space.mai.maiStayInTouch` aktiviert sein (Stand für
die Komplikation).
