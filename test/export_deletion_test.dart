import 'package:kipto/features/backup/application/file_queue.dart';
import 'package:kipto/core/auth/kipto_auth_state.dart';

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/files/original_store.dart';
import 'package:kipto/core/repositories/drift_sources_repository.dart';
import 'package:kipto/core/repositories/drift_reminders_repository.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/features/capture/application/capture_service.dart';
import 'package:kipto/features/privacy/application/deletion_service.dart';
import 'package:kipto/features/privacy/application/export_service.dart';

import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'T20 local deletion resumes after platform failure even after a new login',
    () async {
      final root = await Directory.systemTemp.createTemp('kipto-delete-local-');
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(() async {
        await db.close();
        await root.delete(recursive: true);
      });
      final auth = TestAuthRepository();
      await auth.signOut();
      final coordinator = LocalSyncCoordinator(
        database: db,
        auth: auth,
        onLocalChange: () {},
      );
      final files = OriginalStore(root);
      final sources = DriftSourcesRepository(db, coordinator);
      const id = '971691c4-4d96-4786-bff6-94c9f128e61a';
      await CaptureService(
        files: files,
        sources: sources,
        scope: () async => 'local:synthetic-installation',
      ).importText(captureId: id, text: 'Synthetic', title: 'Synthetic');
      final deletion = DeletionService(
        database: db,
        coordinator: coordinator,
        originals: () async => files,
        reconcile: () async {
          throw StateError('Synthetic platform interruption');
        },
        wakeFiles: () async {},
      );
      await expectLater(deletion.deleteMatter(id), throwsStateError);
      expect(await files.file('$id/original').exists(), isTrue);
      final next = TestAuthRepository(
        const KiptoUser(id: 'next-account', isAnonymous: true),
      );
      await LocalSyncCoordinator(
        database: db,
        auth: next,
        onLocalChange: () {},
      ).claimLocalOnlyData(next.userId!);
      expect((await db.select(db.sources).get()).single.ownerId, isNull);
      final queue = FileQueue(
        database: db,
        files: () async => files,
        owner: () => next.userId,
        canUpload: () => false,
        transfer: (_, _, _) async {
          fail('A local-only deletion must never need a server');
        },
      );
      addTearDown(queue.dispose);
      await queue.resume();
      expect((await db.select(db.fileJobs).get()).single.state, 'done');
      expect(await files.file('$id/original').exists(), isFalse);
    },
  );
  test('T20 export identifies missing originals; deletion persists tombstones and file retry after platform failure', () async {
    final root = await Directory.systemTemp.createTemp('kipto-export-test-');
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await db.close();
      await root.delete(recursive: true);
    });
    final auth = TestAuthRepository();
    final coordinator = LocalSyncCoordinator(
      database: db,
      auth: auth,
      onLocalChange: () {},
    );
    final files = OriginalStore(Directory('${root.path}/originals'));
    final sources = DriftSourcesRepository(db, coordinator);
    final capture = CaptureService(
      files: files,
      sources: sources,
      scope: () async => testUser.id,
    );
    const id = '971691c4-4d96-4786-bff6-94c9f128e61a';
    await capture.importText(
      captureId: id,
      text: 'Synthetic original',
      title: 'Synthetic',
    );
    final reminders = DriftRemindersRepository(
      db,
      syncCoordinator: coordinator,
      onChanged: () async {},
    );
    await reminders.create(
      itemId: id,
      remindAt: DateTime.now().toUtc().add(const Duration(days: 1)),
    );
    final exporter = ExportService(db, files, () => testUser.id);
    final exported = await exporter.export(
      itemIds: [id],
      destination: Directory('${root.path}/exports'),
      cancelled: () => false,
    );
    final archive = ZipDecoder().decodeBytes(await exported.file.readAsBytes());
    final json = utf8.decode(archive.findFile('manifest.json')!.content);
    expect(json, contains('"exportVersion": 1'));
    expect(json, contains('"complete": true'));
    expect(json, isNot(contains(root.path)));
    expect(json, isNot(contains('accessToken')));
    expect(archive.findFile('originals/$id'), isNotNull);
    await files.file('$id/original').delete();
    final missing = await exporter.export(
      itemIds: [id],
      destination: Directory('${root.path}/exports'),
      cancelled: () => false,
    );
    expect(missing.missing, [id]);
    var cancelCalled = false;
    final deletion = DeletionService(
      database: db,
      coordinator: coordinator,
      originals: () async => files,
      reconcile: () async {
        cancelCalled = true;
      },
      wakeFiles: () async {
        throw const SocketException('synthetic');
      },
    );
    await expectLater(
      deletion.deleteMatter(id),
      throwsA(isA<SocketException>()),
    );
    expect(cancelCalled, isTrue);
    expect((await db.select(db.sources).get()).single.textContent, isNull);
    expect((await db.select(db.sources).get()).single.originalName, 'Deleted');
    expect((await db.select(db.items).get()).single.title, 'Deleted');
    expect(
      (await db.itemsDao.findById(id, includeDeleted: true))!.deletedAt,
      isNotNull,
    );
    expect((await db.select(db.reminders).get()).single.deletedAt, isNotNull);
    expect((await db.select(db.fileJobs).get()).single.operation, 'delete');
    expect((await db.select(db.fileJobs).get()).single.state, 'queued');
  });
}
