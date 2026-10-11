# Ruf durch — Konzept

## Idee

Kontakt halten scheitert selten am Wollen, sondern am „Wen eigentlich, und
wann?“. Ruf durch nimmt diese Entscheidung ab: Einmal alle Kontakte
übernehmen und nach Wichtigkeit einordnen — danach schlägt die App jeden Tag
genau eine Person vor. Eine Benachrichtigung, drei Antworten: **Heute
nicht**, **Anrufen**, **WhatsApp**.

## Grundsätze

- **Lokal, ohne Konto, ohne Server.** Keine INTERNET-Berechtigung. Die
  Benachrichtigung ist eine lokal geplante Mitteilung, kein Push-Dienst.
- **Ein Vorschlag pro Tag**, nicht eine To-do-Liste. Kein schlechtes
  Gewissen, keine roten Zähler.
- **Die App lernt aus dem eigenen Verlauf**, nicht aus Daten anderer.

## Wichtigkeit

| Stufe      | Zielabstand | Gewichtung |
|------------|-------------|------------|
| Sehr wichtig | 7 Tage    | 1,5        |
| Oft        | 14 Tage     | 1,25       |
| Ab und zu  | 30 Tage     | 1,0        |
| Selten     | 90 Tage     | 0,8        |
| Nie vorschlagen | —      | wird nie vorgeschlagen |

Noch nicht eingeordnete Kontakte werden nicht vorgeschlagen.

## Auslosung (`lib/domain/suggestions.dart`)

Gewicht je Kontakt und Tag:

`Gewichtung × Fälligkeit × Ablehnungs-Dämpfung × Ansprechbarkeit`

- **Fälligkeit:** Tage seit dem letzten Kontakt / Zielabstand. Unter 1
  quadratisch (früh kaum), darüber mit Exponent 1,5 bis zum Vierfachen.
  Nie kontaktiert = 1,5-fach fällig.
- **Ausgeschlossen:** pausiert; in den letzten 3 Tagen vorgeschlagen;
  Kontakt vor weniger als einem Viertel des Zielabstands.
- **„Heute nicht“:** je Ablehnung seit dem letzten Kontakt × 0,6
  (mindestens 0,15).
- **Ansprechbarkeit:** Annahmequote mit Vorwissen ½ → Faktor 0,6 … 1,4.

Der Zufall ist je Tag fest (Datum + Salz der Installation): App, Widget,
Uhr und Benachrichtigung zeigen denselben Vorschlag. Die **Vorschau** spielt
die nächsten 14 Tage durch und nimmt dabei an, dass jeder Vorschlag
angenommen wird. „Jemand anderen“ und „Trotzdem jemanden vorschlagen“ ziehen
gelockert (auch kürzlich Vorgeschlagene).

## Daten

- `people`: Name, Nummer, WhatsApp ja/nein, Wichtigkeit, Pause, Notiz,
  Archiv, Verknüpfung zum Adressbuch-Eintrag.
- `contact_events`: Anruf, Nachricht, „Heute nicht“, eingetragen.
- `daily_suggestions`: der Vorschlag je Tag mit Status.

Reaktionen ohne geöffnete App (Benachrichtigung, Widget) landen in einer
Warteschlange (`pending_actions.jsonl`, nur Tag, interne ID, Aktion), die
die App beim Öffnen übernimmt.

## Oberflächen

- **Heute:** Vorschlag mit Anrufen / WhatsApp / Heute nicht, Vorschau.
- **Kontakte:** Suche, Filter nach Stufe, Einordnen, Import, Detail mit
  Verlauf.
- **Verlauf:** Statistik und Liste.
- **Widget „Heute anrufen“**, **Wear-OS-Kachel und -Komplikation**,
  **Apple-Watch-App und -Komplikation**.

## Roadmap

- iOS-Startbildschirm-Widget (WidgetKit) mit App-Gruppe.
- Geburtstage aus dem Adressbuch als Anlass.
- Gruppen („Familie“, „Studium“) und Wochenziel.
- Signal/Telegram als weitere Aktion.
