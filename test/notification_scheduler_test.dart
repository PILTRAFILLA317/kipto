import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/models/reminder.dart';
import 'package:kipto/core/repositories/drift_reminders_repository.dart';
import 'package:kipto/core/repositories/drift_saved_items_repository.dart';
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

  test('reconcile removes stale mappings and schedules only A and B', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final a = await fixture.addReminder('A', const Duration(hours: 1));
    final b = await fixture.addReminder('B', const Duration(hours: 2));
    final c = await fixture.addReminder('C', const Duration(hours: 3));
    final d = await fixture.addReminder('D', const Duration(hours: 4));
    final x = await fixture.addReminder('X', const Duration(hours: 5));
    await fixture.reminders.complete(c.id);
    await fixture.reminders.delete(d.id);
    await fixture.reminders.delete(x.id);
    await fixture.mappings.put(
      NotificationMapping(
        reminderId: b.id,
        notificationId: 101,
        scheduledFor: b.remindAt,
        timeZone: 'UTC',
      ),
    );
    await fixture.mappings.put(
      NotificationMapping(
        reminderId: c.id,
        notificationId: 102,
        scheduledFor: c.remindAt,
        timeZone: 'UTC',
      ),
    );
    await fixture.mappings.put(
      NotificationMapping(
        reminderId: x.id,
        notificationId: 103,
        scheduledFor: x.remindAt,
        timeZone: 'UTC',
      ),
    );

    await fixture.scheduler.reconcile();

    final mappings = await fixture.mappings.list();
    expect(mappings.map((mapping) => mapping.reminderId).toSet(), {a.id, b.id});
    expect(fixture.gateway.cancelled, containsAll([102, 103]));
    expect(fixture.gateway.scheduled.values.single.reminderId, a.id);
  });

  test('reconcile is idempotent and never duplicates notifications', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    await fixture.addReminder('A', const Duration(hours: 1));

    await fixture.scheduler.reconcile();
    await fixture.scheduler.reconcile();
    await fixture.scheduler.reconcile();

    expect(fixture.gateway.scheduleCalls, 1);
    expect(await fixture.mappings.count(), 1);
  });

  test('only the next 50 of 100 future reminders are scheduled', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    for (var index = 0; index < 100; index++) {
      await fixture.addReminder('item-$index', Duration(minutes: index + 1));
    }

    await fixture.scheduler.reconcile();

    expect(fixture.gateway.scheduled, hasLength(50));
    final scheduledReminderIds = fixture.gateway.scheduled.values
        .map((value) => value.reminderId)
        .toSet();
    expect(scheduledReminderIds, contains('reminder-1'));
    expect(scheduledReminderIds, contains('reminder-50'));
    expect(scheduledReminderIds, isNot(contains('reminder-51')));
  });

  test('timezone change reprograms the same instant', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final reminder = await fixture.addReminder('A', const Duration(hours: 2));
    await fixture.scheduler.reconcile();
    final first = fixture.gateway.scheduled.values.single;

    fixture.timeZones.identifier = 'Europe/Madrid';
    await fixture.scheduler.reconcile();

    final mapping = (await fixture.mappings.list()).single;
    expect(mapping.timeZone, 'Europe/Madrid');
    expect(mapping.scheduledFor, reminder.remindAt);
    expect(fixture.gateway.scheduleCalls, 2);
    expect(fixture.gateway.cancelled, contains(first.id));
  });

  test('denied permission leaves the Reminder row and no mapping', () async {
    final fixture = await _Fixture.create(
      permission: NotificationPermissionStatus.denied,
    );
    addTearDown(fixture.dispose);
    final reminder = await fixture.addReminder('A', const Duration(hours: 1));

    await fixture.scheduler.reconcile();

    expect(
      await fixture.database.remindersDao.findById(reminder.id),
      isNotNull,
    );
    expect(await fixture.mappings.count(), 0);
    expect(fixture.gateway.scheduleCalls, 0);
  });

  test('notification payload is minimal and rejects malformed input', () {
    const payload = ReminderNotificationPayload(
      savedItemId: 'item-A',
      reminderId: 'reminder-A',
    );
    final parsed = ReminderNotificationPayload.tryParse(payload.encode());
    expect(parsed?.savedItemId, 'item-A');
    expect(parsed?.reminderId, 'reminder-A');
    expect(ReminderNotificationPayload.tryParse('{bad'), isNull);
    expect(payload.encode(), isNot(contains('savedItemTitle')));
  });

  test(
    'cold-start launch payload is retained through initialization',
    () async {
      final fixture = await _Fixture.create();
      addTearDown(fixture.dispose);
      fixture.gateway.initialPayload = const ReminderNotificationPayload(
        savedItemId: 'item-A',
        reminderId: 'reminder-A',
      ).encode();

      final payload = await fixture.scheduler.initialize((_) {});

      expect(payload, fixture.gateway.initialPayload);
    },
  );
}

