import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/auth/kipto_auth_state.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/repositories/drift_reminders_repository.dart';
import 'package:kipto/core/repositories/drift_saved_items_repository.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/core/sync/remote_models.dart';
import 'package:kipto/core/sync/sync_service.dart';
import 'package:kipto/core/sync/sync_status.dart';
import 'package:kipto/dev/seed/development_seed.dart';
import 'package:kipto/features/notifications/application/device_time_zone_service.dart';
import 'package:kipto/features/notifications/application/notification_gateway.dart';
import 'package:kipto/features/notifications/application/reminder_notification_scheduler.dart';
import 'package:kipto/features/notifications/data/notification_mapping_store.dart';
import 'package:kipto/features/notifications/domain/notification_models.dart';
import 'package:timezone/timezone.dart' as tz;

import 'fakes/fake_sync_dependencies.dart';
import 'test_helpers.dart';

void main() {
  const identity = KiptoUser(id: 'user-a', isAnonymous: true);
  final now = DateTime.utc(2026, 8, 29, 12);

  test(
    'claims real pre-auth data, excludes demo seed, and registers device',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      await DevelopmentSeed(database, clock: Clock.fixed(now)).run();
      final local = DriftSavedItemsRepository(database);
      for (var index = 0; index < 3; index++) {
        await local.create(testSavedItem(id: 'real-$index', now: now));
      }
      final remote = FakeRemoteDataSource();
      final service = SyncService(
        database: database,
        auth: FakeAuthRepository(identity),
        remote: remote,
      );
      addTearDown(service.dispose);

      await service.initialize();

      expect(remote.savedItems.keys, {'real-0', 'real-1', 'real-2'});
      expect(remote.devices, hasLength(1));
      for (final id in DevelopmentSeed.knownItemIds) {
        expect((await database.savedItemsDao.findById(id))?.ownerId, isNull);
      }
      expect(await database.syncQueueDao.pending(), isEmpty);
    },
  );

  test(
    'local writes are atomic, coalesced, batched, and soft-delete remotely',
    () async {
      final harness = await _Harness.create(identity: identity);
      addTearDown(harness.dispose);
      final repository = harness.savedRepository;
      await repository.create(testSavedItem(id: 'item', now: now));
      await repository.toggleFavorite('item');
      await repository.toggleFavorite('item');
      await repository.archive('item');
      expect(await harness.database.syncQueueDao.pending(), hasLength(4));

      await harness.service.syncNow();
      expect(harness.remote.savedUpsertCalls, 1);
      expect(
        harness.remote.savedItems['item']?.status,
        SavedItemStatus.archived,
      );
      expect(await harness.database.syncQueueDao.pending(), isEmpty);

      await repository.softDelete('item');
      await harness.service.syncNow();
      expect(harness.remote.savedItems['item']?.deletedAt, isNotNull);
      expect(
        await repository.watchAll().first,
        isEmpty,
        reason: 'normal queries hide synchronized tombstones',
      );
    },
  );

  test(
    'pull inserts cloud-only items and preserves device-local image fields',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final localItem = _localItem(
        id: 'preserved',
        now: now,
        ownerId: identity.id,
        localAssetId: 'asset-1',
        previewCachePath: '/tmp/preview',
        originalAvailable: true,
      );
      await DriftSavedItemsRepository(database).create(localItem);
      final remote = FakeRemoteDataSource();
      remote.savedItems['preserved'] = _remoteItem(
        id: 'preserved',
        clientUpdatedAt: now.add(const Duration(minutes: 1)),
        serverUpdatedAt: now.add(const Duration(minutes: 2)),
        title: 'Remote wins',
      );
      remote.savedItems['cloud-only'] = _remoteItem(
        id: 'cloud-only',
        clientUpdatedAt: now,
        serverUpdatedAt: now.add(const Duration(minutes: 3)),
        cloudPreviewPath: 'user-a/cloud-only/preview-v1.jpg',
      );
      final service = SyncService(
        database: database,
        auth: FakeAuthRepository(identity),
        remote: remote,
      );
      addTearDown(service.dispose);

      await service.initialize();

      final preserved = await database.savedItemsDao.findById('preserved');
      expect(preserved?.title, 'Remote wins');
      expect(preserved?.localAssetId, 'asset-1');
      expect(preserved?.previewCachePath, '/tmp/preview');
      expect(preserved?.originalAvailable, isTrue);
      final cloudOnly = await database.savedItemsDao.findById('cloud-only');
      expect(cloudOnly?.localAssetId, isNull);
      expect(cloudOnly?.originalAvailable, isFalse);
      expect(cloudOnly?.cloudPreviewPath, 'user-a/cloud-only/preview-v1.jpg');
    },
  );

  test(
    'create then delete before first push never creates a cloud row',
    () async {
      final harness = await _Harness.create(identity: identity);
      addTearDown(harness.dispose);
      await harness.savedRepository.create(
        testSavedItem(id: 'ephemeral', now: now),
      );
      await harness.savedRepository.softDelete('ephemeral');

      await harness.service.syncNow();

      expect(harness.remote.savedItems, isNot(contains('ephemeral')));
      expect(await harness.database.syncQueueDao.pending(), isEmpty);
    },
  );

  test('last-write-wins keeps newer local and applies newer remote', () async {
    final harness = await _Harness.create(identity: identity);
    addTearDown(harness.dispose);
    await harness.savedRepository.create(
      testSavedItem(id: 'conflict', now: now),
    );
    harness.remote.savedItems['conflict'] = _remoteItem(
      id: 'conflict',
      clientUpdatedAt: now.subtract(const Duration(days: 2)),
      serverUpdatedAt: now,
      title: 'Older remote',
    );
    await harness.service.syncNow();
    expect(harness.remote.savedItems['conflict']?.title, 'Test item');

    await harness.savedRepository.toggleFavorite('conflict');
    harness.remote.savedItems['conflict'] = _remoteItem(
      id: 'conflict',
      clientUpdatedAt: now.add(const Duration(days: 2)),
      serverUpdatedAt: now.add(const Duration(days: 2)),
      title: 'Newer remote',
    );
    await harness.service.syncNow();
    expect(
      (await harness.database.savedItemsDao.findById('conflict'))?.title,
      'Newer remote',
    );
    expect(await harness.database.syncQueueDao.pending(), isEmpty);
  });

  test(
    'reminders create, complete, and tombstone after saved item push',
    () async {
      final harness = await _Harness.create(identity: identity);
      addTearDown(harness.dispose);
      await harness.savedRepository.create(
        testSavedItem(id: 'parent', now: now),
      );
      final reminder = await harness.remindersRepository.create(
        savedItemId: 'parent',
        remindAt: now.add(const Duration(days: 1)),
      );
      await harness.service.syncNow();
      expect(harness.remote.savedItems, contains('parent'));
      expect(harness.remote.reminders, contains(reminder.id));

      await harness.remindersRepository.complete(reminder.id);
      await harness.service.syncNow();
      expect(harness.remote.reminders[reminder.id]?.completedAt, isNotNull);
      await harness.remindersRepository.delete(reminder.id);
      await harness.service.syncNow();
      expect(harness.remote.reminders[reminder.id]?.deletedAt, isNotNull);
    },
  );

  test('incremental pull advances only from server timestamps', () async {
    final harness = await _Harness.create(identity: identity);
    addTearDown(harness.dispose);
    final firstServerTime = DateTime.utc(2032, 1, 1);
    harness.remote.savedItems['first'] = _remoteItem(
      id: 'first',
      clientUpdatedAt: now,
      serverUpdatedAt: firstServerTime,
    );
    await harness.service.syncNow();
    harness.remote.savedItems['stale'] = _remoteItem(
      id: 'stale',
      clientUpdatedAt: now,
      serverUpdatedAt: firstServerTime.subtract(const Duration(minutes: 1)),
    );
    final newest = firstServerTime.add(const Duration(seconds: 10));
    harness.remote.savedItems['newer'] = _remoteItem(
      id: 'newer',
      clientUpdatedAt: now,
      serverUpdatedAt: newest,
    );

    await harness.service.syncNow();

    expect(await harness.database.savedItemsDao.findById('newer'), isNotNull);
    expect(await harness.database.savedItemsDao.findById('stale'), isNull);
    final state = await harness.database
        .select(harness.database.cloudSyncStates)
        .getSingle();
    expect(state.lastSavedItemsCursor, newest);
  });

  test(
    'a different authenticated user never claims another owner data',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      await DriftSavedItemsRepository(database).create(
        _localItem(
          id: 'owned-by-a',
          now: now,
          ownerId: 'user-a',
          localAssetId: 'asset-a',
          previewCachePath: '/tmp/a',
          originalAvailable: true,
        ),
      );
      await database
          .into(database.cloudSyncStates)
          .insert(
            CloudSyncStatesCompanion.insert(
              installationId: 'installation-a',
              userId: const Value('user-a'),
            ),
          );
      final remote = FakeRemoteDataSource();
      final service = SyncService(
        database: database,
        auth: FakeAuthRepository(
          const KiptoUser(id: 'user-b', isAnonymous: true),
        ),
        remote: remote,
      );
      addTearDown(service.dispose);

      await service.initialize();

      expect(
        (await database.savedItemsDao.findById('owned-by-a'))?.ownerId,
        'user-a',
      );
      expect(remote.savedItems, isEmpty);
      expect(service.currentStatus.phase, SyncPhase.offlineOrFailed);
    },
  );

  test('offline failure keeps data and queue, then retry converges', () async {
    final harness = await _Harness.create(identity: identity);
    addTearDown(harness.dispose);
    await harness.savedRepository.create(
      testSavedItem(id: 'offline', now: now),
    );
    harness.remote.fail = true;
    await harness.service.syncNow();
    expect(await harness.database.syncQueueDao.pending(), isNotEmpty);
    expect(harness.service.currentStatus.phase, SyncPhase.offlineOrFailed);
    expect(await harness.database.savedItemsDao.findById('offline'), isNotNull);

    harness.remote.fail = false;
    await harness.service.syncNow(SyncReason.retry);
    expect(await harness.database.syncQueueDao.pending(), isEmpty);
    expect(harness.remote.savedItems, contains('offline'));
  });

  test('concurrent sync requests never run remote work concurrently', () async {
    final harness = await _Harness.create(identity: identity);
    addTearDown(harness.dispose);
    harness.remote.delay = const Duration(milliseconds: 20);
    await harness.savedRepository.create(testSavedItem(id: 'one', now: now));
    await Future.wait([
      harness.service.syncNow(),
      harness.service.syncNow(),
      harness.service.syncNow(),
    ]);
    expect(harness.remote.maxActiveCalls, 1);
  });

  test('realtime invalidation triggers normal debounced pull', () async {
    final harness = await _Harness.create(identity: identity);
    addTearDown(harness.dispose);
    harness.remote.savedItems['broadcast-item'] = _remoteItem(
      id: 'broadcast-item',
      clientUpdatedAt: now,
      serverUpdatedAt: now,
    );
    harness.remote.invalidations.add(null);
    await Future<void>.delayed(const Duration(milliseconds: 750));
    expect(
      await harness.database.savedItemsDao.findById('broadcast-item'),
      isNotNull,
    );
  });

  test(
    'save favorites one item and reaches cloud through the sync queue',
    () async {
      final harness = await _Harness.create(identity: identity);
      addTearDown(harness.dispose);
      await harness.savedRepository.create(
        testSavedItem(id: 'saved', now: now),
      );
      await harness.service.syncNow();

      await harness.savedRepository.save('saved');

      expect(await harness.database.syncQueueDao.pending(), hasLength(1));
      expect(await harness.database.savedItemsDao.getActive(), hasLength(1));
      await harness.service.syncNow();
      final remote = harness.remote.savedItems['saved'];
      expect(remote?.favorite, isTrue);
      expect(
        remote?.entities[SavedItem.completedActionsEntityKey],
        contains(SavedItemActionType.save.storageValue),
      );
    },
  );

  test(
    'remote reminder pull schedules its device-local notification',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final remote = FakeRemoteDataSource();
      remote.savedItems['parent'] = _remoteItem(
        id: 'parent',
        clientUpdatedAt: now,
        serverUpdatedAt: now,
      );
      remote.reminders['remote-reminder'] = RemoteReminder(
        id: 'remote-reminder',
        userId: identity.id,
        savedItemId: 'parent',
        remindAt: now.add(const Duration(days: 1)),
        kind: ReminderKind.followUp,
        clientUpdatedAt: now,
        serverUpdatedAt: now.add(const Duration(seconds: 1)),
        createdAt: now,
      );
      final notificationGateway = _SyncNotificationGateway();
      final mappingStore = NotificationMappingStore(database);
      final notificationScheduler = ReminderNotificationScheduler(
        gateway: notificationGateway,
        mappings: mappingStore,
        timeZones: _UtcTimeZoneService(),
        clock: Clock.fixed(now),
      );
      final service = SyncService(
        database: database,
        auth: FakeAuthRepository(identity),
        remote: remote,
        onRemindersChanged: notificationScheduler.reconcile,
      );
      addTearDown(service.dispose);

      await service.initialize();

      expect(
        await database.remindersDao.findById('remote-reminder'),
        isNotNull,
      );
      expect(notificationGateway.scheduledReminderIds, ['remote-reminder']);
      expect(await mappingStore.count(), 1);
    },
  );
}

