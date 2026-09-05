import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/repositories/drift_items_repository.dart';
import 'package:kipto/core/repositories/drift_reminders_repository.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';

import 'test_support.dart';

void main() {
  test(
    'Item and Reminder writes are local-first and coalesce per entity',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final now = DateTime.utc(2026, 9, 3, 12);
      final coordinator = LocalSyncCoordinator(
        database: database,
        auth: TestAuthRepository(),
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

      final item = await items.create(title: '  Renew policy  ');
      await items.setStatus(item.id, ItemStatus.resolved);
      final pendingItemWrites = await database.syncQueueDao.pending();

      expect(item.title, 'Renew policy');
      expect(
        pendingItemWrites.where((entry) => entry.entityId == item.id),
        hasLength(1),
      );
      expect(pendingItemWrites.single.operation, SyncOperation.update);
      expect((await items.findById(item.id))?.status, ItemStatus.resolved);

      final reminder = await reminders.create(
        itemId: item.id,
        remindAt: now.add(const Duration(days: 1)),
      );
      await reminders.complete(reminder.id);
      final pendingReminderWrites = (await database.syncQueueDao.pending())
          .where((entry) => entry.entityId == reminder.id)
          .toList();

      expect(reminder.itemId, item.id);
      expect(pendingReminderWrites, hasLength(1));
      expect(pendingReminderWrites.single.operation, SyncOperation.update);
      expect((await reminders.findById(reminder.id))?.completedAt, isNotNull);
    },
  );
}
