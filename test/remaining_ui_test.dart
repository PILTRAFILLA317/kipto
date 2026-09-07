import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/app/theme/app_theme.dart';
import 'package:kipto/app/theme/theme_mode_controller.dart';
import 'package:kipto/core/auth/auth_repository.dart';
import 'package:kipto/core/auth/kipto_auth_state.dart';
import 'package:kipto/core/config/app_config.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/models/source.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/features/analysis/presentation/analysis_panel.dart';
import 'package:kipto/features/analysis/presentation/analysis_providers.dart';
import 'package:kipto/features/backup/presentation/backup_providers.dart';
import 'package:kipto/features/capture/presentation/add_sheet.dart';
import 'package:kipto/features/billing/application/billing_repository.dart';
import 'package:kipto/features/billing/presentation/billing_providers.dart';
import 'package:kipto/features/billing/presentation/pro_screen.dart';
import 'package:kipto/features/items/presentation/item_detail_screen.dart';
import 'package:kipto/features/notifications/domain/notification_models.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';
import 'package:kipto/features/settings/presentation/settings_screen.dart';
import 'package:kipto/l10n/app_localizations.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'test_support.dart';

Source source({SourceKind kind = SourceKind.pdf, int revision = 1}) => Source(
  id: 'source-a',
  itemId: 'item-a',
  ownerId: 'user-a',
  kind: kind,
  origin: SourceOrigin.manual,
  originalName: 'Documento de prueba con un nombre considerablemente largo',
  mimeType: kind == SourceKind.pdf ? 'application/pdf' : 'text/plain',
  byteSize: 100,
  contentHash: 'synthetic',
  revision: revision,
  pageCount: 2,
  textContent: List.filled(
    20,
    'Texto sintético largo para revisar la lectura y el desplazamiento.',
  ).join('\n'),
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

class LayoutBilling extends BillingRepository {
  LayoutBilling() : super(owner: () => 'user-a');
  @override
  bool get configured => true;
}

Widget host(
  ProviderContainer container,
  Widget screen, {
  required bool reduced,
  bool light = false,
}) => UncontrolledProviderScope(
  container: container,
  child: MaterialApp(
    theme: light ? AppTheme.light() : AppTheme.dark(),
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(2),
        disableAnimations: reduced,
      ),
      child: child!,
    ),
    home: screen,
  ),
);