final class _SyncNotificationGateway implements ReminderNotificationGateway {
  final List<String> scheduledReminderIds = [];

  @override
  Future<String?> initialize(NotificationPayloadCallback onPayload) async =>
      null;

  @override
  Future<NotificationPermissionStatus> permissionStatus() async =>
      NotificationPermissionStatus.granted;

  @override
  Future<NotificationPermissionStatus> requestPermission() async =>
      NotificationPermissionStatus.granted;

  @override
  Future<void> openSettings() async {}

  @override
  Future<void> schedule({
    required int id,
    required tz.TZDateTime at,
    required String title,
    required String body,
    required String payload,
  }) async {
    scheduledReminderIds.add(
      ReminderNotificationPayload.tryParse(payload)!.reminderId,
    );
  }

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> showTest() async {}
}

final class _UtcTimeZoneService implements DeviceTimeZoneService {
  @override
  Future<String> currentIdentifier() async => 'UTC';

  @override
  tz.Location locationFor(String identifier) => tz.UTC;
}

final class _Harness {
  _Harness({
    required this.database,
    required this.remote,
    required this.service,
    required this.savedRepository,
    required this.remindersRepository,
  });

  static Future<_Harness> create({required KiptoUser identity}) async {
    final database = createTestDatabase();
    final auth = FakeAuthRepository(identity);
    final remote = FakeRemoteDataSource();
    final service = SyncService(database: database, auth: auth, remote: remote);
    await service.initialize();
    final coordinator = LocalSyncCoordinator(
      database: database,
      auth: auth,
      onLocalChange: () {},
    );
    return _Harness(
      database: database,
      remote: remote,
      service: service,
      savedRepository: DriftSavedItemsRepository(
        database,
        syncCoordinator: coordinator,
      ),
      remindersRepository: DriftRemindersRepository(
        database,
        syncCoordinator: coordinator,
      ),
    );
  }

