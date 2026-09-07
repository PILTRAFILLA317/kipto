import 'dart:async';

import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/presentation/widgets/kipto_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:kipto/app/theme/app_theme.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/models/fact.dart';
import 'package:kipto/core/domain/models/fact_value.dart';
import 'package:kipto/core/domain/models/item_action.dart';
import 'package:kipto/core/providers/repository_providers.dart';
import 'package:kipto/core/repositories/drift_items_repository.dart';
import 'package:kipto/core/repositories/drift_life_admin_repository.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/features/actions/application/action_service.dart';
import 'package:kipto/features/actions/presentation/action_feedback.dart';
import 'package:kipto/features/actions/presentation/action_providers.dart';
import 'package:kipto/features/actions/presentation/item_actions_panel.dart';
import 'package:kipto/features/calendar/application/calendar_action_service.dart';
import 'package:kipto/features/items/presentation/widgets/fact_card.dart';
import 'package:kipto/features/notifications/application/reminder_notification_scheduler.dart';
import 'package:kipto/features/notifications/data/notification_mapping_store.dart';
import 'package:kipto/features/notifications/domain/notification_models.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';
import 'package:kipto/l10n/app_localizations.dart';

import 'notification_test_support.dart';
import 'test_support.dart';

class _DeferredCalendar implements CalendarActionService {
  final entered = Completer<void>();
  final result = Completer<CalendarActionResult>();
  int calls = 0;
  @override
  Future<CalendarActionResult> present(CalendarEventDraft draft) {
    calls++;
    if (!entered.isCompleted) entered.complete();
    return result.future;
  }
}

Widget _app(Widget child, bool reduced) => MaterialApp(
  locale: const Locale('es'),
  theme: AppTheme.dark(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      disableAnimations: reduced,
      textScaler: const TextScaler.linear(2),
    ),
    child: child!,
  ),
  home: Scaffold(
    body: SafeArea(child: SingleChildScrollView(child: child)),
  ),
);

Future<void> _driveUntil(WidgetTester tester, bool Function() ready) async {
  for (var attempt = 0; attempt < 100 && !ready(); attempt++) {
    // Drift stream notifications also need the widget test's fake microtasks.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 20));
  }
  expect(ready(), isTrue);
}

