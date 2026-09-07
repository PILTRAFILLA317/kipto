import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/app/app.dart';
import 'package:kipto/app/router/app_router.dart';
import 'package:kipto/app/theme/app_theme.dart';
import 'package:kipto/features/inbox/presentation/providers/inbox_providers.dart';
import 'package:kipto/features/capture/presentation/add_sheet.dart';
import 'package:kipto/features/design/presentation/design_preview_screen.dart';
import 'package:kipto/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    final font = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('T01 shell retains archive filter through tabs and add sheet', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    appRouter.go('/inbox');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeItemsProvider.overrideWith((ref) => Stream.value([])),
          archivedItemsProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const KiptoApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resolved'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-button')));
    await tester.pumpAndSettle();
    expect(find.byType(AddSheet), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pending').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive').last);
    await tester.pumpAndSettle();
    final selectedFilter = tester.getSemantics(find.text('Resolved'));
    expect(selectedFilter.label, contains('Resolved'));
    expect(selectedFilter.flagsCollection.isSelected, ui.Tristate.isTrue);
    final otherFilter = tester.getSemantics(find.text('All'));
    expect(otherFilter.flagsCollection.isSelected, ui.Tristate.isFalse);
    expect(appRouter.routeInformationProvider.value.uri.path, '/archive');
    expect(tester.takeException(), isNull);
    semantics.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets(
    'T02 narrow preview and sheet support large text and reduced motion',
    (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final boundary = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(2),
              disableAnimations: true,
            ),
            child: child!,
          ),
          home: RepaintBoundary(
            key: boundary,
            child: const DesignPreviewScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.binding.transientCallbackCount, 0);
      if (const bool.fromEnvironment('KIPTO_CAPTURE_PREVIEW')) {
        await tester.runAsync(() async {
          final render =
              boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = await render.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File('/tmp/kipto-phase01-preview.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.scrollUntilVisible(
        find.byKey(const Key('add-button')),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.byKey(const Key('add-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('add-button')));
      await tester.pumpAndSettle();
      expect(find.byType(AddSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Cerrar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
