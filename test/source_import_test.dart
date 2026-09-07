import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/files/original_store.dart';
import 'package:kipto/core/repositories/drift_items_repository.dart';
import 'package:kipto/core/repositories/drift_reminders_repository.dart';
import 'package:kipto/core/repositories/drift_sources_repository.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/core/sync/sync_service.dart';

import 'test_support.dart';

void main() {
  test(
    'T03 v7 upgrade preserves Item and Reminder before adding Sources',
    () async {
      final dir = await Directory.systemTemp.createTemp('kipto-upgrade-');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/db.sqlite');
      final before = AppDatabase(NativeDatabase(file));
      final coordinator = LocalSyncCoordinator(
        database: before,
        auth: TestAuthRepository(),
        onLocalChange: () {},
      );
      final item = await DriftItemsRepository(
        before,
        syncCoordinator: coordinator,
      ).create(title: 'Keep existing data');
      final reminder = await DriftRemindersRepository(
        before,
        syncCoordinator: coordinator,
        onChanged: () async {},
      ).create(itemId: item.id, remindAt: DateTime.utc(2030));
      for (final trigger in [
        'reminders_action_insert',
        'reminders_action_update',
      ]) {
        await before.customStatement('DROP TRIGGER $trigger');
      }
      await before.customStatement('DROP INDEX reminders_action_idx');
      for (final column in ['action_id', 'title', 'time_zone']) {
        await before.customStatement(
          'ALTER TABLE reminders DROP COLUMN $column',
        );
      }
      await before.customStatement('DROP TABLE analysis_jobs');
      await before.customStatement('DROP TABLE item_actions');
      await before.customStatement('DROP TABLE facts');
      for (final column in ['last_facts_cursor', 'last_actions_cursor']) {
        await before.customStatement(
          'ALTER TABLE cloud_sync_states DROP COLUMN $column',
        );
      }
      await before.customStatement('DROP TABLE source_files');
      await before.customStatement('DROP TABLE sources');
      await before.customStatement(
        'ALTER TABLE cloud_sync_states DROP COLUMN last_sources_cursor',
      );
      await before.customStatement('PRAGMA user_version = 7');
      await before.close();
      final after = AppDatabase(NativeDatabase(file));
      addTearDown(after.close);
      expect((await after.itemsDao.findById(item.id))!.title, item.title);
      expect((await after.remindersDao.findById(reminder.id))!.itemId, item.id);
      expect(after.schemaVersion, 11);
      expect(await after.select(after.sources).get(), isEmpty);
      expect(await after.syncQueueDao.pending(), hasLength(2));
    },
  );

  test('T04 interrupted capture recovers once, retains original and syncs no local path', () async {
    final dir = await Directory.systemTemp.createTemp('kipto-import-');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db.sqlite');
    var db = AppDatabase(NativeDatabase(file));
    final auth = TestAuthRepository();
    const id = 'b5d7a121-d494-44dc-8d43-82735fdc19c9';
    final png = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAACklEQVR4nGNoAAAAggCBd81ytgAAAABJRU5ErkJggg==',
    );
    final files = OriginalStore(Directory('${dir.path}/originals'));
    await files.persist(
      captureId: id,
      scope: testUser.id,
      name: '../../synthetic.png',
      origin: 'systemPicker',
      bytes: Stream.value(png),
    );
    // Crash boundary: durable file exists but no database row was committed.
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    final recovered = (await OriginalStore(files.root).recover(testUser.id))
        .single;
    final coordinator = LocalSyncCoordinator(
      database: db,
      auth: auth,
      onLocalChange: () {},
    );
    final sources = DriftSourcesRepository(db, coordinator);
    for (var delivery = 0; delivery < 2; delivery++) {
      await sources.import(
        recovered,
        expectedScope: testUser.id,
        currentScope: testUser.id,
      );
    }
    expect(await db.select(db.items).get(), hasLength(1));
    expect(await db.select(db.sources).get(), hasLength(1));
    expect(await files.file('$id/original').readAsBytes(), png);
    expect(() => files.file('../private'), throwsA(isA<CaptureFailure>()));
    expect(await files.recover('another-account'), isEmpty);
    final remote = FakeRemoteDataSource();
    final sync = SyncService(database: db, auth: auth, remote: remote);
    addTearDown(sync.dispose);
    await sync.initialize();
    expect(remote.calls.take(2), ['items', 'sources']);
    expect(remote.sources[id]!.contentHash, recovered.hash);
    expect(
      remote.sources[id]!.toJson().keys,
      isNot(contains('originalRelativePath')),
    );
    expect(jsonEncode(remote.sources[id]!.toJson()), isNot(contains(dir.path)));
  });

  test(
    'invalid signatures and unsafe paths never publish a ready capture',
    () async {
      final root = await Directory.systemTemp.createTemp('kipto-invalid-');
      addTearDown(() => root.delete(recursive: true));
      final store = OriginalStore(root);
      await expectLater(
        store.persist(
          captureId: 'c66f4141-c8d9-436d-87a0-671726a6bfef',
          scope: 'local',
          name: 'fake.pdf',
          origin: 'systemPicker',
          bytes: Stream.value(utf8.encode('not a PDF')),
        ),
        throwsA(isA<CaptureFailure>()),
      );
      expect(await store.recover('local'), isEmpty);
      await expectLater(
        store.persist(
          captureId: '../escape',
          scope: 'local',
          name: 'x',
          origin: 'manual',
          bytes: const Stream.empty(),
        ),
        throwsA(isA<CaptureFailure>()),
      );
    },
  );
}
