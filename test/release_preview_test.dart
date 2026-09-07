import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/app/app.dart';
import 'package:kipto/app/router/app_router.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/core/repositories/drift_items_repository.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_support.dart';

import 'package:kipto/core/files/original_store.dart';
import 'package:kipto/features/capture/presentation/capture_providers.dart';

void main() {
  testWidgets(
    'Opt-in synthetic captures of actual Pending, Archive and detail screens',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final font = FontLoader('Inter')
        ..addFont(rootBundle.load('assets/fonts/Inter.ttf'));
      await font.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      tester.binding.platformDispatcher.localesTestValue = const [Locale('es')];
      addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);
      final root = await tester.runAsync(
        () => Directory.systemTemp.createTemp('kipto-preview-'),
      );
      addTearDown(() => root!.delete(recursive: true));
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final auth = TestAuthRepository();
      final items = DriftItemsRepository(
        db,
        syncCoordinator: LocalSyncCoordinator(
          database: db,
          auth: auth,
          onLocalChange: () {},
        ),
      );
      final first = await tester.runAsync(() async {
        final first = await items.create(
          title: 'Revisar renovación del seguro',
          summary: 'Consultar el preaviso indicado en la póliza.',
        );
        await items.create(
          title: 'Preparar la devolución',
          summary: 'Comprobar la fecha del justificante.',
        );
        final kept = await items.create(
          title: 'Garantía del portátil',
          summary: 'Información guardada para cuando haga falta.',
        );
        await items.setStatus(kept.id, ItemStatus.archived);
        return first;
      });
      final boundary = GlobalKey();
      appRouter.go('/inbox');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            originalStoreProvider.overrideWith(
              (ref) async => OriginalStore(root!),
            ),
            authRepositoryProvider.overrideWithValue(auth),
          ],
          child: RepaintBoundary(key: boundary, child: const KiptoApp()),
        ),
      );
      final output = Directory('docs/design/screens');
      await tester.runAsync(() => output.create(recursive: true));
      for (final screen in [
        ('pendientes', '/inbox'),
        ('archivo', '/archive'),
        ('detalle', '/items/${first!.id}'),
        ('ajustes', '/settings'),
        ('pro', '/pro'),
      ]) {
        appRouter.go(screen.$2);
        await tester.pumpAndSettle();
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final render =
              boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = await render.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File('${output.path}/${screen.$1}.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
    skip: !const bool.fromEnvironment('KIPTO_RELEASE_PREVIEW'),
  );
}
