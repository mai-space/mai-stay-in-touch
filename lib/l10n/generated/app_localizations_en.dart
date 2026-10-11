// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ruf durch';

  @override
  String get tabToday => 'Today';

  @override
  String get tabContacts => 'Contacts';

  @override
  String get tabHistory => 'History';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonDone => 'Done';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonToday => 'Today';

  @override
  String get commonTomorrow => 'Tomorrow';

  @override
  String get commonUnderstood => 'Got it';

  @override
  String get commonUndo => 'Undo';

  @override
  String get actionCall => 'Call';

  @override
  String get actionWhatsApp => 'WhatsApp';

  @override
  String get actionLater => 'Not today';

  @override
  String get actionAnother => 'Someone else';

  @override
  String get actionNoted => 'Log contact';

  @override
  String get importanceUnrated => 'Not sorted';

  @override
  String get importanceNever => 'Never suggest';

  @override
  String get importanceRarely => 'Rarely';

  @override
  String get importanceSometimes => 'Now and then';

  @override
  String get importanceOften => 'Often';

  @override
  String get importanceVeryOften => 'Very important';

  @override
  String get importanceHintNever => 'Never shows up as a suggestion';

  @override
  String get importanceHintRarely => 'About every three months';

  @override
  String get importanceHintSometimes => 'About once a month';

  @override
  String get importanceHintOften => 'About every two weeks';

  @override
  String get importanceHintVeryOften => 'About every week';

  @override
  String get lastContactNever => 'No contact logged yet';

  @override
  String lastContactDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Last contact $count days ago',
      one: 'Last contact yesterday',
      zero: 'In touch today',
    );
    return '$_temp0';
  }

  @override
  String get noNumber => 'No phone number saved';

  @override
  String get launchFailed => 'Could not be opened';

  @override
  String get whatsAppFailed =>
      'Could not open WhatsApp. Is the number saved with its country code?';

  @override
  String get keyUnavailableTitle => 'Data not readable right now';

  @override
  String get keyUnavailableText =>
      'The key for your encrypted data is not available right now. Your data is safe — try again in a moment or restart your device.';

  @override
  String get unreadableTitle => 'Old data could not be read';

  @override
  String get unreadableText =>
      'Your previous data could no longer be decrypted on this device and was set aside. Restore it from a backup (Settings → Data).';

  @override
  String get contactsEmptyTitle => 'No contacts yet';

  @override
  String get contactsEmptyText =>
      'Get your contacts from the address book or add them by hand.';

  @override
  String get contactsAdd => 'Add contact';

  @override
  String get contactsImport => 'Import from address book';

  @override
  String get contactsFilterAll => 'All';

  @override
  String get contactsNoMatch => 'No matches';

  @override
  String contactsPausedUntil(String date) {
    return 'Paused until $date';
  }

  @override
  String get contactImportance => 'How often do you want to get in touch?';

  @override
  String get contactPause => 'Pause';

  @override
  String get contactPauseWeek => '1 week';

  @override
  String get contactPauseMonth => '1 month';

  @override
  String get contactPauseQuarter => '3 months';

  @override
  String get contactResume => 'End pause';

  @override
  String get contactPauseText =>
      'No suggestions for this contact while paused – e.g. during a holiday.';

  @override
  String get contactWhatsApp => 'Offer WhatsApp';

  @override
  String get contactNote => 'Note';

  @override
  String get contactNoteHint => 'e.g. what you want to ask about';

  @override
  String get contactHistory => 'History';

  @override
  String get contactNoHistory => 'Nothing logged yet';

  @override
  String get contactNotedDone => 'Contact logged';

  @override
  String get contactRemove => 'Remove from app';

  @override
  String contactRemoveTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get contactRemoveText =>
      'The contact will no longer be suggested and stays out on the next import. Your address book is not changed.';

  @override
  String get contactName => 'Name';

  @override
  String get contactPhone => 'Phone number';

  @override
  String get contactNameRequired => 'Please enter a name';

  @override
  String get contactEdit => 'Edit contact';

  @override
  String contactStats(int accepted, int suggested) {
    return '$accepted of $suggested suggestions taken';
  }

  @override
  String get historyEmptyTitle => 'No history yet';

  @override
  String get historyEmptyText =>
      'Calls, messages and “Not today” show up here.';

  @override
  String get eventCalled => 'Called';

  @override
  String get eventMessaged => 'Sent a WhatsApp';

  @override
  String get eventDeclined => 'Not today';

  @override
  String get eventNoted => 'Contact logged';

  @override
  String get historyDeleted => 'Entry deleted';

  @override
  String get historyRemovedPerson => 'Removed contact';

  @override
  String get statsWeek => 'Last 7 days';

  @override
  String get statsMonth => 'Last 30 days';

  @override
  String get statsPeople => 'Different people (30 days)';

  @override
  String get importTitle => 'Import contacts';

  @override
  String get importIntro =>
      'Choose whom to add. Only name and phone number are taken over – encrypted, only on this device.';

  @override
  String get importSelectAll => 'Select all';

  @override
  String get importSelectNone => 'Select none';

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count contacts',
      one: 'Add 1 contact',
      zero: 'Nothing selected',
    );
    return '$_temp0';
  }

  @override
  String get importAlready => 'Already in the app';

  @override
  String get importDenied =>
      'Import needs access to your contacts. You can also add contacts by hand.';

  @override
  String get importOpenSettings => 'Open settings';

  @override
  String get importNone => 'No contacts with a phone number found.';

  @override
  String importResult(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contacts added',
      one: '1 contact added',
      zero: 'Nothing new added',
    );
    return '$_temp0';
  }

  @override
  String get importUnsupported =>
      'Importing from the address book is not available here.';

  @override
  String get onboardingWelcomeTitle => 'Stay in touch';

  @override
  String get onboardingWelcomeText =>
      'Every day Ruf durch suggests one person you could get in touch with – the more important they are to you, the more often.';

  @override
  String get onboardingPrivacyText =>
      'Everything stays encrypted on your phone. No account, no cloud, no internet permission.';

  @override
  String get onboardingImportTitle => 'Get your contacts';

  @override
  String get onboardingImportText =>
      'Take over contacts from your address book and sort them afterwards. You can add more later.';

  @override
  String onboardingImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contacts in the app',
      one: '1 contact in the app',
      zero: 'No contacts yet',
    );
    return '$_temp0';
  }

  @override
  String get onboardingNotifyTitle => 'When suits you?';

  @override
  String get onboardingNotifyText =>
      'At this time the suggestion arrives as a notification – with “Not today”, “Call” and “WhatsApp”.';

  @override
  String get onboardingNotifyButton => 'Allow notifications';

  @override
  String get onboardingNotifyOn => 'Notifications are on';

  @override
  String get onboardingStart => 'Let’s go';

  @override
  String get onboardingLater => 'Later';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSuggestions => 'Suggestions';

  @override
  String get settingsNotifications => 'Daily notification';

  @override
  String get settingsNotificationsText =>
      'With “Not today”, “Call” and “WhatsApp” right in the notification.';

  @override
  String get settingsTime => 'Time';

  @override
  String get settingsDays => 'On these days';

  @override
  String get settingsCountryCode => 'Country code for WhatsApp';

  @override
  String get settingsCountryCodeText =>
      'For numbers without a country code, e.g. 0171 …';

  @override
  String get settingsDiscreet => 'Discreet: initials only';

  @override
  String get settingsDiscreetText =>
      'Widget and watch show initials instead of names.';

  @override
  String get settingsContacts => 'Contacts';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacyText =>
      'All data stays encrypted on this device. No account, no cloud, no internet permission, no analytics. From the address book the app only takes name and number, and only when you ask. It does not detect calls by itself – it counts what you tap or log in the app.';

  @override
  String get backupIntro =>
      'Backup: all your data, encrypted in one file – for a new phone or just in case. It cannot be read without the password.';

  @override
  String get backupCreate => 'Back up';

  @override
  String get backupRestore => 'Restore';

  @override
  String get backupCreated => 'Backup created';

  @override
  String get backupFailed => 'Sorry, that did not work.';

  @override
  String get backupPassphrase => 'Password';

  @override
  String get backupPassphraseCreateHint =>
      'Choose a password for the backup. It cannot be restored without it – keep it safe!';

  @override
  String get backupPassphraseRestoreHint => 'Backup password';

  @override
  String get backupPassphraseRepeat => 'Repeat password';

  @override
  String get backupPassphraseMismatch => 'Passwords do not match';

  @override
  String get backupPassphraseTooShort => 'At least 8 characters';

  @override
  String get backupPick => 'Choose backup';

  @override
  String get backupReplace => 'Replace';

  @override
  String get backupRestoreConfirmTitle => 'Replace all data?';

  @override
  String get backupRestoreConfirmText =>
      'All contacts, the history and the settings on this device will be replaced by the backup.';

  @override
  String backupRestored(String date) {
    return 'Backup from $date restored';
  }

  @override
  String get backupShareSubject => 'Ruf durch backup';

  @override
  String get backupTooNew =>
      'This backup is from a newer app version. Please update the app.';

  @override
  String get backupUnsupported => 'Backups are not available here.';

  @override
  String get backupWrongApp => 'This is not a Ruf durch backup.';

  @override
  String get csvPeople => 'Share contacts as table (CSV)';

  @override
  String get csvHistory => 'Share history as table (CSV)';

  @override
  String get csvShareSubject => 'Ruf durch – table';

  @override
  String get csvName => 'Name';

  @override
  String get csvPhone => 'Phone';

  @override
  String get csvImportance => 'Importance';

  @override
  String get csvLastContact => 'Last contact';

  @override
  String get csvPausedUntil => 'Paused until';

  @override
  String get csvNote => 'Note';

  @override
  String get csvDate => 'Date';

  @override
  String get csvKind => 'Type';

  @override
  String notificationTitle(String name) {
    return 'Why not call $name today? 📞';
  }

  @override
  String get notificationBodyNew => 'Today would be a good day for it.';

  @override
  String notificationBodySince(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You were last in touch $count days ago.',
      one: 'You were last in touch yesterday.',
    );
    return '$_temp0';
  }

  @override
  String get notificationChannel => 'Daily suggestion';

  @override
  String get notificationChannelDescription =>
      'One contact a day you could get in touch with.';

  @override
  String get todaySuggestion => 'Reach out today to';

  @override
  String get todayDone => 'Done – nice that you got in touch!';

  @override
  String get todayDeclined => 'Not today – there is a new suggestion tomorrow.';

  @override
  String get todayFree => 'No suggestion scheduled for today.';

  @override
  String get todayFreeAction => 'Suggest someone anyway';

  @override
  String get todayEmptyTitle => 'No one to suggest yet';

  @override
  String get todayEmptyText =>
      'Import your contacts and sort them by how important they are to you. Then you get a suggestion every day.';

  @override
  String get todayNobody =>
      'No one is due right now. Nice that you are so well in touch!';

  @override
  String get todayImport => 'Import contacts';

  @override
  String todayUnrated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contacts are not sorted yet',
      one: '1 contact is not sorted yet',
    );
    return '$_temp0';
  }

  @override
  String get todaySort => 'Sort';

  @override
  String todayWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contacts in the last 7 days',
      one: '1 contact in the last 7 days',
      zero: 'No contacts in the last 7 days',
    );
    return '$_temp0';
  }

  @override
  String get upcomingTitle => 'Coming up';

  @override
  String get upcomingHint =>
      'Preview – it changes with every call and every “Not today”.';

  @override
  String get upcomingEmpty => 'No further suggestions';

  @override
  String get todayAnotherNone => 'No one else is due right now.';

  @override
  String get triageTitle => 'Sort contacts';

  @override
  String triageProgress(int done, int total) {
    return '$done of $total';
  }

  @override
  String get triageQuestion =>
      'How often do you want to get in touch with this person?';

  @override
  String get triageDoneTitle => 'All sorted';

  @override
  String get triageDoneText =>
      'From now on you get a suggestion every day. You can change the sorting on each contact at any time.';

  @override
  String get triageEmpty => 'All contacts are sorted.';

  @override
  String triageSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skipped – will come up again later',
      one: '1 skipped – will come up again later',
    );
    return '$_temp0';
  }

  @override
  String get widgetTitle => 'Call today';

  @override
  String get widgetDone => 'Done';

  @override
  String get widgetDeclined => 'Not today';

  @override
  String get widgetFree => 'Day off';

  @override
  String get widgetEmpty => 'Open Ruf durch to sort contacts';
}
