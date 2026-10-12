# Play Store – Ruf durch

Alles für den Store-Eintrag in der Play Console, nach Sprache getrennt.
Paket: `space.mai.mai_stay_in_touch`.

## Was gehört wohin

Play Console → *Wachstum → Store-Präsenz → Haupt-Store-Eintrag* (für
Englisch über *Übersetzungen verwalten* die Sprache „Englisch“ hinzufügen):

| Datei | Feld in der Play Console | Vorgabe |
|---|---|---|
| `de/title.txt`, `en/title.txt` | App-Name | max. 30 Zeichen |
| `de/short-description.txt`, `en/…` | Kurzbeschreibung | max. 80 Zeichen |
| `de/full-description.txt`, `en/…` | Vollständige Beschreibung | max. 4000 Zeichen |
| `icon-512.png` | App-Symbol | 512 × 512 PNG |
| `de/feature-graphic.png`, `en/…` | Vorstellungsgrafik | 1024 × 500 PNG |
| `de/screenshots/*.png`, `en/…` | Screenshots für Smartphones | 1080 × 1920, 7 Stück |
| `de/release-notes.txt`, `en/…` | Release → Versionshinweise | max. 500 Zeichen |
| `permissions.md` | Rückfragen zu Berechtigungen / Datensicherheit | – |

Die Screenshots in der Reihenfolge der Dateinamen hochladen (01 zuerst):
Heute · Kontakte · Einordnen · Kontaktseite · Verlauf · Einrichtung ·
Einstellungen.

Die Datenschutzerklärung entsteht separat (Projektordner
`play-store/`), hier liegt nur der Store-Eintrag.

## Hinweise

- **Wear OS:** Beschreibung und Versionshinweise erwähnen Kachel und
  Komplikation der Uhr-App. Wird die Wear-APK nicht mit veröffentlicht,
  den Punkt „Wear OS“ in beiden Beschreibungen streichen.
- **Datensicherheit:** Die App überträgt nichts vom Gerät (keine
  INTERNET-Berechtigung). Kontaktdaten werden nur lokal verarbeitet; einzig
  die eigene gekoppelte Uhr bekommt – falls die Uhr-App installiert ist –
  Name bzw. Initialen des Tagesvorschlags (keine Nummern).

## Wie die Bilder entstehen

Kein echtes Gerät, keine echten Kontakte:

- **Screenshots:** `test/store_screenshots_test.dart` startet die echte App
  (gleiche Seiten, Theme und Texte wie im Release) in der Flutter-
  Testumgebung mit einer In-Memory-Datenbank und frei erfundenen
  Beispielkontakten („Alex Beispiel“, „Sam Muster“ …, ausgedachte Nummern)
  und speichert jede Seite als PNG. Schrift ist Roboto aus dem Flutter-SDK.
  Statusleiste und Android-Navigationsleiste fehlen deshalb; Datumsangaben
  sind relativ zum Tag der Erzeugung. In der CI wird der Test übersprungen.

  ```bash
  STORE_SCREENSHOTS=1 flutter test test/store_screenshots_test.dart
  ```

- **Icon und Vorstellungsgrafik:** `tool/generate_store_graphics.py`, gleiches
  Motiv wie das App-Icon (`tool/generate_icons.py`).

  ```bash
  pip install cairosvg pillow && python3 tool/generate_store_graphics.py
  ```
