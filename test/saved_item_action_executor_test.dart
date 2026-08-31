import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/repositories/drift_reminders_repository.dart';
import 'package:kipto/core/repositories/drift_saved_items_repository.dart';
import 'package:kipto/features/actions/application/device_action_services.dart';
import 'package:kipto/features/actions/application/reminder_action_service.dart';
import 'package:kipto/features/actions/application/saved_item_action_executor.dart';
import 'package:kipto/features/actions/domain/action_execution_result.dart';
import 'package:kipto/features/actions/domain/calendar_event_draft.dart';
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

  test(
    'calendar success records completion without marking item done',
    () async {
      final fixture = await _ExecutorFixture.create(
        const ActionExecutionResult.success('Added to Calendar'),
      );
      addTearDown(fixture.dispose);

      final result = await fixture.executor.execute(fixture.calendarRequest());

      expect(result.isSuccess, isTrue);
      final saved = await fixture.database.savedItemsDao.findById('event');
      expect(saved?.status, isNot(SavedItemStatus.done));
      expect(
        saved?.entities[SavedItem.completedActionsEntityKey],
        contains(SavedItemActionType.addCalendar.storageValue),
      );
    },
  );

  test(
    'missing date draft, cancellation and failure never complete calendar',
    () async {
      final invalid = await _ExecutorFixture.create(
        const ActionExecutionResult.success(),
      );
      final invalidResult = await invalid.executor.execute(
        SavedItemActionRequest(
          item: invalid.item,
          action: SavedItemActionType.addCalendar,
        ),
      );
      expect(invalidResult.status, ActionExecutionStatus.invalidData);
      expect(invalid.calendar.calls, 0);
      await invalid.dispose();

      final cancelled = await _ExecutorFixture.create(
        const ActionExecutionResult.cancelled(),
      );
      expect(
        (await cancelled.executor.execute(cancelled.calendarRequest())).status,
        ActionExecutionStatus.cancelled,
      );
      expect(
        (await cancelled.database.savedItemsDao.findById('event'))
            ?.entities[SavedItem.completedActionsEntityKey],
        isNull,
      );
      await cancelled.dispose();

      final failed = await _ExecutorFixture.create(
        const ActionExecutionResult.failed(errorCode: 'native_failed'),
      );
      expect(
        (await failed.executor.execute(failed.calendarRequest())).status,
        ActionExecutionStatus.failed,
      );
      await failed.dispose();
    },
  );

  test(
    'already completed calendar requires explicit duplicate consent',
    () async {
      final fixture = await _ExecutorFixture.create(
        const ActionExecutionResult.success(),
      );
      addTearDown(fixture.dispose);
      await fixture.savedItems.markActionCompleted(
        fixture.item.id,
        SavedItemActionType.addCalendar,
      );
      final current = await fixture.savedItems.watchById(fixture.item.id).first;

      final blocked = await fixture.executor.execute(
        fixture.calendarRequest(item: current!),
      );
      expect(blocked.status, ActionExecutionStatus.cancelled);
      expect(fixture.calendar.calls, 0);

      final repeated = await fixture.executor.execute(
        fixture.calendarRequest(item: current, allowDuplicate: true),
      );
      expect(repeated.isSuccess, isTrue);
      expect(fixture.calendar.calls, 1);
    },
  );

  test(
    'save favorites the same item and records a synchronized completion',
    () async {
      final fixture = await _ExecutorFixture.create(
        const ActionExecutionResult.success(),
      );
      addTearDown(fixture.dispose);

      final result = await fixture.executor.execute(
        SavedItemActionRequest(
          item: fixture.item,
          action: SavedItemActionType.save,
        ),
      );

      expect(result.isSuccess, isTrue);
      final rows = await fixture.database.savedItemsDao.getActive();
      expect(rows, hasLength(1));
      expect(rows.single.favorite, isTrue);
      expect(
        rows.single.entities[SavedItem.completedActionsEntityKey],
        contains(SavedItemActionType.save.storageValue),
      );
    },
  );
}

