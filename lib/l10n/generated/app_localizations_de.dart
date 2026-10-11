// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Ruf durch';

  @override
  String get tabToday => 'Heute';

  @override
  String get tabContacts => 'Kontakte';

  @override
  String get tabHistory => 'Verlauf';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonContinue => 'Weiter';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonDone => 'Fertig';

  @override
  String get commonEdit => 'Bearbeiten';

  @override
  String get commonRetry => 'Erneut versuchen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonSearch => 'Suchen';

  @override
  String get commonSkip => 'Überspringen';

  @override
  String get commonToday => 'Heute';

  @override
  String get commonTomorrow => 'Morgen';

  @override
  String get commonUnderstood => 'Verstanden';

  @override
  String get commonUndo => 'Rückgängig';

  @override
  String get actionCall => 'Anrufen';

  @override
  String get actionWhatsApp => 'WhatsApp';

  @override
  String get actionLater => 'Heute nicht';

  @override
  String get actionAnother => 'Jemand anderen';

  @override
  String get actionNoted => 'Kontakt eintragen';

  @override
  String get importanceUnrated => 'Nicht eingeordnet';

  @override
  String get importanceNever => 'Nie vorschlagen';

  @override
  String get importanceRarely => 'Selten';

  @override
  String get importanceSometimes => 'Ab und zu';

  @override
  String get importanceOften => 'Oft';

  @override
  String get importanceVeryOften => 'Sehr wichtig';

  @override
  String get importanceHintNever => 'Taucht nie als Vorschlag auf';

  @override
  String get importanceHintRarely => 'Etwa alle drei Monate';

  @override
  String get importanceHintSometimes => 'Etwa einmal im Monat';

  @override
  String get importanceHintOften => 'Etwa alle zwei Wochen';

  @override
  String get importanceHintVeryOften => 'Etwa jede Woche';

  @override
  String get lastContactNever => 'Noch kein Kontakt eingetragen';

  @override
  String lastContactDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Letzter Kontakt vor $count Tagen',
      one: 'Letzter Kontakt gestern',
      zero: 'Kontakt heute',
    );
    return '$_temp0';
  }

  @override
  String get noNumber => 'Keine Telefonnummer hinterlegt';

  @override
  String get launchFailed => 'Konnte nicht geöffnet werden';

  @override
  String get whatsAppFailed =>
      'WhatsApp ließ sich nicht öffnen. Ist die Nummer mit Vorwahl gespeichert?';

  @override
  String get keyUnavailableTitle => 'Daten gerade nicht lesbar';

  @override
  String get keyUnavailableText =>
      'Der Schlüssel deiner verschlüsselten Daten ist gerade nicht erreichbar. Deine Daten sind sicher — versuch es gleich noch einmal oder starte das Gerät neu.';

  @override
  String get unreadableTitle => 'Alte Daten nicht lesbar';

  @override
  String get unreadableText =>
      'Deine bisherigen Daten ließen sich auf diesem Gerät nicht mehr entschlüsseln und wurden beiseitegelegt. Stell sie über eine Sicherung wieder her (Einstellungen → Daten).';

  @override
  String get contactsEmptyTitle => 'Noch keine Kontakte';

  @override
  String get contactsEmptyText =>
      'Hol deine Kontakte aus dem Adressbuch oder leg sie von Hand an.';

  @override
  String get contactsAdd => 'Kontakt hinzufügen';

  @override
  String get contactsImport => 'Aus dem Adressbuch importieren';

  @override
  String get contactsFilterAll => 'Alle';

  @override
  String get contactsNoMatch => 'Keine Treffer';

  @override
  String contactsPausedUntil(String date) {
    return 'Pausiert bis $date';
  }

  @override
  String get contactImportance => 'Wie oft möchtest du dich melden?';

  @override
  String get contactPause => 'Pausieren';

  @override
  String get contactPauseWeek => '1 Woche';

  @override
  String get contactPauseMonth => '1 Monat';

  @override
  String get contactPauseQuarter => '3 Monate';

  @override
  String get contactResume => 'Pause beenden';

  @override
  String get contactPauseText =>
      'Während der Pause gibt es keine Vorschläge für diesen Kontakt – z. B. im Urlaub.';

  @override
  String get contactWhatsApp => 'WhatsApp anbieten';

  @override
  String get contactNote => 'Notiz';

  @override
  String get contactNoteHint => 'z. B. wonach du fragen willst';

  @override
  String get contactHistory => 'Verlauf';

  @override
  String get contactNoHistory => 'Noch nichts eingetragen';

  @override
  String get contactNotedDone => 'Kontakt eingetragen';

  @override
  String get contactRemove => 'Aus der App entfernen';

  @override
  String contactRemoveTitle(String name) {
    return '$name entfernen?';
  }

  @override
  String get contactRemoveText =>
      'Der Kontakt wird nicht mehr vorgeschlagen und bleibt auch beim nächsten Import draußen. Dein Adressbuch bleibt unverändert.';

  @override
  String get contactName => 'Name';

  @override
  String get contactPhone => 'Telefonnummer';

  @override
  String get contactNameRequired => 'Bitte einen Namen eingeben';

  @override
  String get contactEdit => 'Kontakt bearbeiten';

  @override
  String contactStats(int accepted, int suggested) {
    return '$accepted von $suggested Vorschlägen angenommen';
  }

  @override
  String get historyEmptyTitle => 'Noch kein Verlauf';

  @override
  String get historyEmptyText =>
      'Hier landen Anrufe, Nachrichten und „Heute nicht“.';

  @override
  String get eventCalled => 'Angerufen';

  @override
  String get eventMessaged => 'WhatsApp geschrieben';

  @override
  String get eventDeclined => 'Heute nicht';

  @override
  String get eventNoted => 'Kontakt eingetragen';

  @override
  String get historyDeleted => 'Eintrag gelöscht';

  @override
  String get historyRemovedPerson => 'Entfernter Kontakt';

  @override
  String get statsWeek => 'Letzte 7 Tage';

  @override
  String get statsMonth => 'Letzte 30 Tage';

  @override
  String get statsPeople => 'Verschiedene Personen (30 Tage)';

  @override
  String get importTitle => 'Kontakte importieren';

  @override
  String get importIntro =>
      'Wähle, wen du übernehmen möchtest. Übernommen werden nur Name und Telefonnummer – verschlüsselt, nur auf diesem Gerät.';

  @override
  String get importSelectAll => 'Alle auswählen';

  @override
  String get importSelectNone => 'Keine auswählen';

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kontakte übernehmen',
      one: '1 Kontakt übernehmen',
      zero: 'Nichts ausgewählt',
    );
    return '$_temp0';
  }

  @override
  String get importAlready => 'Schon in der App';

  @override
  String get importDenied =>
      'Ohne Zugriff auf die Kontakte geht der Import nicht. Du kannst Kontakte aber auch von Hand hinzufügen.';

  @override
  String get importOpenSettings => 'Einstellungen öffnen';

  @override
  String get importNone => 'Keine Kontakte mit Telefonnummer gefunden.';

  @override
  String importResult(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kontakte übernommen',
      one: '1 Kontakt übernommen',
      zero: 'Nichts Neues übernommen',
    );
    return '$_temp0';
  }

  @override
  String get importUnsupported =>
      'Der Import aus dem Adressbuch ist hier nicht verfügbar.';

  @override
  String get onboardingWelcomeTitle => 'Bleib in Kontakt';

  @override
  String get onboardingWelcomeText =>
      'Jeden Tag schlägt Ruf durch dir eine Person vor, bei der du dich melden könntest – je wichtiger sie dir ist, desto öfter.';

  @override
  String get onboardingPrivacyText =>
      'Alles bleibt verschlüsselt auf deinem Handy. Kein Konto, keine Cloud, keine Internet-Berechtigung.';

  @override
  String get onboardingImportTitle => 'Kontakte holen';

  @override
  String get onboardingImportText =>
      'Übernimm Kontakte aus deinem Adressbuch und ordne sie danach ein. Du kannst auch später noch welche hinzufügen.';

  @override
  String onboardingImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kontakte in der App',
      one: '1 Kontakt in der App',
      zero: 'Noch keine Kontakte',
    );
    return '$_temp0';
  }

  @override
  String get onboardingNotifyTitle => 'Wann passt es dir?';

  @override
  String get onboardingNotifyText =>
      'Zu dieser Uhrzeit kommt der Vorschlag als Benachrichtigung – mit „Heute nicht“, „Anrufen“ und „WhatsApp“.';

  @override
  String get onboardingNotifyButton => 'Benachrichtigung erlauben';

  @override
  String get onboardingNotifyOn => 'Benachrichtigung ist an';

  @override
  String get onboardingStart => 'Los geht’s';

  @override
  String get onboardingLater => 'Später';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSuggestions => 'Vorschläge';

  @override
  String get settingsNotifications => 'Tägliche Benachrichtigung';

  @override
  String get settingsNotificationsText =>
      'Mit „Heute nicht“, „Anrufen“ und „WhatsApp“ direkt in der Benachrichtigung.';

  @override
  String get settingsTime => 'Uhrzeit';

  @override
  String get settingsDays => 'An diesen Tagen';

  @override
  String get settingsCountryCode => 'Ländervorwahl für WhatsApp';

  @override
  String get settingsCountryCodeText =>
      'Für Nummern ohne Vorwahl, z. B. 0171 …';

  @override
  String get settingsDiscreet => 'Diskret: nur Initialen';

  @override
  String get settingsDiscreetText =>
      'Widget und Uhr zeigen Initialen statt Namen.';

  @override
  String get settingsContacts => 'Kontakte';

  @override
  String get settingsData => 'Daten';

  @override
  String get settingsPrivacy => 'Datenschutz';

  @override
  String get settingsPrivacyText =>
      'Alle Daten bleiben verschlüsselt auf diesem Gerät. Kein Konto, keine Cloud, keine Internet-Berechtigung, keine Analyse. Aus dem Adressbuch übernimmt die App nur Name und Nummer, und nur auf deinen Wunsch. Anrufe erkennt sie nicht selbst – gezählt wird, was du in der App antippst oder einträgst.';

  @override
  String get backupIntro =>
      'Sicherung: alle Daten verschlüsselt in einer Datei – für ein neues Handy oder zur Vorsorge. Ohne Passwort ist sie nicht lesbar.';

  @override
  String get backupCreate => 'Sichern';

  @override
  String get backupRestore => 'Wiederherstellen';

  @override
  String get backupCreated => 'Sicherung erstellt';

  @override
  String get backupFailed => 'Das hat leider nicht geklappt.';

  @override
  String get backupPassphrase => 'Passwort';

  @override
  String get backupPassphraseCreateHint =>
      'Wähle ein Passwort für die Sicherung. Ohne dieses Passwort lässt sie sich nicht wiederherstellen – gut merken!';

  @override
  String get backupPassphraseRestoreHint => 'Passwort der Sicherung';

  @override
  String get backupPassphraseRepeat => 'Passwort wiederholen';

  @override
  String get backupPassphraseMismatch => 'Die Passwörter stimmen nicht überein';

  @override
  String get backupPassphraseTooShort => 'Mindestens 8 Zeichen';

  @override
  String get backupPick => 'Sicherung auswählen';

  @override
  String get backupReplace => 'Ersetzen';

  @override
  String get backupRestoreConfirmTitle => 'Alle Daten ersetzen?';

  @override
  String get backupRestoreConfirmText =>
      'Alle Kontakte, der Verlauf und die Einstellungen auf diesem Gerät werden durch die Sicherung ersetzt.';

  @override
  String backupRestored(String date) {
    return 'Sicherung vom $date wiederhergestellt';
  }

  @override
  String get backupShareSubject => 'Ruf-durch-Sicherung';

  @override
  String get backupTooNew =>
      'Diese Sicherung stammt aus einer neueren App-Version. Bitte aktualisiere die App.';

  @override
  String get backupUnsupported => 'Sicherungen sind hier nicht verfügbar.';

  @override
  String get backupWrongApp => 'Das ist keine Sicherung von Ruf durch.';

  @override
  String get csvPeople => 'Kontakte als Tabelle teilen (CSV)';

  @override
  String get csvHistory => 'Verlauf als Tabelle teilen (CSV)';

  @override
  String get csvShareSubject => 'Ruf durch – Tabelle';

  @override
  String get csvName => 'Name';

  @override
  String get csvPhone => 'Telefon';

  @override
  String get csvImportance => 'Wichtigkeit';

  @override
  String get csvLastContact => 'Letzter Kontakt';

  @override
  String get csvPausedUntil => 'Pausiert bis';

  @override
  String get csvNote => 'Notiz';

  @override
  String get csvDate => 'Datum';

  @override
  String get csvKind => 'Art';

  @override
  String notificationTitle(String name) {
    return 'Ruf doch mal $name an 📞';
  }

  @override
  String get notificationBodyNew => 'Heute wäre ein guter Tag dafür.';

  @override
  String notificationBodySince(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Euer letzter Kontakt ist $count Tage her.',
      one: 'Euer letzter Kontakt war gestern.',
    );
    return '$_temp0';
  }

  @override
  String get notificationChannel => 'Tagesvorschlag';

  @override
  String get notificationChannelDescription =>
      'Ein Kontakt pro Tag, bei dem du dich melden könntest.';

  @override
  String get todaySuggestion => 'Heute melden bei';

  @override
  String get todayDone => 'Erledigt – schön, dass ihr Kontakt hattet!';

  @override
  String get todayDeclined =>
      'Heute nicht – morgen gibt es einen neuen Vorschlag.';

  @override
  String get todayFree => 'Heute ist kein Vorschlagstag.';

  @override
  String get todayFreeAction => 'Trotzdem jemanden vorschlagen';

  @override
  String get todayEmptyTitle => 'Noch niemand zum Vorschlagen';

  @override
  String get todayEmptyText =>
      'Importiere deine Kontakte und ordne ein, wie wichtig sie dir sind. Dann gibt es jeden Tag einen Vorschlag.';

  @override
  String get todayNobody =>
      'Gerade ist niemand fällig. Schön, dass du so gut in Kontakt bist!';

  @override
  String get todayImport => 'Kontakte importieren';

  @override
  String todayUnrated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kontakte sind noch nicht eingeordnet',
      one: '1 Kontakt ist noch nicht eingeordnet',
    );
    return '$_temp0';
  }

  @override
  String get todaySort => 'Einordnen';

  @override
  String todayWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kontakte in den letzten 7 Tagen',
      one: '1 Kontakt in den letzten 7 Tagen',
      zero: 'In den letzten 7 Tagen noch kein Kontakt',
    );
    return '$_temp0';
  }

  @override
  String get upcomingTitle => 'Demnächst';

  @override
  String get upcomingHint =>
      'Vorschau – sie ändert sich mit jedem Anruf und jedem „Heute nicht“.';

  @override
  String get upcomingEmpty => 'Keine weiteren Vorschläge';

  @override
  String get todayAnotherNone => 'Gerade ist niemand anderes fällig.';

  @override
  String get triageTitle => 'Einordnen';

  @override
  String triageProgress(int done, int total) {
    return '$done von $total';
  }

  @override
  String get triageQuestion =>
      'Wie oft möchtest du dich bei dieser Person melden?';

  @override
  String get triageDoneTitle => 'Alles eingeordnet';

  @override
  String get triageDoneText =>
      'Ab jetzt gibt es jeden Tag einen Vorschlag. Die Einordnung kannst du jederzeit beim Kontakt ändern.';

  @override
  String get triageEmpty => 'Alle Kontakte sind eingeordnet.';

  @override
  String triageSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count übersprungen – kommen später wieder',
      one: '1 übersprungen – kommt später wieder',
    );
    return '$_temp0';
  }

  @override
  String get widgetTitle => 'Heute anrufen';

  @override
  String get widgetDone => 'Erledigt';

  @override
  String get widgetDeclined => 'Heute nicht';

  @override
  String get widgetFree => 'Heute frei';

  @override
  String get widgetEmpty => 'Öffne Ruf durch zum Einordnen';
}
