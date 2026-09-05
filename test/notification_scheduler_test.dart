import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/repositories/drift_items_repository.dart';
import 'package:kipto/core/repositories/drift_reminders_repository.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/features/notifications/application/device_time_zone_service.dart';
import 'package:kipto/features/notifications/application/notification_gateway.dart';
import 'package:kipto/features/notifications/application/reminder_notification_scheduler.dart';
import 'package:kipto/features/notifications/data/notification_mapping_store.dart';
import 'package:kipto/features/notifications/domain/notification_models.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'test_support.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);

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
      final gateway = _Gateway();
      final scheduler = ReminderNotificationScheduler(
        gateway: gateway,
        mappings: NotificationMappingStore(database),
        timeZones: const _UtcTimeZones(),
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

final class _Gateway implements ReminderNotificationGateway {
  final List<String> payloads = [];

  @override
  Future<void> cancel(int id) async {}
  @override
  Future<String?> initialize(NotificationPayloadCallback onPayload) async =>
      null;
  @override
  Future<void> openSettings() async {}
  @override
  Future<NotificationPermissionStatus> permissionStatus() async =>
      NotificationPermissionStatus.granted;
  @override
  Future<NotificationPermissionStatus> requestPermission() =>
      permissionStatus();
  @override
  Future<void> schedule({
    required int id,
    required tz.TZDateTime at,
    required String title,
    required String body,
    required String payload,
  }) async => payloads.add(payload);
  @override
  Future<void> showTest() async {}
}

final class _UtcTimeZones implements DeviceTimeZoneService {
  const _UtcTimeZones();

  @override
  Future<String> currentIdentifier() async => 'UTC';
  @override
  tz.Location locationFor(String identifier) => tz.UTC;
}