void main() {
  setUpAll(tz_data.initializeTimeZones);
  for (final reduced in [false, true]) {
    testWidgets(
      'T21 action feedback waits for the real adapter outcome; reduced=$reduced',
      (tester) async {
        SharedPreferences.setMockInitialValues({'appearance.haptics': false});
        tester.view.physicalSize = const Size(360, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        for (final result in [
          CalendarActionResult.saved,
          CalendarActionResult.launched,
          CalendarActionResult.permissionDenied,
          CalendarActionResult.cancelled,
        ]) {
          final db = AppDatabase(NativeDatabase.memory());
          var closed = false;
          addTearDown(() async {
            if (!closed) await db.close();
          });
          final now = DateTime.utc(2030, 9, 5);
          final clock = Clock.fixed(now);
          final coordinator = LocalSyncCoordinator(
            database: db,
            auth: TestAuthRepository(),
            onLocalChange: () {},
          );
          final repository = DriftLifeAdminRepository(
            db,
            coordinator,
            clock: clock,
          );
          final items = DriftItemsRepository(
            db,
            syncCoordinator: coordinator,
            clock: clock,
          );
          final item = await tester.runAsync(
            () => items.create(title: 'Cita sintética'),
          );
          final action = ItemAction(
            id: 'event',
            itemId: item!.id,
            ownerId: item.ownerId,
            title: 'Revisar cita',
            payload: EventPayload(
              allDay: false,
              start: now.add(const Duration(days: 1)),
              end: now.add(const Duration(days: 1, hours: 1)),
              zone: 'UTC',
            ),
            origin: ActionOrigin.user,
            createdAt: now,
            updatedAt: now,
          );
          await tester.runAsync(() => repository.propose(action));
          final mappings = NotificationMappingStore(db);
          final scheduler = ReminderNotificationScheduler(
            gateway: TestNotificationGateway(),
            mappings: mappings,
            timeZones: const TestTimeZones(),
            clock: clock,
          );
          final calendar = _DeferredCalendar();
          final service = ActionService(
            repository: repository,
            scheduler: scheduler,
            mappings: mappings,
            calendar: calendar,
          );
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                lifeAdminRepositoryProvider.overrideWithValue(repository),
                itemActionsProvider(item.id)
                    .overrideWith((ref) => repository.watchActions(item.id)),
                itemFactsProvider(item.id)
                    .overrideWith((ref) => Stream.value([])),
                itemRemindersProvider(item.id)
                    .overrideWith((ref) => Stream.value([])),
                scheduledReminderIdsProvider.overrideWith((ref) async => {}),
                scheduledReminderCountProvider.overrideWith((ref) async => 0),
                notificationPermissionStatusProvider.overrideWith(
                  (ref) async => NotificationPermissionStatus.granted,
                ),
                actionServiceProvider.overrideWithValue(service),
              ],
              child: _app(ItemActionsPanel(item: item), reduced),
            ),
          );
          await tester.pumpAndSettle();
          final review = find.text('Revisar propuesta');
          await tester.ensureVisible(review);
          await tester.tap(review);
          await tester.pumpAndSettle();
          final confirm = find.widgetWithText(FilledButton, 'Confirmar');
          await tester.ensureVisible(confirm);
          final callback = tester.widget<FilledButton>(confirm).onPressed!;
          late Future<void> pending;
          var finished = false;
          await tester.runAsync(() async {
            pending = Function.apply(callback, []) as Future<void>;
            pending.then((_) => finished = true);
          });
          await _driveUntil(tester, () => calendar.entered.isCompleted);
          await tester.runAsync(
            () => Function.apply(callback, []) as Future<void>,
          );
          await tester.pump(const Duration(milliseconds: 300));
          expect(find.text('Confirmando…'), findsOneWidget);
          expect(find.byType(ActionFeedback), findsNothing);
          expect(calendar.calls, 1);
          if (reduced) {
            expect(find.byType(CircularProgressIndicator), findsNothing);
          }
          calendar.result.complete(result);
          await _driveUntil(tester, () => finished);
          await tester.pumpAndSettle();
          final feedback = find.byType(ActionFeedback);
          expect(feedback, findsOneWidget);
          expect(
            find.descendant(
              of: feedback,
              matching: find.byType(KiptoSuccessMark),
            ),
            result == CalendarActionResult.saved
                ? findsOneWidget
                : findsNothing,
          );
          final expected = switch (result) {
            CalendarActionResult.saved => 'Evento guardado en el calendario.',
            CalendarActionResult.launched => 'Calendario abierto. Kipto no puede confirmar si guardaste el evento.',
            CalendarActionResult.permissionDenied =>
              'No se ha autorizado el acceso al calendario.',
            _ => 'No se ha guardado ningún evento.',
          };
          expect(
            find.descendant(of: feedback, matching: find.text(expected)),
            findsOneWidget,
          );
          if (result == CalendarActionResult.saved) {
            final reopen = find.widgetWithText(
              TextButton,
              'Volver a abrir calendario',
            );
            await tester.ensureVisible(reopen);
            final reopenCallback = tester.widget<TextButton>(reopen).onPressed!;
            reopenCallback();
            reopenCallback();
            await tester.pumpAndSettle();
            expect(find.byType(AlertDialog), findsOneWidget);
            expect(find.byType(ActionFeedback), findsNothing);
            final cancel = MaterialLocalizations.of(
              tester.element(find.byType(AlertDialog)),
            ).cancelButtonLabel;
            await tester.tap(find.text(cancel));
            await tester.pumpAndSettle();
            expect(calendar.calls, 1);
            expect(tester.widget<TextButton>(reopen).onPressed, isNotNull);
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
          await tester.runAsync(db.close);
          closed = true;
          expect(tester.binding.transientCallbackCount, 0);
        }
      },
    );

    testWidgets(
      'T21 evidence expands with full quote and page then disposes; reduced=$reduced',
      (tester) async {
        tester.view.physicalSize = const Size(360, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final now = DateTime.utc(2030);
        final fact = Fact(
          id: 'fact',
          itemId: 'item',
          sourceId: 'source',
          sourceRevision: 1,
          key: 'note',
          value: TextFactValue('Revisar el original'),
          provenance: FactProvenance.extracted,
          evidence: FactEvidence(
            page: 2,
            quote: 'La revisión requiere confirmar la fecha con la fuente original.',
            verification: EvidenceVerification.unverified,
          ),
          createdAt: now,
          updatedAt: now,
        );
        await tester.pumpWidget(
          _app(FactCard(fact: fact, onSource: () {}), reduced),
        );
        await tester.pumpAndSettle();
        final quote = find.text(
          '«La revisión requiere confirmar la fecha con la fuente original.»',
        );
        expect(quote, findsNothing);
        final l = AppLocalizations.of(tester.element(find.byType(FactCard)));
        expect(find.text(l.checkOriginal), findsOneWidget);
        await tester.tap(find.text(l.evidenceDetails));
        await tester.pumpAndSettle();
        expect(quote, findsOneWidget);
        expect(find.text(l.pageNumber(2)), findsOneWidget);
        expect(find.text(l.checkOriginal), findsOneWidget);
        await tester.tap(find.text(l.evidenceDetails));
        await tester.pump(const Duration(milliseconds: 30));
        await tester.tap(find.text(l.evidenceDetails));
        await tester.pump();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(tester.binding.transientCallbackCount, 0);
      },
    );
  }
}
