import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mai_backup_format/mai_backup_format.dart';
import 'package:mai_stay_in_touch/data/app_database.dart';
import 'package:mai_stay_in_touch/data/repositories/people_repository.dart';
import 'package:mai_stay_in_touch/data/repositories/suggestion_repository.dart';
import 'package:mai_stay_in_touch/data/settings.dart';
import 'package:mai_stay_in_touch/domain/importance.dart';
import 'package:mai_stay_in_touch/services/backup_service.dart';
import 'package:sqlite3/sqlite3.dart';

import 'helpers.dart';

void main() {
  late Directory tmp;
  late AppDatabase db;
  late BackupService service;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('backup_');
    db = testDb();
    service = BackupService(db, tempDir: () async => tmp, iterations: 1000);
  });
  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  /// Erfundene Beispieldaten: zwei Kontakte, ein Anruf.
  Future<String> seed() async {
    final people = PeopleRepository(db);
    final alex = await people.add(
      name: 'Alex Beispiel',
      phone: '0171 1111111',
      importance: Importance.veryOften,
    );
    await people.add(name: 'Sam Muster', importance: Importance.rarely);
    await SuggestionRepository(db).note(alex, at: DateTime(2026, 10, 1));
    await Settings(db).set(SettingKeys.notificationMinutes, '480');
    return alex;
  }

  test('Sicherung → alles ändern → Wiederherstellen bringt Daten zurück', () async {
    final alex = await seed();
    final file = await service.createBackupFile('geheim123');
    expect(file.path, endsWith('.mairuf'));
    final bytes = await file.readAsBytes();
    expect(String.fromCharCodes(bytes), isNot(contains('Alex')));
    expect(BackupCrypto.looksLikeBackup(bytes), isTrue);

    final people = PeopleRepository(db);
    await people.archive(alex);
    await Settings(db).set(SettingKeys.notificationMinutes, '600');

    await service.restoreFile(file.path, 'geheim123');
    final restored = await people.active();
    expect(restored.map((p) => p.name), containsAll(['Alex Beispiel', 'Sam Muster']));
    expect(await Settings(db).get(SettingKeys.notificationMinutes), '480');
    expect((await people.lastContacts())[alex]!.$1, DateTime(2026, 10, 1));
    expect(tmp.listSync().whereType<Directory>(), isEmpty);
  });

  test('falsches Passwort lässt Daten unverändert', () async {
    await seed();
    final file = await service.createBackupFile('geheim123');
    await PeopleRepository(db).add(name: 'Kim Test');
    await expectLater(
      service.restoreFile(file.path, 'falsch!!!'),
      throwsA(isA<BackupException>()),
    );
    expect(await PeopleRepository(db).active(), hasLength(3));
  });

  test('zu kurze Passwörter werden abgelehnt', () async {
    await expectLater(
      service.createBackupFile('kurz'),
      throwsA(isA<BackupException>()),
    );
  });

  test('Sicherungen anderer Mai-Apps werden abgelehnt', () async {
    final foreign = File('${tmp.path}/fit.maifit');
    await foreign.writeAsBytes(
      await BackupCrypto.encrypt(
        BackupArchive.build(
          database: Uint8List(0),
          manifest: {'app': 'mai_fitness', 'schemaVersion': 1},
        ),
        'geheim123',
        iterations: 1000,
      ),
    );
    await expectLater(
      service.restoreFile(foreign.path, 'geheim123'),
      throwsA(
        isA<BackupException>().having(
          (e) => e.message,
          'message',
          contains('keine Sicherung von Ruf durch'),
        ),
      ),
    );
  });

  test('Sicherungen aus neuerem Schema werden abgelehnt', () async {
    await seed();
    final snapshot = '${tmp.path}/newer.sqlite';
    await db.customStatement('VACUUM INTO ?', [snapshot]);
    sqlite3.open(snapshot)
      ..execute('PRAGMA user_version = 99')
      ..close();
    final file = File('${tmp.path}/newer.mairuf');
    await file.writeAsBytes(
      await BackupCrypto.encrypt(
        BackupArchive.build(
          database: await File(snapshot).readAsBytes(),
          manifest: {'app': backupAppId, 'schemaVersion': 99},
        ),
        'geheim123',
        iterations: 1000,
      ),
    );
    await expectLater(
      service.restoreFile(file.path, 'geheim123'),
      throwsA(isA<BackupException>()),
    );
  });
}
