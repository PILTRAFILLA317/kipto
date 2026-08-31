import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/repositories/drift_reminders_repository.dart';
import 'package:kipto/core/repositories/drift_saved_items_repository.dart';
import 'package:kipto/features/actions/application/reminder_action_service.dart';
import 'package:kipto/features/actions/domain/action_execution_result.dart';
import 'package:kipto/features/notifications/application/device_time_zone_service.dart';
import 'package:kipto/features/notifications/application/notification_gateway.dart';
import 'package:kipto/features/notifications/application/reminder_notification_scheduler.dart';
import 'package:kipto/features/notifications/data/notification_mapping_store.dart';
import 'package:kipto/features/notifications/domain/notification_models.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'test_helpers.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('permission denial still saves and completes reminder action', () async {
    final fixture = await _ReminderFixture.create(
      permission: NotificationPermissionStatus.denied,
    );
    addTearDown(fixture.dispose);

    final result = await fixture.service.create(
      item: fixture.item,
      remindAt: fixture.now.add(const Duration(hours: 1)),
    );

    expect(result.status, ActionExecutionStatus.permissionDenied);
    expect(await fixture.reminders.futurePending(), hasLength(1));
    final saved = await fixture.database.savedItemsDao.findById('item');
    expect(
      saved?.entities[SavedItem.completedActionsEntityKey],
      contains(SavedItemActionType.createReminder.storageValue),
    );
    expect(await fixture.mappings.count(), 0);
  });

  test(
    'first explicit reminder requests permission and schedules locally',
    () async {
      final fixture = await _ReminderFixture.create(
        permission: NotificationPermissionStatus.notDetermined,
        requestedPermission: NotificationPermissionStatus.granted,
      );
      addTearDown(fixture.dispose);

      final result = await fixture.service.create(
        item: fixture.item,
        remindAt: fixture.now.add(const Duration(hours: 1)),
      );

      expect(result.isSuccess, isTrue);
      expect(fixture.gateway.requestCalls, 1);
      expect(fixture.gateway.scheduleCalls, 1);
      expect(await fixture.mappings.count(), 1);
    },
  );

  test(
    'edit reschedules and complete/delete cancel local projection',
    () async {
      final fixture = await _ReminderFixture.create(
        permission: NotificationPermissionStatus.granted,
      );
      addTearDown(fixture.dispose);
      await fixture.service.create(
        item: fixture.item,
        remindAt: fixture.now.add(const Duration(hours: 1)),
      );
      var reminder = (await fixture.reminders.futurePending()).single;
      final firstId = (await fixture.mappings.list()).single.notificationId;

      final editedAt = fixture.now.add(const Duration(hours: 4));
      expect(
        (await fixture.service.edit(reminder, editedAt)).isSuccess,
        isTrue,
      );
      reminder = (await fixture.reminders.futurePending()).single;
      expect(reminder.remindAt, editedAt);
      expect(fixture.gateway.cancelled, contains(firstId));

      expect((await fixture.service.complete(reminder)).isSuccess, isTrue);
      expect(await fixture.mappings.count(), 0);
      expect(await fixture.reminders.futurePending(), isEmpty);

      final second = await fixture.reminders.create(
        savedItemId: fixture.item.id,
        remindAt: fixture.now.add(const Duration(hours: 6)),
      );
      await fixture.scheduler.reconcile();
      expect((await fixture.service.delete(second)).isSuccess, isTrue);
      expect(await fixture.mappings.count(), 0);
    },
  );
}

final class _ReminderFixture {
  _ReminderFixture({
    required this.database,
    required this.savedItems,
    required this.reminders,
    required this.mappings,
    required this.gateway,
    required this.scheduler,
    required this.service,
    required this.item,
    required this.now,
  });

  static Future<_ReminderFixture> create({
    required NotificationPermissionStatus permission,
    NotificationPermissionStatus? requestedPermission,
  }) async {
    final now = DateTime.utc(2026, 8, 30, 12);
    final database = createTestDatabase();
    final savedItems = DriftSavedItemsRepository(
      database,
      clock: Clock.fixed(now),
    );
    var sequence = 0;
    final reminders = DriftRemindersRepository(
      database,
      clock: Clock.fixed(now),
      idGenerator: () => 'reminder-${++sequence}',
    );
    final item = testSavedItem(id: 'item', now: now);
    await savedItems.create(item);
    final mappings = NotificationMappingStore(database);
    final gateway = _ReminderGateway(
      permission,
      requestedPermission ?? permission,
    );
    final scheduler = ReminderNotificationScheduler(
      gateway: gateway,
      mappings: mappings,
      timeZones: _UtcTimeZones(),
      clock: Clock.fixed(now),
    );
    final service = ReminderActionService(
      reminders: reminders,
      savedItems: savedItems,
      notifications: scheduler,
      clock: Clock.fixed(now),
    );
    return _ReminderFixture(
      database: database,
      savedItems: savedItems,
      reminders: reminders,
      mappings: mappings,
      gateway: gateway,
      scheduler: scheduler,
      service: service,
      item: item,
      now: now,
    );
  }

  final AppDatabase database;
  final DriftSavedItemsRepository savedItems;
  final DriftRemindersRepository reminders;
  final NotificationMappingStore mappings;
  final _ReminderGateway gateway;
  final ReminderNotificationScheduler scheduler;
  final ReminderActionService service;
  final SavedItem item;
  final DateTime now;

  Future<void> dispose() => database.close();
}

final class _ReminderGateway implements ReminderNotificationGateway {
  _ReminderGateway(this.permission, this.requestedPermission);

  NotificationPermissionStatus permission;
  final NotificationPermissionStatus requestedPermission;
  var requestCalls = 0;
  var scheduleCalls = 0;
  final List<int> cancelled = [];

  @override
  Future<String?> initialize(NotificationPayloadCallback onPayload) async =>
      null;

  @override
  Future<NotificationPermissionStatus> permissionStatus() async => permission;

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    requestCalls++;
    permission = requestedPermission;
    return permission;
  }

  @override
  Future<void> schedule({
    required int id,
    required tz.TZDateTime at,
    required String title,
    required String body,
    required String payload,
  }) async {
    scheduleCalls++;
  }

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
  }

  @override
  Future<void> openSettings() async {}

  @override
  Future<void> showTest() async {}
}

final class _UtcTimeZones implements DeviceTimeZoneService {
  @override
  Future<String> currentIdentifier() async => 'UTC';

  @override
  tz.Location locationFor(String identifier) => tz.UTC;
}