  final AppDatabase database;
  final FakeRemoteDataSource remote;
  final SyncService service;
  final DriftSavedItemsRepository savedRepository;
  final DriftRemindersRepository remindersRepository;

  Future<void> dispose() async {
    await service.dispose();
    await database.close();
  }
}

SavedItem _localItem({
  required String id,
  required DateTime now,
  required String ownerId,
  required String localAssetId,
  required String previewCachePath,
  required bool originalAvailable,
}) {
  final base = testSavedItem(id: id, now: now);
  return SavedItem(
    id: base.id,
    ownerId: ownerId,
    title: base.title,
    summary: base.summary,
    category: base.category,
    subtype: base.subtype,
    intent: base.intent,
    status: base.status,
    favorite: base.favorite,
    capturedAt: base.capturedAt,
    expiresAt: base.expiresAt,
    entities: base.entities,
    availableActions: base.availableActions,
    analysisStatus: base.analysisStatus,
    analysisVersion: base.analysisVersion,
    confidence: base.confidence,
    createdAt: base.createdAt,
    updatedAt: base.updatedAt,
    localAssetId: localAssetId,
    previewCachePath: previewCachePath,
    originalAvailable: originalAvailable,
    syncStatus: SyncStatus.synced,
  );
}

RemoteSavedItem _remoteItem({
  required String id,
  required DateTime clientUpdatedAt,
  required DateTime serverUpdatedAt,
  String title = 'Cloud item',
  String? cloudPreviewPath,
}) => RemoteSavedItem(
  id: id,
  userId: 'user-a',
  title: title,
  summary: 'Cloud summary',
  category: SavedItemCategory.information,
  status: SavedItemStatus.newItem,
  favorite: false,
  capturedAt: clientUpdatedAt,
  entities: const {},
  availableActions: const [],
  cloudPreviewPath: cloudPreviewPath,
  analysisStatus: AnalysisStatus.unprocessed,
  analysisVersion: 0,
  clientUpdatedAt: clientUpdatedAt,
  serverUpdatedAt: serverUpdatedAt,
  createdAt: clientUpdatedAt,
);
