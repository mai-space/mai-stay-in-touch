# Begründung der Berechtigungen

Für Rückfragen im Review, die Datensicherheits-Angaben oder ein
Freitextfeld „Warum braucht die App diese Berechtigung?“. Jeweils
Deutsch und Englisch zum Kopieren.

## READ_CONTACTS (Kontakte lesen)

**Deutsch**

> Ruf durch schlägt jeden Tag eine Person vor, bei der sich der Nutzer
> melden könnte. Damit Nutzer ihre Kontakte nicht von Hand abtippen müssen,
> können sie auf eigenen Wunsch („Kontakte importieren“) Kontakte aus dem
> Adressbuch übernehmen. Die App liest dabei nur Name und Telefonnummer,
> der Nutzer wählt vor der Übernahme aus, wen er übernehmen möchte. Die
> Daten werden ausschließlich verschlüsselt auf dem Gerät gespeichert; die
> App hat keine Internet-Berechtigung und überträgt keine Kontaktdaten an
> Server oder Dritte. Ohne die Berechtigung bleibt die App voll nutzbar,
> Kontakte lassen sich dann von Hand anlegen.

**English**

> Ruf durch suggests one person per day whom the user could get in touch
> with. So that users don’t have to type their contacts by hand, they can
> choose to import contacts from their address book (“Import contacts”).
> The app reads only name and phone number, and the user selects who to
> import before anything is saved. The data is stored only on the device,
> encrypted; the app has no internet permission and never sends contact
> data to any server or third party. Without the permission the app stays
> fully usable, and contacts can be added by hand.

## Weitere Berechtigungen (falls gefragt)

- **POST_NOTIFICATIONS** – tägliche, lokal geplante Benachrichtigung mit
  dem Vorschlag des Tages. / Daily, locally scheduled notification with
  the day’s suggestion.
- **RECEIVE_BOOT_COMPLETED** – die geplante Benachrichtigung nach einem
  Neustart wiederherstellen. / Restore the scheduled notification after a
  reboot.
- **Keine** Telefon-, Anruflisten-, SMS- oder Internet-Berechtigung:
  Anrufen öffnet die Wähl-App (`ACTION_DIAL`), WhatsApp über einen
  `wa.me`-Link.
