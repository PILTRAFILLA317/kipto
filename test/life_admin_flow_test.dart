import 'dart:io';

import 'package:kipto/features/analysis/application/analysis_preparer.dart';
import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/files/original_store.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/domain/models/item_action.dart';
import 'package:kipto/core/repositories/drift_items_repository.dart';
import 'package:kipto/core/repositories/drift_sources_repository.dart';
import 'package:kipto/core/repositories/drift_life_admin_repository.dart';
import 'package:kipto/core/repositories/item_queries.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/features/capture/application/capture_service.dart';
import 'package:kipto/features/actions/application/action_service.dart';
import 'package:kipto/features/calendar/application/calendar_action_service.dart';
import 'package:kipto/features/notifications/application/reminder_notification_scheduler.dart';
import 'package:kipto/features/notifications/data/notification_mapping_store.dart';

import 'analysis_queue_test.dart' as ai;
import 'action_service_test.dart' show TestCalendar;
import 'notification_test_support.dart';
import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz.initializeTimeZones);
  test('T22 import, proposal, confirmed alert, reopen, resolve and Archive persist', () async {
    final root = await Directory.systemTemp.createTemp('kipto-full-flow-');
    final disk = File('${root.path}/library.sqlite');
    var db = AppDatabase(NativeDatabase(disk));
    addTearDown(() async {
      await db.close();
      await root.delete(recursive: true);
    });
    final auth = TestAuthRepository();
    LocalSyncCoordinator coordinator() =>
        LocalSyncCoordinator(database: db, auth: auth, onLocalChange: () {});
    final originals = OriginalStore(Directory('${root.path}/originals'));
    final sources = DriftSourcesRepository(db, coordinator());
    final capture = CaptureService(
      files: originals,
      sources: sources,
      scope: () async => auth.userId!,
    );
    await capture.importText(
      captureId: ai.sourceId,
      text: 'Factura sintética: pagar antes del 20/09/2026',
      title: 'Factura sintética',
    );
    expect(await originals.file('${ai.sourceId}/original').exists(), isTrue);
    final queue = ai.makeQueue(
      db,
      auth,
      coordinator(),
      send: (_, body) async => ai.envelope(body),
    );
    await queue.enqueue(ai.sourceId, locale: 'es', timeZone: 'Europe/Madrid');
    await queue.resume();
    expect((await db.select(db.analysisJobs).get()).single.state, 'done');
    expect(await db.select(db.reminders).get(), isEmpty);
    final gateway = TestNotificationGateway();
    ReminderNotificationScheduler scheduler() => ReminderNotificationScheduler(
      gateway: gateway,
      mappings: NotificationMappingStore(db),
      timeZones: const TestTimeZones(),
      clock: Clock.fixed(ai.now),
    );
    final action = (await db.select(db.itemActions).get()).single;
    final service = ActionService(
      repository: DriftLifeAdminRepository(
        db,
        coordinator(),
        clock: Clock.fixed(ai.now),
      ),
      scheduler: scheduler(),
      mappings: NotificationMappingStore(db),
      calendar: TestCalendar(Future.value(CalendarActionResult.cancelled)),
    );
    expect(
      await service.confirm(
        action.id,
        RemindPayload(
          instant: ai.now.add(const Duration(days: 2)),
          zone: 'Europe/Madrid',
        ),
      ),
      ActionOutcome.scheduled,
    );
    expect(gateway.scheduled, hasLength(1));
    final reminderId = (await db.select(db.reminders).get()).single.id;
    queue.dispose();
    await db.close();
    db = AppDatabase(NativeDatabase(disk));
    expect((await db.select(db.reminders).get()).single.id, reminderId);
    final notifications = scheduler();
    await notifications.reconcile();
    expect(
      gateway.scheduleCalls,
      2,
    ); // New scheduler applies current discreet content.
    final items = DriftItemsRepository(
      db,
      syncCoordinator: coordinator(),
      clock: Clock.fixed(ai.now),
      onChanged: notifications.reconcile,
    );
    await items.setStatus(ai.sourceId, ItemStatus.resolved);
    expect(gateway.scheduled, isEmpty);
    expect(await NotificationMappingStore(db).list(), isEmpty);
    expect(
      await ItemQueries(db)
          .search('Factura', auth.userId, archiveOnly: true)
          .first,
      contains(ai.sourceId),
    );
    expect(await originals.file('${ai.sourceId}/original').exists(), isTrue);
    expect((await db.select(db.itemActions).get()).single.id, action.id);
  });

  test(
    'iOS fallback imports the same analysis twice without creating an alert',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final auth = TestAuthRepository();
      final coordinator = await ai.seed(db, auth);
      String? request;
      final queue = ai.makeQueue(
        db,
        auth,
        coordinator,
        send: (_, payload) async {
          request = payload;
          throw const AnalysisFailure('network');
        },
      );
      addTearDown(queue.dispose);
      await queue.enqueue(ai.sourceId, locale: 'es', timeZone: 'Europe/Madrid');
      await queue.resume();
      queue.pause();
      await db.delete(db.analysisJobs).go();
      expect(await db.select(db.facts).get(), isEmpty);
      await queue.importSharedResult(request!, ai.envelope(request!));
      final ids = (await db.select(db.facts).get()).map((f) => f.id).toList();
      expect(ids, hasLength(1));
      await queue.importSharedResult(request!, ai.envelope(request!));
      await queue.importSharedResult(request!, ai.envelope(request!));
      expect((await db.select(db.facts).get()).map((f) => f.id), ids);
      expect(await db.select(db.itemActions).get(), hasLength(1));
      expect(await db.select(db.reminders).get(), isEmpty);
    },
  );
}