final class _Fixture {
  _Fixture({
    required this.database,
    required this.savedItems,
    required this.reminders,
    required this.mappings,
    required this.gateway,
    required this.timeZones,
    required this.scheduler,
    required this.now,
  });

  static Future<_Fixture> create({
    NotificationPermissionStatus permission =
        NotificationPermissionStatus.granted,
  }) async {
    final now = DateTime.utc(2026, 8, 30, 12);
    final database = createTestDatabase();
    var reminderId = 0;
    final savedItems = DriftSavedItemsRepository(
      database,
      clock: Clock.fixed(now),
    );
    final reminders = DriftRemindersRepository(
      database,
      clock: Clock.fixed(now),
      idGenerator: () => 'reminder-${++reminderId}',
    );
    final mappings = NotificationMappingStore(database);
    final gateway = _FakeGateway(permission);
    final timeZones = _FakeTimeZones();
    final scheduler = ReminderNotificationScheduler(
      gateway: gateway,
      mappings: mappings,
      timeZones: timeZones,
      clock: Clock.fixed(now),
    );
    return _Fixture(
      database: database,
      savedItems: savedItems,
      reminders: reminders,
      mappings: mappings,
      gateway: gateway,
      timeZones: timeZones,
      scheduler: scheduler,
      now: now,
    );
  }

  final AppDatabase database;
  final DriftSavedItemsRepository savedItems;
  final DriftRemindersRepository reminders;
  final NotificationMappingStore mappings;
  final _FakeGateway gateway;
  final _FakeTimeZones timeZones;
  final ReminderNotificationScheduler scheduler;
  final DateTime now;

  Future<Reminder> addReminder(String itemId, Duration after) async {
    await savedItems.create(testSavedItem(id: itemId, now: now));
    return reminders.create(savedItemId: itemId, remindAt: now.add(after));
  }

  Future<void> dispose() => database.close();
}

final class _ScheduledCall {
  const _ScheduledCall({
    required this.id,
    required this.at,
    required this.reminderId,
  });

  final int id;
  final tz.TZDateTime at;
  final String reminderId;
}

final class _FakeGateway implements ReminderNotificationGateway {
  _FakeGateway(this.permission);

  NotificationPermissionStatus permission;
  final Map<int, _ScheduledCall> scheduled = {};
  final List<int> cancelled = [];
  var scheduleCalls = 0;
  String? initialPayload;

  @override
  Future<String?> initialize(NotificationPayloadCallback onPayload) async =>
      initialPayload;

  @override
  Future<NotificationPermissionStatus> permissionStatus() async => permission;

  @override
  Future<NotificationPermissionStatus> requestPermission() async => permission;

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
    scheduleCalls++;
    final decoded = ReminderNotificationPayload.tryParse(payload)!;
    scheduled[id] = _ScheduledCall(
      id: id,
      at: at,
      reminderId: decoded.reminderId,
    );
  }

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    scheduled.remove(id);
  }

  @override
  Future<void> showTest() async {}
}

final class _FakeTimeZones implements DeviceTimeZoneService {
  String identifier = 'UTC';

  @override
  Future<String> currentIdentifier() async => identifier;

  @override
  tz.Location locationFor(String identifier) =>
      identifier == 'UTC' ? tz.UTC : tz.getLocation(identifier);
}
