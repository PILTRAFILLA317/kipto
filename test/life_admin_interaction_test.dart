import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/app/theme/app_theme.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/domain/models/item.dart';
import 'package:kipto/core/providers/repository_providers.dart';
import 'package:kipto/core/repositories/drift_items_repository.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/features/items/presentation/widgets/matter_controls.dart';
import 'package:kipto/l10n/app_localizations.dart';

import 'test_support.dart';

void main() {
  for (final reduced in [false, true]) {
    testWidgets(
      'T21 real matter rapid taps, resolve/undo, sheet/dispose with 2x text; reduced=$reduced',
      (tester) async {
        tester.view.physicalSize = const Size(360, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        final repo = DriftItemsRepository(
          db,
          syncCoordinator: LocalSyncCoordinator(
            database: db,
            auth: TestAuthRepository(),
            onLocalChange: () {},
          ),
        );
        final item = await tester.runAsync(
          () => repo.create(title: 'Revisar factura sintética'),
        );
        final itemState = ValueNotifier<Item>(item!);
        addTearDown(itemState.dispose);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [itemsRepositoryProvider.overrideWithValue(repo)],
            child: MaterialApp(
              locale: const Locale('es'),
              theme: AppTheme.dark(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(2),
                  disableAnimations: reduced,
                ),
                child: child!,
              ),
              home: Scaffold(
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: ValueListenableBuilder<Item>(
                      valueListenable: itemState,
                      builder: (_, value, _) => MatterControls(item: value),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final resolve = find.text('Resolver asunto');
        await tester.ensureVisible(resolve);
        final callback = tester
            .widget<TextButton>(
              find.ancestor(of: resolve, matching: find.byType(TextButton)),
            )
            .onPressed!;
        callback();
        callback();
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.tap(find.text('Confirmar'));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 80));
          itemState.value = (await repo.findById(item.id))!;
        });
        await tester.pumpAndSettle();
        expect(itemState.value.status, ItemStatus.resolved);
        await tester.tap(find.text('Deshacer'));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 80));
          itemState.value = (await repo.findById(item.id))!;
        });
        await tester.pumpAndSettle();
        expect(itemState.value.status, ItemStatus.active);
        await tester.ensureVisible(find.text('Editar título y resumen'));
        await tester.tap(find.text('Editar título y resumen'));
        await tester.pumpAndSettle();
        expect(find.byType(MatterTextSheet), findsOneWidget);
        expect(tester.takeException(), isNull);
        // Dispose the real editing controllers while the modal is still open.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(tester.binding.transientCallbackCount, 0);
      },
    );
  }
}
