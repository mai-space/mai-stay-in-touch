import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'Ruf durch'**
  String get appTitle;

  /// No description provided for @tabToday.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get tabToday;

  /// No description provided for @tabContacts.
  ///
  /// In de, this message translates to:
  /// **'Kontakte'**
  String get tabContacts;

  /// No description provided for @tabHistory.
  ///
  /// In de, this message translates to:
  /// **'Verlauf'**
  String get tabHistory;

  /// No description provided for @commonCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get commonClose;

  /// No description provided for @commonContinue.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get commonContinue;

  /// No description provided for @commonDelete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get commonDelete;

  /// No description provided for @commonDone.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get commonDone;

  /// No description provided for @commonEdit.
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get commonEdit;

  /// No description provided for @commonRetry.
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get commonRetry;

  /// No description provided for @commonSave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get commonSave;

  /// No description provided for @commonSearch.
  ///
  /// In de, this message translates to:
  /// **'Suchen'**
  String get commonSearch;

  /// No description provided for @commonSkip.
  ///
  /// In de, this message translates to:
  /// **'Überspringen'**
  String get commonSkip;

  /// No description provided for @commonToday.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get commonToday;

  /// No description provided for @commonTomorrow.
  ///
  /// In de, this message translates to:
  /// **'Morgen'**
  String get commonTomorrow;

  /// No description provided for @commonUnderstood.
  ///
  /// In de, this message translates to:
  /// **'Verstanden'**
  String get commonUnderstood;

  /// No description provided for @commonUndo.
  ///
  /// In de, this message translates to:
  /// **'Rückgängig'**
  String get commonUndo;

  /// No description provided for @actionCall.
  ///
  /// In de, this message translates to:
  /// **'Anrufen'**
  String get actionCall;

  /// No description provided for @actionWhatsApp.
  ///
  /// In de, this message translates to:
  /// **'WhatsApp'**
  String get actionWhatsApp;

  /// No description provided for @actionLater.
  ///
  /// In de, this message translates to:
  /// **'Heute nicht'**
  String get actionLater;

  /// No description provided for @actionAnother.
  ///
  /// In de, this message translates to:
  /// **'Jemand anderen'**
  String get actionAnother;

  /// No description provided for @actionNoted.
  ///
  /// In de, this message translates to:
  /// **'Kontakt eintragen'**
  String get actionNoted;

  /// No description provided for @importanceUnrated.
  ///
  /// In de, this message translates to:
  /// **'Nicht eingeordnet'**
  String get importanceUnrated;

  /// No description provided for @importanceNever.
  ///
  /// In de, this message translates to:
  /// **'Nie vorschlagen'**
  String get importanceNever;

  /// No description provided for @importanceRarely.
  ///
  /// In de, this message translates to:
  /// **'Selten'**
  String get importanceRarely;

  /// No description provided for @importanceSometimes.
  ///
  /// In de, this message translates to:
  /// **'Ab und zu'**
  String get importanceSometimes;

  /// No description provided for @importanceOften.
  ///
  /// In de, this message translates to:
  /// **'Oft'**
  String get importanceOften;

  /// No description provided for @importanceVeryOften.
  ///
  /// In de, this message translates to:
  /// **'Sehr wichtig'**
  String get importanceVeryOften;

  /// No description provided for @importanceHintNever.
  ///
  /// In de, this message translates to:
  /// **'Taucht nie als Vorschlag auf'**
  String get importanceHintNever;

  /// No description provided for @importanceHintRarely.
  ///
  /// In de, this message translates to:
  /// **'Etwa alle drei Monate'**
  String get importanceHintRarely;

  /// No description provided for @importanceHintSometimes.
  ///
  /// In de, this message translates to:
  /// **'Etwa einmal im Monat'**
  String get importanceHintSometimes;

  /// No description provided for @importanceHintOften.
  ///
  /// In de, this message translates to:
  /// **'Etwa alle zwei Wochen'**
  String get importanceHintOften;

  /// No description provided for @importanceHintVeryOften.
  ///
  /// In de, this message translates to:
  /// **'Etwa jede Woche'**
  String get importanceHintVeryOften;

  /// No description provided for @lastContactNever.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Kontakt eingetragen'**
  String get lastContactNever;

  /// No description provided for @lastContactDays.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Kontakt heute} =1{Letzter Kontakt gestern} other{Letzter Kontakt vor {count} Tagen}}'**
  String lastContactDays(int count);

  /// No description provided for @noNumber.
  ///
  /// In de, this message translates to:
  /// **'Keine Telefonnummer hinterlegt'**
  String get noNumber;

  /// No description provided for @launchFailed.
  ///
  /// In de, this message translates to:
  /// **'Konnte nicht geöffnet werden'**
  String get launchFailed;

  /// No description provided for @whatsAppFailed.
  ///
  /// In de, this message translates to:
  /// **'WhatsApp ließ sich nicht öffnen. Ist die Nummer mit Vorwahl gespeichert?'**
  String get whatsAppFailed;

  /// No description provided for @keyUnavailableTitle.
  ///
  /// In de, this message translates to:
  /// **'Daten gerade nicht lesbar'**
  String get keyUnavailableTitle;

  /// No description provided for @keyUnavailableText.
  ///
  /// In de, this message translates to:
  /// **'Der Schlüssel deiner verschlüsselten Daten ist gerade nicht erreichbar. Deine Daten sind sicher — versuch es gleich noch einmal oder starte das Gerät neu.'**
  String get keyUnavailableText;

  /// No description provided for @unreadableTitle.
  ///
  /// In de, this message translates to:
  /// **'Alte Daten nicht lesbar'**
  String get unreadableTitle;

  /// No description provided for @unreadableText.
  ///
  /// In de, this message translates to:
  /// **'Deine bisherigen Daten ließen sich auf diesem Gerät nicht mehr entschlüsseln und wurden beiseitegelegt. Stell sie über eine Sicherung wieder her (Einstellungen → Daten).'**
  String get unreadableText;

  /// No description provided for @contactsEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Kontakte'**
  String get contactsEmptyTitle;

  /// No description provided for @contactsEmptyText.
  ///
  /// In de, this message translates to:
  /// **'Hol deine Kontakte aus dem Adressbuch oder leg sie von Hand an.'**
  String get contactsEmptyText;

  /// No description provided for @contactsAdd.
  ///
  /// In de, this message translates to:
  /// **'Kontakt hinzufügen'**
  String get contactsAdd;

  /// No description provided for @contactsImport.
  ///
  /// In de, this message translates to:
  /// **'Aus dem Adressbuch importieren'**
  String get contactsImport;

  /// No description provided for @contactsFilterAll.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get contactsFilterAll;

  /// No description provided for @contactsNoMatch.
  ///
  /// In de, this message translates to:
  /// **'Keine Treffer'**
  String get contactsNoMatch;

  /// No description provided for @contactsPausedUntil.
  ///
  /// In de, this message translates to:
  /// **'Pausiert bis {date}'**
  String contactsPausedUntil(String date);

  /// No description provided for @contactImportance.
  ///
  /// In de, this message translates to:
  /// **'Wie oft möchtest du dich melden?'**
  String get contactImportance;

  /// No description provided for @contactPause.
  ///
  /// In de, this message translates to:
  /// **'Pausieren'**
  String get contactPause;

  /// No description provided for @contactPauseWeek.
  ///
  /// In de, this message translates to:
  /// **'1 Woche'**
  String get contactPauseWeek;

  /// No description provided for @contactPauseMonth.
  ///
  /// In de, this message translates to:
  /// **'1 Monat'**
  String get contactPauseMonth;

  /// No description provided for @contactPauseQuarter.
  ///
  /// In de, this message translates to:
  /// **'3 Monate'**
  String get contactPauseQuarter;

  /// No description provided for @contactResume.
  ///
  /// In de, this message translates to:
  /// **'Pause beenden'**
  String get contactResume;

  /// No description provided for @contactPauseText.
  ///
  /// In de, this message translates to:
  /// **'Während der Pause gibt es keine Vorschläge für diesen Kontakt – z. B. im Urlaub.'**
  String get contactPauseText;

  /// No description provided for @contactWhatsApp.
  ///
  /// In de, this message translates to:
  /// **'WhatsApp anbieten'**
  String get contactWhatsApp;

  /// No description provided for @contactNote.
  ///
  /// In de, this message translates to:
  /// **'Notiz'**
  String get contactNote;

  /// No description provided for @contactNoteHint.
  ///
  /// In de, this message translates to:
  /// **'z. B. wonach du fragen willst'**
  String get contactNoteHint;

  /// No description provided for @contactHistory.
  ///
  /// In de, this message translates to:
  /// **'Verlauf'**
  String get contactHistory;

  /// No description provided for @contactNoHistory.
  ///
  /// In de, this message translates to:
  /// **'Noch nichts eingetragen'**
  String get contactNoHistory;

  /// No description provided for @contactNotedDone.
  ///
  /// In de, this message translates to:
  /// **'Kontakt eingetragen'**
  String get contactNotedDone;

  /// No description provided for @contactRemove.
  ///
  /// In de, this message translates to:
  /// **'Aus der App entfernen'**
  String get contactRemove;

  /// No description provided for @contactRemoveTitle.
  ///
  /// In de, this message translates to:
  /// **'{name} entfernen?'**
  String contactRemoveTitle(String name);

  /// No description provided for @contactRemoveText.
  ///
  /// In de, this message translates to:
  /// **'Der Kontakt wird nicht mehr vorgeschlagen und bleibt auch beim nächsten Import draußen. Dein Adressbuch bleibt unverändert.'**
  String get contactRemoveText;

  /// No description provided for @contactName.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get contactName;

  /// No description provided for @contactPhone.
  ///
  /// In de, this message translates to:
  /// **'Telefonnummer'**
  String get contactPhone;

  /// No description provided for @contactNameRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte einen Namen eingeben'**
  String get contactNameRequired;

  /// No description provided for @contactEdit.
  ///
  /// In de, this message translates to:
  /// **'Kontakt bearbeiten'**
  String get contactEdit;

  /// No description provided for @contactStats.
  ///
  /// In de, this message translates to:
  /// **'{accepted} von {suggested} Vorschlägen angenommen'**
  String contactStats(int accepted, int suggested);

  /// No description provided for @historyEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Verlauf'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyText.
  ///
  /// In de, this message translates to:
  /// **'Hier landen Anrufe, Nachrichten und „Heute nicht“.'**
  String get historyEmptyText;

  /// No description provided for @eventCalled.
  ///
  /// In de, this message translates to:
  /// **'Angerufen'**
  String get eventCalled;

  /// No description provided for @eventMessaged.
  ///
  /// In de, this message translates to:
  /// **'WhatsApp geschrieben'**
  String get eventMessaged;

  /// No description provided for @eventDeclined.
  ///
  /// In de, this message translates to:
  /// **'Heute nicht'**
  String get eventDeclined;

  /// No description provided for @eventNoted.
  ///
  /// In de, this message translates to:
  /// **'Kontakt eingetragen'**
  String get eventNoted;

  /// No description provided for @historyDeleted.
  ///
  /// In de, this message translates to:
  /// **'Eintrag gelöscht'**
  String get historyDeleted;

  /// No description provided for @historyRemovedPerson.
  ///
  /// In de, this message translates to:
  /// **'Entfernter Kontakt'**
  String get historyRemovedPerson;

  /// No description provided for @statsWeek.
  ///
  /// In de, this message translates to:
  /// **'Letzte 7 Tage'**
  String get statsWeek;

  /// No description provided for @statsMonth.
  ///
  /// In de, this message translates to:
  /// **'Letzte 30 Tage'**
  String get statsMonth;

  /// No description provided for @statsPeople.
  ///
  /// In de, this message translates to:
  /// **'Verschiedene Personen (30 Tage)'**
  String get statsPeople;

  /// No description provided for @importTitle.
  ///
  /// In de, this message translates to:
  /// **'Kontakte importieren'**
  String get importTitle;

  /// No description provided for @importIntro.
  ///
  /// In de, this message translates to:
  /// **'Wähle, wen du übernehmen möchtest. Übernommen werden nur Name und Telefonnummer – verschlüsselt, nur auf diesem Gerät.'**
  String get importIntro;

  /// No description provided for @importSelectAll.
  ///
  /// In de, this message translates to:
  /// **'Alle auswählen'**
  String get importSelectAll;

  /// No description provided for @importSelectNone.
  ///
  /// In de, this message translates to:
  /// **'Keine auswählen'**
  String get importSelectNone;

  /// No description provided for @importButton.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Nichts ausgewählt} =1{1 Kontakt übernehmen} other{{count} Kontakte übernehmen}}'**
  String importButton(int count);

  /// No description provided for @importAlready.
  ///
  /// In de, this message translates to:
  /// **'Schon in der App'**
  String get importAlready;

  /// No description provided for @importDenied.
  ///
  /// In de, this message translates to:
  /// **'Ohne Zugriff auf die Kontakte geht der Import nicht. Du kannst Kontakte aber auch von Hand hinzufügen.'**
  String get importDenied;

  /// No description provided for @importOpenSettings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen öffnen'**
  String get importOpenSettings;

  /// No description provided for @importNone.
  ///
  /// In de, this message translates to:
  /// **'Keine Kontakte mit Telefonnummer gefunden.'**
  String get importNone;

  /// No description provided for @importResult.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Nichts Neues übernommen} =1{1 Kontakt übernommen} other{{count} Kontakte übernommen}}'**
  String importResult(int count);

  /// No description provided for @importUnsupported.
  ///
  /// In de, this message translates to:
  /// **'Der Import aus dem Adressbuch ist hier nicht verfügbar.'**
  String get importUnsupported;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In de, this message translates to:
  /// **'Bleib in Kontakt'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeText.
  ///
  /// In de, this message translates to:
  /// **'Jeden Tag schlägt Ruf durch dir eine Person vor, bei der du dich melden könntest – je wichtiger sie dir ist, desto öfter.'**
  String get onboardingWelcomeText;

  /// No description provided for @onboardingPrivacyText.
  ///
  /// In de, this message translates to:
  /// **'Alles bleibt verschlüsselt auf deinem Handy. Kein Konto, keine Cloud, keine Internet-Berechtigung.'**
  String get onboardingPrivacyText;

  /// No description provided for @onboardingImportTitle.
  ///
  /// In de, this message translates to:
  /// **'Kontakte holen'**
  String get onboardingImportTitle;

  /// No description provided for @onboardingImportText.
  ///
  /// In de, this message translates to:
  /// **'Übernimm Kontakte aus deinem Adressbuch und ordne sie danach ein. Du kannst auch später noch welche hinzufügen.'**
  String get onboardingImportText;

  /// No description provided for @onboardingImported.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Noch keine Kontakte} =1{1 Kontakt in der App} other{{count} Kontakte in der App}}'**
  String onboardingImported(int count);

  /// No description provided for @onboardingNotifyTitle.
  ///
  /// In de, this message translates to:
  /// **'Wann passt es dir?'**
  String get onboardingNotifyTitle;

  /// No description provided for @onboardingNotifyText.
  ///
  /// In de, this message translates to:
  /// **'Zu dieser Uhrzeit kommt der Vorschlag als Benachrichtigung – mit „Heute nicht“, „Anrufen“ und „WhatsApp“.'**
  String get onboardingNotifyText;

  /// No description provided for @onboardingNotifyButton.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigung erlauben'**
  String get onboardingNotifyButton;

  /// No description provided for @onboardingNotifyOn.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigung ist an'**
  String get onboardingNotifyOn;

  /// No description provided for @onboardingStart.
  ///
  /// In de, this message translates to:
  /// **'Los geht’s'**
  String get onboardingStart;

  /// No description provided for @onboardingLater.
  ///
  /// In de, this message translates to:
  /// **'Später'**
  String get onboardingLater;

  /// No description provided for @settingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settingsTitle;

  /// No description provided for @settingsSuggestions.
  ///
  /// In de, this message translates to:
  /// **'Vorschläge'**
  String get settingsSuggestions;

  /// No description provided for @settingsNotifications.
  ///
  /// In de, this message translates to:
  /// **'Tägliche Benachrichtigung'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsText.
  ///
  /// In de, this message translates to:
  /// **'Mit „Heute nicht“, „Anrufen“ und „WhatsApp“ direkt in der Benachrichtigung.'**
  String get settingsNotificationsText;

  /// No description provided for @settingsTime.
  ///
  /// In de, this message translates to:
  /// **'Uhrzeit'**
  String get settingsTime;

  /// No description provided for @settingsDays.
  ///
  /// In de, this message translates to:
  /// **'An diesen Tagen'**
  String get settingsDays;

  /// No description provided for @settingsCountryCode.
  ///
  /// In de, this message translates to:
  /// **'Ländervorwahl für WhatsApp'**
  String get settingsCountryCode;

  /// No description provided for @settingsCountryCodeText.
  ///
  /// In de, this message translates to:
  /// **'Für Nummern ohne Vorwahl, z. B. 0171 …'**
  String get settingsCountryCodeText;

  /// No description provided for @settingsDiscreet.
  ///
  /// In de, this message translates to:
  /// **'Diskret: nur Initialen'**
  String get settingsDiscreet;

  /// No description provided for @settingsDiscreetText.
  ///
  /// In de, this message translates to:
  /// **'Widget und Uhr zeigen Initialen statt Namen.'**
  String get settingsDiscreetText;

  /// No description provided for @settingsContacts.
  ///
  /// In de, this message translates to:
  /// **'Kontakte'**
  String get settingsContacts;

  /// No description provided for @settingsData.
  ///
  /// In de, this message translates to:
  /// **'Daten'**
  String get settingsData;

  /// No description provided for @settingsPrivacy.
  ///
  /// In de, this message translates to:
  /// **'Datenschutz'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacyText.
  ///
  /// In de, this message translates to:
  /// **'Alle Daten bleiben verschlüsselt auf diesem Gerät. Kein Konto, keine Cloud, keine Internet-Berechtigung, keine Analyse. Aus dem Adressbuch übernimmt die App nur Name und Nummer, und nur auf deinen Wunsch. Anrufe erkennt sie nicht selbst – gezählt wird, was du in der App antippst oder einträgst.'**
  String get settingsPrivacyText;

  /// No description provided for @backupIntro.
  ///
  /// In de, this message translates to:
  /// **'Sicherung: alle Daten verschlüsselt in einer Datei – für ein neues Handy oder zur Vorsorge. Ohne Passwort ist sie nicht lesbar.'**
  String get backupIntro;

  /// No description provided for @backupCreate.
  ///
  /// In de, this message translates to:
  /// **'Sichern'**
  String get backupCreate;

  /// No description provided for @backupRestore.
  ///
  /// In de, this message translates to:
  /// **'Wiederherstellen'**
  String get backupRestore;

  /// No description provided for @backupCreated.
  ///
  /// In de, this message translates to:
  /// **'Sicherung erstellt'**
  String get backupCreated;

  /// No description provided for @backupFailed.
  ///
  /// In de, this message translates to:
  /// **'Das hat leider nicht geklappt.'**
  String get backupFailed;

  /// No description provided for @backupPassphrase.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get backupPassphrase;

  /// No description provided for @backupPassphraseCreateHint.
  ///
  /// In de, this message translates to:
  /// **'Wähle ein Passwort für die Sicherung. Ohne dieses Passwort lässt sie sich nicht wiederherstellen – gut merken!'**
  String get backupPassphraseCreateHint;

  /// No description provided for @backupPassphraseRestoreHint.
  ///
  /// In de, this message translates to:
  /// **'Passwort der Sicherung'**
  String get backupPassphraseRestoreHint;

  /// No description provided for @backupPassphraseRepeat.
  ///
  /// In de, this message translates to:
  /// **'Passwort wiederholen'**
  String get backupPassphraseRepeat;

  /// No description provided for @backupPassphraseMismatch.
  ///
  /// In de, this message translates to:
  /// **'Die Passwörter stimmen nicht überein'**
  String get backupPassphraseMismatch;

  /// No description provided for @backupPassphraseTooShort.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 8 Zeichen'**
  String get backupPassphraseTooShort;

  /// No description provided for @backupPick.
  ///
  /// In de, this message translates to:
  /// **'Sicherung auswählen'**
  String get backupPick;

  /// No description provided for @backupReplace.
  ///
  /// In de, this message translates to:
  /// **'Ersetzen'**
  String get backupReplace;

  /// No description provided for @backupRestoreConfirmTitle.
  ///
  /// In de, this message translates to:
  /// **'Alle Daten ersetzen?'**
  String get backupRestoreConfirmTitle;

  /// No description provided for @backupRestoreConfirmText.
  ///
  /// In de, this message translates to:
  /// **'Alle Kontakte, der Verlauf und die Einstellungen auf diesem Gerät werden durch die Sicherung ersetzt.'**
  String get backupRestoreConfirmText;

  /// No description provided for @backupRestored.
  ///
  /// In de, this message translates to:
  /// **'Sicherung vom {date} wiederhergestellt'**
  String backupRestored(String date);

  /// No description provided for @backupShareSubject.
  ///
  /// In de, this message translates to:
  /// **'Ruf-durch-Sicherung'**
  String get backupShareSubject;

  /// No description provided for @backupTooNew.
  ///
  /// In de, this message translates to:
  /// **'Diese Sicherung stammt aus einer neueren App-Version. Bitte aktualisiere die App.'**
  String get backupTooNew;

  /// No description provided for @backupUnsupported.
  ///
  /// In de, this message translates to:
  /// **'Sicherungen sind hier nicht verfügbar.'**
  String get backupUnsupported;

  /// No description provided for @backupWrongApp.
  ///
  /// In de, this message translates to:
  /// **'Das ist keine Sicherung von Ruf durch.'**
  String get backupWrongApp;

  /// No description provided for @csvPeople.
  ///
  /// In de, this message translates to:
  /// **'Kontakte als Tabelle teilen (CSV)'**
  String get csvPeople;

  /// No description provided for @csvHistory.
  ///
  /// In de, this message translates to:
  /// **'Verlauf als Tabelle teilen (CSV)'**
  String get csvHistory;

  /// No description provided for @csvShareSubject.
  ///
  /// In de, this message translates to:
  /// **'Ruf durch – Tabelle'**
  String get csvShareSubject;

  /// No description provided for @csvName.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get csvName;

  /// No description provided for @csvPhone.
  ///
  /// In de, this message translates to:
  /// **'Telefon'**
  String get csvPhone;

  /// No description provided for @csvImportance.
  ///
  /// In de, this message translates to:
  /// **'Wichtigkeit'**
  String get csvImportance;

  /// No description provided for @csvLastContact.
  ///
  /// In de, this message translates to:
  /// **'Letzter Kontakt'**
  String get csvLastContact;

  /// No description provided for @csvPausedUntil.
  ///
  /// In de, this message translates to:
  /// **'Pausiert bis'**
  String get csvPausedUntil;

  /// No description provided for @csvNote.
  ///
  /// In de, this message translates to:
  /// **'Notiz'**
  String get csvNote;

  /// No description provided for @csvDate.
  ///
  /// In de, this message translates to:
  /// **'Datum'**
  String get csvDate;

  /// No description provided for @csvKind.
  ///
  /// In de, this message translates to:
  /// **'Art'**
  String get csvKind;

  /// No description provided for @notificationTitle.
  ///
  /// In de, this message translates to:
  /// **'Ruf doch mal {name} an 📞'**
  String notificationTitle(String name);

  /// No description provided for @notificationBodyNew.
  ///
  /// In de, this message translates to:
  /// **'Heute wäre ein guter Tag dafür.'**
  String get notificationBodyNew;

  /// No description provided for @notificationBodySince.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{Euer letzter Kontakt war gestern.} other{Euer letzter Kontakt ist {count} Tage her.}}'**
  String notificationBodySince(int count);

  /// No description provided for @notificationChannel.
  ///
  /// In de, this message translates to:
  /// **'Tagesvorschlag'**
  String get notificationChannel;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In de, this message translates to:
  /// **'Ein Kontakt pro Tag, bei dem du dich melden könntest.'**
  String get notificationChannelDescription;

  /// No description provided for @todaySuggestion.
  ///
  /// In de, this message translates to:
  /// **'Heute melden bei'**
  String get todaySuggestion;

  /// No description provided for @todayDone.
  ///
  /// In de, this message translates to:
  /// **'Erledigt – schön, dass ihr Kontakt hattet!'**
  String get todayDone;

  /// No description provided for @todayDeclined.
  ///
  /// In de, this message translates to:
  /// **'Heute nicht – morgen gibt es einen neuen Vorschlag.'**
  String get todayDeclined;

  /// No description provided for @todayFree.
  ///
  /// In de, this message translates to:
  /// **'Heute ist kein Vorschlagstag.'**
  String get todayFree;

  /// No description provided for @todayFreeAction.
  ///
  /// In de, this message translates to:
  /// **'Trotzdem jemanden vorschlagen'**
  String get todayFreeAction;

  /// No description provided for @todayEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch niemand zum Vorschlagen'**
  String get todayEmptyTitle;

  /// No description provided for @todayEmptyText.
  ///
  /// In de, this message translates to:
  /// **'Importiere deine Kontakte und ordne ein, wie wichtig sie dir sind. Dann gibt es jeden Tag einen Vorschlag.'**
  String get todayEmptyText;

  /// No description provided for @todayNobody.
  ///
  /// In de, this message translates to:
  /// **'Gerade ist niemand fällig. Schön, dass du so gut in Kontakt bist!'**
  String get todayNobody;

  /// No description provided for @todayImport.
  ///
  /// In de, this message translates to:
  /// **'Kontakte importieren'**
  String get todayImport;

  /// No description provided for @todayUnrated.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Kontakt ist noch nicht eingeordnet} other{{count} Kontakte sind noch nicht eingeordnet}}'**
  String todayUnrated(int count);

  /// No description provided for @todaySort.
  ///
  /// In de, this message translates to:
  /// **'Einordnen'**
  String get todaySort;

  /// No description provided for @todayWeek.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{In den letzten 7 Tagen noch kein Kontakt} =1{1 Kontakt in den letzten 7 Tagen} other{{count} Kontakte in den letzten 7 Tagen}}'**
  String todayWeek(int count);

  /// No description provided for @upcomingTitle.
  ///
  /// In de, this message translates to:
  /// **'Demnächst'**
  String get upcomingTitle;

  /// No description provided for @upcomingHint.
  ///
  /// In de, this message translates to:
  /// **'Vorschau – sie ändert sich mit jedem Anruf und jedem „Heute nicht“.'**
  String get upcomingHint;

  /// No description provided for @upcomingEmpty.
  ///
  /// In de, this message translates to:
  /// **'Keine weiteren Vorschläge'**
  String get upcomingEmpty;

  /// No description provided for @todayAnotherNone.
  ///
  /// In de, this message translates to:
  /// **'Gerade ist niemand anderes fällig.'**
  String get todayAnotherNone;

  /// No description provided for @triageTitle.
  ///
  /// In de, this message translates to:
  /// **'Einordnen'**
  String get triageTitle;

  /// No description provided for @triageProgress.
  ///
  /// In de, this message translates to:
  /// **'{done} von {total}'**
  String triageProgress(int done, int total);

  /// No description provided for @triageQuestion.
  ///
  /// In de, this message translates to:
  /// **'Wie oft möchtest du dich bei dieser Person melden?'**
  String get triageQuestion;

  /// No description provided for @triageDoneTitle.
  ///
  /// In de, this message translates to:
  /// **'Alles eingeordnet'**
  String get triageDoneTitle;

  /// No description provided for @triageDoneText.
  ///
  /// In de, this message translates to:
  /// **'Ab jetzt gibt es jeden Tag einen Vorschlag. Die Einordnung kannst du jederzeit beim Kontakt ändern.'**
  String get triageDoneText;

  /// No description provided for @triageEmpty.
  ///
  /// In de, this message translates to:
  /// **'Alle Kontakte sind eingeordnet.'**
  String get triageEmpty;

  /// No description provided for @triageSkipped.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 übersprungen – kommt später wieder} other{{count} übersprungen – kommen später wieder}}'**
  String triageSkipped(int count);

  /// No description provided for @widgetTitle.
  ///
  /// In de, this message translates to:
  /// **'Heute anrufen'**
  String get widgetTitle;

  /// No description provided for @widgetDone.
  ///
  /// In de, this message translates to:
  /// **'Erledigt'**
  String get widgetDone;

  /// No description provided for @widgetDeclined.
  ///
  /// In de, this message translates to:
  /// **'Heute nicht'**
  String get widgetDeclined;

  /// No description provided for @widgetFree.
  ///
  /// In de, this message translates to:
  /// **'Heute frei'**
  String get widgetFree;

  /// No description provided for @widgetEmpty.
  ///
  /// In de, this message translates to:
  /// **'Öffne Ruf durch zum Einordnen'**
  String get widgetEmpty;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
