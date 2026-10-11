import 'package:drift/drift.dart';

import '../domain/importance.dart';
import 'connection/connection.dart';

part 'app_database.g.dart';

// Alle Enums werden als Index gespeichert (`intEnum`): neue Werte nur hinten
// anhängen, nie umsortieren oder löschen.

/// Was mit einem Kontakt passiert ist.
enum EventKind {
  /// „Anrufen“ getippt (Wähl-App geöffnet).
  called,

  /// „WhatsApp“ getippt.
  messaged,

  /// „Heute nicht“.
  declined,

  /// Von Hand eingetragen („Wir haben gesprochen“, getroffen …).
  noted,
}

/// Stand des Tagesvorschlags.
enum SuggestionStatus {
  open,
  called,
  messaged,
  declined,

  /// Kontakt auf anderem Weg (von Hand eingetragen).
  noted;

  /// Angenommen: Kontakt kam zustande.
  bool get accepted =>
      this == called || this == messaged || this == noted;
}

/// Einstellungen als Schlüssel/Wert (tolerant lesen, siehe SettingKeys).
class LocalSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Kontakt in der App — aus dem Adressbuch übernommen oder von Hand angelegt.
@DataClassName('Person')
class People extends Table {
  TextColumn get id => text()();

  /// Schlüssel im Adressbuch des Geräts (Android: Lookup-Key, iOS:
  /// Identifier) zum Abgleich beim erneuten Import; `null` = von Hand.
  TextColumn get systemId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();

  /// WhatsApp-Knopf anbieten.
  BoolColumn get whatsapp => boolean().withDefault(const Constant(true))();

  /// `null` = noch nicht eingeordnet (wird nicht vorgeschlagen).
  IntColumn get importance => intEnum<Importance>().nullable()();

  /// Pausiert bis einschließlich diesem Tag.
  DateTimeColumn get pausedUntil => dateTime().nullable()();
  TextColumn get note => text().nullable()();

  /// Aus der App entfernt — bleibt, damit ein erneuter Import ihn nicht
  /// wieder hinzufügt und der Verlauf erhalten bleibt.
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Verlauf: Anrufe, Nachrichten, „Heute nicht“, eingetragene Kontakte.
class ContactEvents extends Table {
  TextColumn get id => text()();
  TextColumn get personId => text()();
  IntColumn get kind => intEnum<EventKind>()();
  DateTimeColumn get at => dateTime()();

  /// Zugehöriger Tagesvorschlag, falls aus einem Vorschlag heraus.
  TextColumn get suggestionId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Tagesvorschläge. Pro Tag gilt der zuletzt angelegte; „Jemand anderen“
/// legt einen weiteren an.
class DailySuggestions extends Table {
  TextColumn get id => text()();

  /// Tagesschlüssel „2026-10-11“.
  TextColumn get day => text()();
  TextColumn get personId => text()();
  IntColumn get status => intEnum<SuggestionStatus>()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [LocalSettings, People, ContactEvents, DailySuggestions])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? openAppDatabase());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIndexes();
    },
    // Schritte strikt aufsteigend: jeder Block bringt v(n-1) → v(n).
    // Beispiel: if (from < 2) { await m.addColumn(...); }
    onUpgrade: (m, from, to) async {},
  );

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_contact_events_person '
      'ON contact_events (person_id, at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_daily_suggestions_day '
      'ON daily_suggestions (day, created_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_people_system '
      'ON people (system_id)',
    );
  }
}
