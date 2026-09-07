import 'dart:async';

import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/repositories/drift_items_repository.dart';
import 'package:kipto/core/repositories/drift_reminders_repository.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/features/notifications/application/reminder_notification_scheduler.dart';
import 'package:kipto/features/notifications/data/notification_mapping_store.dart';
import 'package:kipto/features/notifications/domain/notification_models.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'test_support.dart';
import 'notification_test_support.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test(
    'Clearing a projection waits for an older OS scheduling request',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final now = DateTime.utc(2026, 9, 5);
      final coordinator = LocalSyncCoordinator(
        database: db,
        auth: TestAuthRepository(),
        onLocalChange: () {},
      );
      final item = await DriftItemsRepository(
        db,
        syncCoordinator: coordinator,
      ).create(title: 'Synthetic');
      await DriftRemindersRepository(
        db,
        syncCoordinator: coordinator,
        onChanged: () async {},
      ).create(itemId: item.id, remindAt: now.add(const Duration(days: 1)));
      final gateway = TestNotificationGateway()
        ..scheduleEntered = Completer<void>()
        ..scheduleRelease = Completer<void>();
      final mappings = NotificationMappingStore(db);
      final scheduler = ReminderNotificationScheduler(
        gateway: gateway,
        mappings: mappings,
        timeZones: const TestTimeZones(),
        clock: Clock.fixed(now),
      );
      final old = scheduler.reconcile();
      await gateway.scheduleEntered!.future;
      final cleanup = scheduler.clearLocalProjection();
      final concurrent = scheduler.reconcile();
      gateway.scheduleRelease!.complete();
      await Future.wait([old, cleanup, concurrent]);
      expect(gateway.scheduled, isEmpty);
      expect(await mappings.list(), isEmpty);
    },
  );

  test(
    'notification reconciliation follows the reminder item_id relationship',
    () async {
      final now = DateTime.utc(2026, 9, 3, 12);
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
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
      final item = await items.create(title: 'Dentist appointment');
      final reminder = await reminders.create(
        itemId: item.id,
        remindAt: now.add(const Duration(hours: 2)),
      );
      final gateway = TestNotificationGateway();
      final scheduler = ReminderNotificationScheduler(
        gateway: gateway,
        mappings: NotificationMappingStore(database),
        timeZones: const TestTimeZones(),
        clock: Clock.fixed(now),
      );

      await scheduler.reconcile();

      expect(gateway.payloads, hasLength(1));
      final payload = ReminderNotificationPayload.tryParse(
        gateway.payloads.single,
      );
      expect(payload?.itemId, item.id);
      expect(payload?.reminderId, reminder.id);
    },
  );
}
