# Ruf durch (mai-stay-in-touch)

Jeden Tag ein Mensch, den du anrufen könntest — **lokal, ohne Konto**, auf
Deutsch und Englisch. Gleiche Prinzipien und gleicher Stack wie die anderen
Mai-Apps (Haushalt, Budget, Ärzte, Fitness).

> Erste Version (v0.1). Konzept und Roadmap: [`project-docs/KONZEPT.md`](project-docs/KONZEPT.md)

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

### Release für den Play Store

Store-Texte, Icon und Screenshots: [`store/android/`](store/android/README.md).

Auf `main` baut die CI zusätzlich **signierte App Bundles**
(`mai-stay-in-touch.aab` und `mai-stay-in-touch-wear.aab`, Artefakt
`mai-stay-in-touch-aab`), sobald diese vier Repository-Secrets gesetzt sind
(*Settings → Secrets and variables → Actions → New repository secret*):

| Secret | Inhalt |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Upload-Keystore (`.jks`) als Base64 |
| `ANDROID_KEYSTORE_PASSWORD` | Passwort des Keystores |
| `ANDROID_KEY_ALIAS` | Alias des Schlüssels, z. B. `upload` |
| `ANDROID_KEY_PASSWORD` | Passwort des Schlüssels |

Ohne Secrets läuft die CI wie bisher (APKs mit Debug-Schlüssel).

**Upload-Schlüssel einmalig erzeugen** (außerhalb des Repos aufbewahren
und sicher sichern; mit Play-App-Signatur ist es nur der Upload-Schlüssel,
Google verwaltet den eigentlichen App-Signaturschlüssel):

```bash
keytool -genkeypair -v -keystore ~/keys/ruf-durch-upload.jks \
  -keyalg RSA -keysize 4096 -validity 10000 -alias upload

# Inhalt für ANDROID_KEYSTORE_BASE64
base64 -w0 ~/keys/ruf-durch-upload.jks        # Linux
base64 -i ~/keys/ruf-durch-upload.jks | pbcopy  # macOS (in die Zwischenablage)
```

**Lokal signiert bauen:** `android/key.properties` anlegen (steht in
`.gitignore`, nie committen); `storeFile` ist relativ zu `android/app`:

```properties
storeFile=/home/ich/keys/ruf-durch-upload.jks
storePassword=…
keyAlias=upload
keyPassword=…
```

```bash
flutter build appbundle --release
(cd android && ./gradlew :wear:bundleRelease)
```

Telefon- und Uhr-App teilen die `applicationId` und werden in derselben
Play-App veröffentlicht (Uhr unter *Formfaktor Wear OS*). Die Uhr-App
bekommt deshalb den Versionscode `100000 + Build-Nummer`, damit beide
eindeutig sind.

### iOS / Apple Watch

Bundle-IDs `space.mai.maiStayInTouch` (+ `.watchkitapp`,
`.watchkitapp.widgets`). Für signierte Builds muss in den App-IDs der Uhr
die App-Gruppe `group.space.mai.maiStayInTouch` aktiviert sein (Stand für
die Komplikation).