final class _ExecutorFixture {
  _ExecutorFixture({
    required this.database,
    required this.savedItems,
    required this.calendar,
    required this.executor,
    required this.item,
    required this.now,
  });

  static Future<_ExecutorFixture> create(
    ActionExecutionResult calendarResult,
  ) async {
    final now = DateTime.utc(2026, 8, 30, 12);
    final database = createTestDatabase();
    final savedItems = DriftSavedItemsRepository(
      database,
      clock: Clock.fixed(now),
    );
    final item = testSavedItem(
      id: 'event',
      now: now,
      category: SavedItemCategory.event,
      eventAt: now.add(const Duration(days: 5)),
      availableActions: const [SavedItemActionType.addCalendar],
    );
    await savedItems.create(item);
    final reminders = DriftRemindersRepository(
      database,
      clock: Clock.fixed(now),
    );
    final scheduler = ReminderNotificationScheduler(
      gateway: _NoopGateway(),
      mappings: NotificationMappingStore(database),
      timeZones: _UtcTimeZones(),
      clock: Clock.fixed(now),
    );
    final reminderActions = ReminderActionService(
      reminders: reminders,
      savedItems: savedItems,
      notifications: scheduler,
      clock: Clock.fixed(now),
    );
    final launcher = _AlwaysLauncher();
    final urls = ExternalUrlService(launcher: launcher);
    final calendar = _CalendarFake(calendarResult);
    final executor = SavedItemActionExecutor(
      calendar: calendar,
      reminders: reminderActions,
      maps: MapsActionService(launcher: launcher),
      urls: urls,
      search: WebSearchActionService(urls: urls),
      clipboard: ClipboardActionService(clipboard: _NoopClipboard()),
      tracking: TrackingActionService(urls: urls),
      savedItems: savedItems,
    );
    return _ExecutorFixture(
      database: database,
      savedItems: savedItems,
      calendar: calendar,
      executor: executor,
      item: item,
      now: now,
    );
  }

  final AppDatabase database;
  final DriftSavedItemsRepository savedItems;
  final _CalendarFake calendar;
  final SavedItemActionExecutor executor;
  final SavedItem item;
  final DateTime now;

  SavedItemActionRequest calendarRequest({
    SavedItem? item,
    bool allowDuplicate = false,
  }) => SavedItemActionRequest(
    item: item ?? this.item,
    action: SavedItemActionType.addCalendar,
    allowCalendarDuplicate: allowDuplicate,
    calendarDraft: CalendarEventDraft(
      title: 'Concert',
      startAt: now.add(const Duration(days: 5)),
      endAt: now.add(const Duration(days: 5, hours: 1)),
      allDay: false,
    ),
  );

  Future<void> dispose() => database.close();
}

final class _CalendarFake implements CalendarActionService {
  _CalendarFake(this.result);
  final ActionExecutionResult result;
  var calls = 0;

  @override
  Future<ActionExecutionResult> present(CalendarEventDraft draft) async {
    calls++;
    return result;
  }
}

final class _AlwaysLauncher implements ExternalLauncher {
  @override
  Future<bool> launch(Uri uri) async => true;
}

final class _NoopClipboard implements ClipboardWriter {
  @override
  Future<void> write(String value) async {}
}

final class _NoopGateway implements ReminderNotificationGateway {
  @override
  Future<String?> initialize(NotificationPayloadCallback onPayload) async =>
      null;
  @override
  Future<NotificationPermissionStatus> permissionStatus() async =>
      NotificationPermissionStatus.denied;
  @override
  Future<NotificationPermissionStatus> requestPermission() async =>
      NotificationPermissionStatus.denied;
  @override
  Future<void> openSettings() async {}
  @override
  Future<void> showTest() async {}
  @override
  Future<void> cancel(int id) async {}
  @override
  Future<void> schedule({
    required int id,
    required tz.TZDateTime at,
    required String title,
    required String body,
    required String payload,
  }) async {}
}

final class _UtcTimeZones implements DeviceTimeZoneService {
  @override
  Future<String> currentIdentifier() async => 'UTC';
  @override
  tz.Location locationFor(String identifier) => tz.UTC;
}
