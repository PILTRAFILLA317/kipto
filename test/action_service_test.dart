import 'dart:async';

import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/domain/models/item_action.dart';
import 'package:kipto/core/repositories/drift_items_repository.dart';
import 'package:kipto/core/repositories/drift_life_admin_repository.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/features/actions/application/action_service.dart';
import 'package:kipto/features/calendar/application/calendar_action_service.dart';
import 'package:kipto/features/notifications/application/reminder_notification_scheduler.dart';
import 'package:kipto/features/notifications/data/notification_mapping_store.dart';
import 'package:kipto/features/notifications/domain/notification_models.dart';

import 'test_support.dart';
import 'notification_test_support.dart';

class TestCalendar implements CalendarActionService {
  TestCalendar(this.result);
  final Future<CalendarActionResult> result;
  int calls = 0;
  @override
  Future<CalendarActionResult> present(CalendarEventDraft draft) {
    calls++;
    return result;
  }
}

void main() {
  setUpAll(tz_data.initializeTimeZones);
  test('T11 denied permission preserves one reminder; resolve cancels projection and undo reschedules only future', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime.utc(2026, 9, 5);
    final clock = Clock.fixed(now);
    final coordinator = LocalSyncCoordinator(
      database: db,
      auth: TestAuthRepository(),
      onLocalChange: () {},
    );
    final mappings = NotificationMappingStore(db);
    final gateway = TestNotificationGateway()
      ..permission = NotificationPermissionStatus.denied;
    final scheduler = ReminderNotificationScheduler(
      gateway: gateway,
      mappings: mappings,
      timeZones: const TestTimeZones(),
      clock: clock,
    );
    final items = DriftItemsRepository(
      db,
      syncCoordinator: coordinator,
      clock: clock,
      onChanged: scheduler.reconcile,
    );
    final item = await items.create(title: 'Cita sintética');
    final repository = DriftLifeAdminRepository(db, coordinator, clock: clock);
    await repository.propose(
      ItemAction(
        id: 'remind',
        itemId: item.id,
        ownerId: item.ownerId,
        title: 'Cita',
        payload: RemindPayload(),
        origin: ActionOrigin.user,
        createdAt: now,
        updatedAt: now,
      ),
    );
    final service = ActionService(
      repository: repository,
      scheduler: scheduler,
      mappings: mappings,
      calendar: TestCalendar(Future.value(CalendarActionResult.cancelled)),
    );
    final payload = RemindPayload(
      instant: now.add(const Duration(days: 1)),
      zone: 'Europe/Madrid',
    );
    expect(
      await service.confirm('remind', payload),
      ActionOutcome.savedNotScheduled,
    );
    expect(
      await service.confirm('remind', payload),
      ActionOutcome.savedNotScheduled,
    );
    expect(await db.select(db.reminders).get(), hasLength(1));
    expect(gateway.scheduled, isEmpty);
    expect((await items.findById(item.id))!.status, ItemStatus.active);
    gateway.permission = NotificationPermissionStatus.granted;
    gateway.failSchedule = true;
    expect(
      await service.confirm('remind', payload),
      ActionOutcome.savedNotScheduled,
    );
    expect(await mappings.list(), hasLength(1));
    expect(await scheduler.scheduledCount(), 0);
    gateway.failSchedule = false;
    expect(await service.confirm('remind', payload), ActionOutcome.scheduled);
    expect(await service.confirm('remind', payload), ActionOutcome.scheduled);
    expect(gateway.scheduleCalls, 2);
    expect(gateway.scheduled, hasLength(1));
    await expectLater(
      items.setStatus(item.id, ItemStatus.archived),
      throwsStateError,
    );
    expect(gateway.scheduled, hasLength(1));
    await items.setStatus(item.id, ItemStatus.resolved);
    expect(gateway.scheduled, isEmpty);
    expect(await mappings.list(), isEmpty);
    await items.setStatus(item.id, ItemStatus.active);
    expect(gateway.scheduled, hasLength(1));
    expect(gateway.scheduleCalls, 3);
    await items.setStatus(item.id, ItemStatus.archived, cancelReminders: true);
    expect(gateway.scheduled, isEmpty);
    await items.setStatus(item.id, ItemStatus.active);
    expect(gateway.scheduled, isEmpty);
  });
  test('T12 calendar cancellation/launch/save stay distinct; double tap opens once; Keep creates no reminders', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime.utc(2026, 9, 5);
    final clock = Clock.fixed(now);
    final coordinator = LocalSyncCoordinator(
      database: db,
      auth: TestAuthRepository(),
      onLocalChange: () {},
    );
    final repository = DriftLifeAdminRepository(db, coordinator, clock: clock);
    final items = DriftItemsRepository(
      db,
      syncCoordinator: coordinator,
      clock: clock,
    );
    final item = await items.create(title: 'Evento sintético');
    final mappings = NotificationMappingStore(db);
    final scheduler = ReminderNotificationScheduler(
      gateway: TestNotificationGateway(),
      mappings: mappings,
      timeZones: const TestTimeZones(),
      clock: clock,
    );
    final payload = EventPayload(
      allDay: false,
      start: now.add(const Duration(days: 2)),
      end: now.add(const Duration(days: 2, hours: 1)),
      zone: 'Europe/Madrid',
    );
    for (final result in [
      CalendarActionResult.cancelled,
      CalendarActionResult.launched,
      CalendarActionResult.saved,
    ]) {
      final id = result.name;
      await repository.propose(
        ItemAction(
          id: id,
          itemId: item.id,
          ownerId: item.ownerId,
          title: 'Cita',
          payload: EventPayload(allDay: false),
          origin: ActionOrigin.user,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final response = Completer<CalendarActionResult>();
      final calendar = TestCalendar(response.future);
      final service = ActionService(
        repository: repository,
        scheduler: scheduler,
        mappings: mappings,
        calendar: calendar,
      );
      final first = service.confirm(id, payload);
      expect(await service.confirm(id, payload), ActionOutcome.busy);
      response.complete(result);
      await first;
      final action = (await repository.findAction(id))!;
      expect(calendar.calls, 1);
      if (result == CalendarActionResult.cancelled) {
        expect(action.state, ActionState.proposed);
        expect(action.executionState, ActionExecutionState.notRequested);
      }
      if (result == CalendarActionResult.launched) {
        expect(action.executionState, ActionExecutionState.launchedUnconfirmed);
      }
      if (result == CalendarActionResult.saved) {
        expect(action.executionState, ActionExecutionState.applied);
      }
    }
    await repository.propose(
      ItemAction(
        id: 'keep',
        itemId: item.id,
        ownerId: item.ownerId,
        title: 'Guardar',
        payload: const KeepPayload(),
        origin: ActionOrigin.user,
        createdAt: now,
        updatedAt: now,
      ),
    );
    final service = ActionService(
      repository: repository,
      scheduler: scheduler,
      mappings: mappings,
      calendar: TestCalendar(Future.value(CalendarActionResult.unavailable)),
    );
    expect(
      await service.confirm('keep', const KeepPayload()),
      ActionOutcome.kept,
    );
    expect(await db.select(db.reminders).get(), isEmpty);
    expect((await items.findById(item.id))!.status, ItemStatus.archived);
  });
}
