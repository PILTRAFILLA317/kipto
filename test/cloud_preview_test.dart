import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/auth/kipto_auth_state.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/repositories/drift_saved_items_repository.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/features/cloud_preview/application/cloud_preview_backup_service.dart';
import 'package:kipto/features/cloud_preview/application/cloud_preview_resolver.dart';
import 'package:kipto/features/cloud_preview/data/cloud_preview_preferences.dart';
import 'package:kipto/features/cloud_preview/data/file_cloud_preview_cache.dart';
import 'package:kipto/features/cloud_preview/domain/cloud_preview_cache.dart';
import 'package:kipto/features/cloud_preview/domain/cloud_preview_generator.dart';
import 'package:kipto/features/cloud_preview/domain/cloud_preview_models.dart';

import 'fakes/fake_cloud_preview_repository.dart';
import 'fakes/fake_sync_dependencies.dart';
import 'test_helpers.dart';

void main() {
  group('preview sizing', () {
    test('portrait, landscape, and very tall images preserve aspect ratio', () {
      final portrait = CloudPreviewSizing.calculate(1170, 2532);
      final landscape = CloudPreviewSizing.calculate(2532, 1170);
      final tall = CloudPreviewSizing.calculate(1080, 20000);

      expect(portrait.width, 900);
      expect(portrait.height, closeTo(1948, 1));
      expect(landscape.width, 900);
      expect(landscape.height, closeTo(416, 1));
      expect(tall.height, 8000);
      expect(tall.width, closeTo(432, 1));
      expect(tall.width * tall.height, lessThanOrEqualTo(8000000));
    });
  });

  group('preview upload queue', () {
    test('eligible item uploads once and queues metadata sync', () async {
      final fixture = await _BackupFixture.create();
      addTearDown(fixture.dispose);
      await fixture.createItem('item-a');

      await fixture.service.enqueueSavedItem('item-a');
      await fixture.service.enqueueSavedItem('item-a');

      final row = await fixture.database.savedItemsDao.findById('item-a');
      expect(fixture.remote.uploadCalls, 1);
      expect(row?.cloudPreviewPath, 'user-a/item-a/preview-v1.jpg');
      expect(await fixture.database.syncQueueDao.pending(), hasLength(1));
      expect(await fixture.remote.exists(row!.cloudPreviewPath!), isTrue);
    });

    test('metadata-only never generates or uploads a preview', () async {
      final fixture = await _BackupFixture.create(
        mode: CloudImageSyncMode.metadataOnly,
      );
      addTearDown(fixture.dispose);
      await fixture.createItem('item-metadata');

      await fixture.service.enqueueSavedItem('item-metadata');

      expect(fixture.generator.calls, 0);
      expect(fixture.remote.uploadCalls, 0);
      expect(
        (await fixture.database.savedItemsDao.findById('item-metadata'))
            ?.cloudPreviewPath,
        isNull,
      );
    });

    test('failed upload is persisted and can be retried safely', () async {
      final fixture = await _BackupFixture.create(maxAttempts: 1);
      addTearDown(fixture.dispose);
      await fixture.createItem('item-retry');
      fixture.remote.failUploads = true;

      await fixture.service.enqueueSavedItem('item-retry');
      final failed = await fixture.database
          .select(fixture.database.previewTransferJobs)
          .getSingle();
      expect(failed.state, PreviewTransferState.paused.name);
      expect(failed.attemptCount, 1);

      fixture.remote.failUploads = false;
      await fixture.service.retryFailed();
      expect(fixture.remote.uploadCalls, 2);
      expect(
        (await fixture.database.savedItemsDao.findById('item-retry'))
            ?.cloudPreviewPath,
        isNotNull,
      );
    });

    test(
      'delete removes cloud preview but preserves tombstone and asset id',
      () async {
        final fixture = await _BackupFixture.create();
        addTearDown(fixture.dispose);
        await fixture.createItem('item-delete');
        await fixture.service.enqueueSavedItem('item-delete');
        await fixture.items.softDelete('item-delete');
        await fixture.service.enqueueDelete('item-delete');

        final row = await fixture.database.savedItemsDao.findById(
          'item-delete',
          includeDeleted: true,
        );
        expect(row?.deletedAt, isNotNull);
        expect(row?.cloudPreviewPath, isNull);
        expect(row?.localAssetId, 'asset-item-delete');
        expect(fixture.remote.objects, isEmpty);
      },
    );
  });

  group('preview cache and download', () {
    test('cache hit, clear, eviction, and corruption fallback', () async {
      final root = await Directory.systemTemp.createTemp('kipto-cache-test-');
      addTearDown(() => root.delete(recursive: true));
      final cache = FileCloudPreviewCache(
        rootDirectory: () async => root,
        maxBytes: 7,
      );
      final jpeg = Uint8List.fromList([0xff, 0xd8, 0xff, 1]);
      final first = await cache.store(
        savedItemId: 'one',
        cloudPath: 'user/one/preview.jpg',
        bytes: jpeg,
      );
      expect(
        await cache.lookup(
          savedItemId: 'one',
          cloudPath: 'user/one/preview.jpg',
        ),
        first,
      );
      await cache.store(
        savedItemId: 'two',
        cloudPath: 'user/two/preview.jpg',
        bytes: jpeg,
      );
      expect(File(first).existsSync(), isFalse);

      final corrupted = await cache.store(
        savedItemId: 'bad',
        cloudPath: 'user/bad/preview.jpg',
        bytes: jpeg,
      );
      await File(corrupted).writeAsBytes([1, 2, 3]);
      expect(
        await cache.lookup(
          savedItemId: 'bad',
          cloudPath: 'user/bad/preview.jpg',
        ),
        isNull,
      );
      await cache.clear();
      expect(
        Directory('${root.path}/kipto_preview_cache').existsSync(),
        isFalse,
      );
    });

    test(
      'concurrent requests for one path perform one lazy download',
      () async {
        final database = createTestDatabase();
        addTearDown(database.close);
        final auth = FakeAuthRepository(
          const KiptoUser(id: 'user-a', isAnonymous: false),
        );
        final item = testSavedItem(
          id: 'remote-item',
          now: DateTime.utc(2026, 8, 30),
          ownerId: 'user-a',
        );
        await DriftSavedItemsRepository(database).create(item);
        const cloudPath = 'user-a/remote-item/preview-v1.jpg';
        await database.savedItemsDao.updateFields(
          item.id,
          const SavedItemsCompanion(cloudPreviewPath: Value(cloudPath)),
        );
        final remote = FakeCloudPreviewRepository()
          ..objects[cloudPath] = Uint8List.fromList([0xff, 0xd8, 0xff, 1])
          ..downloadDelay = const Duration(milliseconds: 20);
        final cache = _MemoryCache();
        final resolver = CloudPreviewResolver(
          database: database,
          auth: auth,
          remote: remote,
          cache: cache,
        );

        final paths = await Future.wait([
          resolver.resolve(savedItemId: item.id, cloudPath: cloudPath),
          resolver.resolve(savedItemId: item.id, cloudPath: cloudPath),
        ]);
        expect(remote.downloadCalls, 1);
        expect(paths, everyElement('/cache/remote-item.jpg'));
        remote.failDownloads = true;
        expect(
          await resolver.resolve(savedItemId: item.id, cloudPath: cloudPath),
          '/cache/remote-item.jpg',
        );
      },
    );
  });
}