Future<void> scan(WidgetTester tester) async {
  final scrollable = find.byType(Scrollable).first;
  for (var n = 0; n < 30; n++) {
    expect(tester.takeException(), isNull);
    final position = tester.state<ScrollableState>(scrollable).position;
    if (position.extentAfter == 0) break;
    await tester.drag(scrollable, const Offset(0, -350));
    await tester.pumpAndSettle();
  }
  expect(tester.takeException(), isNull);
}

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await (FontLoader(
      'Inter',
    )..addFont(rootBundle.load('assets/fonts/Inter.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  setUp(
    () => SharedPreferences.setMockInitialValues({
      'privacy.user-a.v1': jsonEncode({'version': 1, 'analysis': true}),
    }),
  );
  for (final reduced in [false, true]) {
    testWidgets(
      'T02/T21 analysis removes stale output, handles corrupt data and account changes; reduced=$reduced',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final auth = StateProvider<AuthRepository>(
          (ref) => TestAuthRepository(),
        );
        final jobs = StateProvider<AnalysisJobRow?>((ref) => null);
        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWith((ref) => ref.watch(auth)),
            analysisJobProvider.overrideWith(
              (ref, id) => Stream.value(ref.watch(jobs)),
            ),
          ],
        );
        addTearDown(container.dispose);
        final fixture = jsonDecode(
          File('test/fixtures/analysis/appointment.json').readAsStringSync(),
        ) as Map<String, dynamic>;
        final output = fixture['output'] as Map<String, dynamic>;
        (output['coverage'] as Map)['isPartial'] = true;
        final l = lookupAppLocalizations(const Locale('es'));
        Future<void> job(
          String state, {
          String? envelope,
          String? error,
          int revision = 1,
        }) async {
          container.read(jobs.notifier).state = AnalysisJobRow(
            sourceId: 'source-a',
            requestId: 'request-$state-$revision',
            ownerId: 'user-a',
            revision: revision,
            locale: 'es',
            timeZone: 'Europe/Madrid',
            state: state,
            attempts: 1,
            requestedAt: DateTime.utc(2026),
            envelope: envelope,
            errorCode: error,
          );
          await tester.pump();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 30));
        }

        await tester.pumpWidget(
          host(
            container,
            Scaffold(
              body: SingleChildScrollView(
                child: AnalysisPanel(source: source()),
              ),
            ),
            reduced: reduced,
          ),
        );
        await tester.pumpAndSettle();
        await job('queued');
        expect(find.text(l.analysisQueued), findsOneWidget);
        await job('running');
        expect(find.text(l.analysisRunning), findsOneWidget);
        expect(
          find.byType(LinearProgressIndicator),
          reduced ? findsNothing : findsOneWidget,
        );
        await job('done', envelope: jsonEncode({'output': output}));
        expect(find.text(l.analysisPartial), findsOneWidget);
        expect(find.text(l.analysisReady), findsOneWidget);
        await tester.pumpAndSettle();
        await scan(tester);
        await job('failed', error: 'quotaBlocked');
        expect(find.text(l.analysisQuota), findsOneWidget);
        expect(find.text(output['title'] as String), findsNothing);
        expect(find.text(l.analysisReady), findsNothing);
        for (final corrupt in [
          '{}',
          '{broken',
          jsonEncode({
            'output': {
              ...output,
              'warnings': [42],
            },
          }),
        ]) {
          await job('done', envelope: corrupt);
          expect(find.text(l.analysisInvalid), findsOneWidget);
          expect(find.text(l.analysisReady), findsNothing);
        }
        await job(
          'done',
          envelope: jsonEncode({'output': output}),
          revision: 2,
        );
        expect(find.text(l.analysisInvalid), findsOneWidget);
        expect(find.text(output['title'] as String), findsNothing);
        await job('done', envelope: jsonEncode({'output': output}));
        expect(find.text(output['title'] as String), findsOneWidget);
        container.read(auth.notifier).state = TestAuthRepository(
          const KiptoUser(id: 'user-b', isAnonymous: true),
        );
        await tester.pump();
        await tester.pump();
        expect(find.text(output['title'] as String), findsNothing);
        expect(find.text(l.analysisReady), findsNothing);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
  for (final light in [false, true]) {
    testWidgets(
      'T02 add with keyboard, settings, subscription and viewer at 2x text; light=$light',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        final offerings = Completer<List<Package>>();
        final packages = [
          for (final type in [PackageType.monthly, PackageType.annual])
            Package(
              'synthetic-${type.name}',
              type,
              StoreProduct(
                'synthetic',
                'Synthetic layout fixture',
                'Synthetic',
                9999.99,
                '9.999,99 €',
                'EUR',
              ),
              const PresentedOfferingContext('synthetic', null, null),
            ),
        ];
        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            appConfigProvider.overrideWithValue(
              const AppConfig(supabaseUrl: '', supabasePublishableKey: ''),
            ),
            authRepositoryProvider.overrideWithValue(TestAuthRepository()),
            fileJobsProvider.overrideWith((ref) => Stream.value([])),
            notificationPermissionStatusProvider.overrideWith(
              (ref) async => NotificationPermissionStatus.denied,
            ),
            billingRepositoryProvider.overrideWithValue(LayoutBilling()),
            billingStatusProvider.overrideWith(
              (ref) async => (pro: false, used: 0),
            ),
            billingOfferingsProvider.overrideWith((ref) => offerings.future),
          ],
        );
        addTearDown(container.dispose);
        final l = lookupAppLocalizations(const Locale('es'));
        await tester.pumpWidget(
          host(
            container,
            const Scaffold(body: AddSheet()),
            reduced: true,
            light: light,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(l.writeOrPaste));
        await tester.pumpAndSettle();
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        addTearDown(tester.view.resetViewInsets);
        await tester.enterText(
          find.byType(TextField).first,
          'Título sintético suficientemente largo para revisar la entrada',
        );
        await tester.enterText(
          find.byType(TextField).last,
          source(kind: SourceKind.text).textContent!,
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.widgetWithText(FilledButton, l.save));
        await tester.pumpAndSettle();
        expect(
          find.widgetWithText(FilledButton, l.save).hitTestable(),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        tester.view.resetViewInsets();
        await tester.pumpWidget(
          host(container, const SettingsScreen(), reduced: true, light: light),
        );
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(find.text(l.dark), 350);
        await tester.tap(find.text(l.dark));
        await tester.pumpAndSettle();
        expect(container.read(themeModeProvider), ThemeMode.dark);
        await scan(tester);
        expect(find.text(l.exportData), findsOneWidget);
        await tester.pumpWidget(
          host(container, const ProScreen(), reduced: true, light: light),
        );
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(find.text(l.billingUnavailable), 300);
        expect(find.text(l.billingUnavailable), findsOneWidget);
        for (
          var i = 0;
          i < 12 && find.text(l.loading).evaluate().isEmpty;
          i++
        ) {
          await tester.drag(find.byType(ListView), const Offset(0, -300));
          await tester.pumpAndSettle();
        }
        expect(find.text(l.loading), findsOneWidget);
        expect(tester.binding.transientCallbackCount, 0);
        offerings.complete(packages);
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(find.text(l.monthlyPlan), 300);
        expect(
          tester
              .widget<OutlinedButton>(
                find.widgetWithText(OutlinedButton, l.monthlyPlan),
              )
              .onPressed,
          isNull,
        );
        await scan(tester);
        await tester.pumpWidget(
          host(
            container,
            SourceViewer(source: source(kind: SourceKind.text)),
            reduced: true,
            light: light,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(SelectableText), findsOneWidget);
        await scan(tester);
        await tester.pumpWidget(
          host(
            container,
            SourceViewer(source: source()),
            reduced: true,
            light: light,
          ),
        );
        for (
          var n = 0;
          n < 30 && find.text(l.sourceUnavailable).evaluate().isEmpty;
          n++
        ) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 10)),
          );
          await tester.pump(const Duration(milliseconds: 10));
        }
        expect(find.text(l.sourceUnavailable), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }
}
