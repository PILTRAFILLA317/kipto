import 'dart:io';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/files/original_store.dart';
import 'package:kipto/core/repositories/drift_sources_repository.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/features/backup/application/file_queue.dart';
import 'package:kipto/features/backup/application/file_transport.dart';
import 'package:kipto/features/capture/application/capture_service.dart';

import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('T16 failed upload never confirms backup; retry uses same identity and download verifies bytes', () async {
    final root = await Directory.systemTemp.createTemp('kipto-backup-test-');
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await db.close();
      await root.delete(recursive: true);
    });
    final store = OriginalStore(root);
    final sources = DriftSourcesRepository(
      db,
      LocalSyncCoordinator(
        database: db,
        auth: TestAuthRepository(),
        onLocalChange: () {},
      ),
    );
    final capture = CaptureService(
      files: store,
      sources: sources,
      scope: () async => testUser.id,
    );
    const id = '971691c4-4d96-4786-bff6-94c9f128e61a';
    await capture.importText(
      captureId: id,
      text: 'synthetic backup',
      title: 'Synthetic',
    );
    var failed = true;
    var user = testUser.id;
    final keys = <String>[];
    final queue = FileQueue(
      database: db,
      files: () async => store,
      owner: () => user,
      canUpload: () => true,
      transfer: (job, file, progress) async {
        keys.add('${job.ownerId}/${job.sourceId}/${job.revision}');
        if (failed) throw const FileTransferFailure('network');
        if (job.operation == 'download') {
          await file.writeAsBytes(utf8.encode('synthetic backup'));
        }
        progress(16);
      },
    );
    addTearDown(queue.dispose);
    await queue.enqueue(id, 'upload');
    await queue.wake();
    expect((await db.select(db.fileJobs).get()).single.state, 'retry');
    expect(await store.file('$id/original').exists(), isTrue);
    failed = false;
    await queue.enqueue(id, 'upload');
    await queue.wake();
    expect((await db.select(db.fileJobs).get()).single.state, 'done');
    expect(keys.toSet(), hasLength(1));
    await store.file('$id/original').delete();
    await db.delete(db.sourceFiles).go();
    expect(await sources.localFile(id), isNull);
    await queue.enqueue(id, 'download');
    await queue.wake();
    expect(await store.file('$id/original').readAsString(), 'synthetic backup');
    expect((await sources.localFile(id))!.availability, 'downloaded');
    // A late response cannot publish availability into a new account.
    await db.delete(db.sourceFiles).go();
    await store.file('$id/original').delete();
    final racing = FileQueue(
      database: db,
      files: () async => store,
      owner: () => user,
      canUpload: () => true,
      transfer: (job, file, progress) async {
        await file.writeAsString('synthetic backup');
        user = 'other';
      },
    );
    addTearDown(racing.dispose);
    await racing.enqueue(id, 'download');
    await racing.wake();
    expect(await db.select(db.sourceFiles).get(), isEmpty);
    expect(await store.file('$id/original').exists(), isFalse);
  });
}