final class _BackupFixture {
  _BackupFixture({
    required this.database,
    required this.items,
    required this.service,
    required this.remote,
    required this.generator,
  });

  final AppDatabase database;
  final DriftSavedItemsRepository items;
  final CloudPreviewBackupService service;
  final FakeCloudPreviewRepository remote;
  final _FakeGenerator generator;

  static Future<_BackupFixture> create({
    CloudImageSyncMode mode = CloudImageSyncMode.optimizedPreviews,
    int maxAttempts = 3,
  }) async {
    final database = createTestDatabase();
    final auth = FakeAuthRepository(
      const KiptoUser(id: 'user-a', isAnonymous: true),
    );
    final coordinator = LocalSyncCoordinator(
      database: database,
      auth: auth,
      onLocalChange: () {},
    );
    final items = DriftSavedItemsRepository(database);
    final remote = FakeCloudPreviewRepository();
    final generator = _FakeGenerator();
    final service = CloudPreviewBackupService(
      database: database,
      auth: auth,
      generator: generator,
      remote: remote,
      cache: _MemoryCache(),
      preferences: _FakePreferences(mode),
      syncCoordinator: coordinator,
      maxAttempts: maxAttempts,
    );
    await service.initialize();
    return _BackupFixture(
      database: database,
      items: items,
      service: service,
      remote: remote,
      generator: generator,
    );
  }

  Future<void> createItem(String id) => items.create(
    testSavedItem(
      id: id,
      now: DateTime.utc(2026, 8, 30),
      ownerId: 'user-a',
      localAssetId: 'asset-$id',
      originalAvailable: true,
    ),
  );

  Future<void> dispose() => database.close();
}

final class _FakeGenerator implements CloudPreviewGenerator {
  int calls = 0;

  @override
  Future<CloudPreview?> generate(String localAssetId) async {
    calls++;
    return CloudPreview(
      bytes: Uint8List.fromList([0xff, 0xd8, 0xff, 1]),
      mimeType: 'image/jpeg',
      width: 900,
      height: 1800,
    );
  }
}

final class _FakePreferences implements CloudPreviewPreferences {
  _FakePreferences(this.mode);
  CloudImageSyncMode mode;
  bool paused = false;

  @override
  Future<CloudPreviewPreferenceState> load() async =>
      CloudPreviewPreferenceState(mode: mode, userPaused: paused, loaded: true);

  @override
  Future<void> setMode(CloudImageSyncMode value) async => mode = value;

  @override
  Future<void> setUserPaused(bool value) async => paused = value;
}

final class _MemoryCache implements CloudPreviewCache {
  final Map<String, String> paths = {};

  @override
  Future<String?> lookup({
    required String savedItemId,
    required String cloudPath,
  }) async => paths[cloudPath];

  @override
  Future<String> store({
    required String savedItemId,
    required String cloudPath,
    required Uint8List bytes,
  }) async {
    final path = '/cache/$savedItemId.jpg';
    paths[cloudPath] = path;
    return path;
  }

  @override
  Future<void> clear() async => paths.clear();
}
