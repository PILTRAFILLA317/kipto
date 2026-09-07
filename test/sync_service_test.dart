import 'dart:async';

import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/repositories/drift_items_repository.dart';
import 'package:kipto/core/repositories/drift_reminders_repository.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/core/sync/remote_models.dart';
import 'package:kipto/core/sync/sync_service.dart';

import 'test_support.dart';

void main() {
  test(
    'sync pushes Items before Reminders, records the device, and applies LWW',
    () async {
      final now = DateTime.utc(2026, 9, 3, 12);
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final auth = TestAuthRepository();
      final remote = FakeRemoteDataSource();
      final service = SyncService(
        database: database,
        auth: auth,
        remote: remote,
        clock: Clock.fixed(now),
      );
      addTearDown(service.dispose);
      final coordinator = LocalSyncCoordinator(
        database: database,
        auth: auth,
        clock: Clock.fixed(now),
        onLocalChange: () {},
      );
      final items = DriftItemsRepository(
        database,
        syncCoordinator: coordinator,
        clock: Clock.fixed(now),
      );
      final reminders = DriftRemindersRepository(
        database,
        syncCoordinator: coordinator,
        clock: Clock.fixed(now),
        onChanged: () async {},
      );

      await service.initialize();
      final item = await items.create(title: 'Insurance renewal');
      final reminder = await reminders.create(
        itemId: item.id,
        remindAt: now.add(const Duration(days: 3)),
      );
      await service.syncNow();

      expect(remote.devices, hasLength(1));
      expect(remote.items, contains(item.id));
      expect(remote.reminders, contains(reminder.id));
      expect(
        (await items.findById(item.id))?.sourceDeviceId,
        remote.items[item.id]?.sourceDeviceId,
      );
      expect(
        (await reminders.findById(reminder.id))?.sourceDeviceId,
        remote.reminders[reminder.id]?.sourceDeviceId,
      );
      expect(remote.calls, containsAllInOrder(['items', 'reminders']));
      expect(await database.syncQueueDao.pending(), isEmpty);

      final newer = RemoteItem(
        id: item.id,
        userId: testUser.id,
        title: 'Renew the insurance now',
        summary: '',
        status: ItemStatus.active,
        createdAt: now,
        clientUpdatedAt: now.add(const Duration(days: 1)),
        serverUpdatedAt: DateTime.utc(2035),
      );
      remote.items[item.id] = newer;
      await service.syncNow();

      expect((await items.findById(item.id))?.title, newer.title);
      await reminders.delete(reminder.id);
      await service.syncNow();
      expect(remote.reminders[reminder.id]?.deletedAt, isNotNull);
    },
  );
  for (final stop in [false, true]) {
    test(
      'in-flight edit survives old ACK; ${stop ? 'account stop' : 'consent withdrawal'} stops further requests',
      () async {
        final now = DateTime.utc(2026, 9, 5);
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        final auth = TestAuthRepository();
        final remote = _PausedRemote();
        var allowed = true;
        final sync = SyncService(
          database: db,
          auth: auth,
          remote: remote,
          canSync: () => allowed,
        );
        addTearDown(sync.dispose);
        final items = DriftItemsRepository(
          db,
          syncCoordinator: LocalSyncCoordinator(
            database: db,
            auth: auth,
            onLocalChange: () {},
          ),
          clock: Clock.fixed(now),
        );
        final item = await items.create(title: 'Original');
        final running = sync.initialize();
        await remote.started.future;
        await items.setStatus(item.id, ItemStatus.resolved);
        final edited = (await items.findById(item.id))!;
        expect(edited.updatedAt.isAfter(item.updatedAt), isTrue);
        Future<void>? stopping;
        if (stop) {
          stopping = sync.stopForAccountChange();
        } else {
          allowed = false;
        }
        remote.release.complete();
        await running;
        await stopping;
        expect((await items.findById(item.id))!.status, ItemStatus.resolved);
        expect(await db.syncQueueDao.pending(), hasLength(1));
        expect(remote.pulls, 0);
        allowed = true;
        await sync.initialize();
        await sync.syncNow();
        expect(remote.items[item.id]!.status, ItemStatus.resolved);
        expect(await db.syncQueueDao.pending(), isEmpty);
      },
    );
  }

  test('editing during an allowed push is not overwritten by its old ACK or subsequent pull', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final auth = TestAuthRepository();
    final remote = _PausedRemote();
    final sync = SyncService(database: db, auth: auth, remote: remote);
    addTearDown(sync.dispose);
    final items = DriftItemsRepository(
      db,
      syncCoordinator: LocalSyncCoordinator(
        database: db,
        auth: auth,
        onLocalChange: () {},
      ),
    );
    final item = await items.create(title: 'Keep edit');
    final running = sync.initialize();
    await remote.started.future;
    await items.setStatus(item.id, ItemStatus.resolved);
    remote.release.complete();
    await running;
    expect((await items.findById(item.id))!.status, ItemStatus.resolved);
    expect(await db.syncQueueDao.pending(), hasLength(1));
    await sync.syncNow();
    expect(remote.items[item.id]!.status, ItemStatus.resolved);
  });
}

class _PausedRemote extends FakeRemoteDataSource {
  final started = Completer<void>();
  final release = Completer<void>();
  int pulls = 0;
  @override
  Future<List<RemoteItem>> upsertItems(List<RemoteItem> rows) async {
    if (!started.isCompleted) {
      started.complete();
      await release.future;
    }
    return super.upsertItems(rows);
  }

  @override
  Future<List<RemoteItem>> fetchItemsChangedSince({
    DateTime? cursor,
    required int offset,
    required int limit,
  }) {
    pulls++;
    return super.fetchItemsChangedSince(
      cursor: cursor,
      offset: offset,
      limit: limit,
    );
  }
}
