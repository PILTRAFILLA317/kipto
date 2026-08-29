import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/app/app.dart';
import 'package:kipto/app/router/app_router.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/repositories/drift_screenshot_import_state_repository.dart';
import 'package:kipto/dev/seed/development_seed.dart';
import 'package:kipto/features/photo_library/domain/screenshot_import_state.dart';
import 'package:kipto/features/photo_library/presentation/providers/photo_library_providers.dart';

import 'fakes/fake_photo_library_repository.dart';
import 'test_helpers.dart';

void main() {
  testWidgets('Kipto starts, navigates tabs, and opens a demo item', (
    tester,
  ) async {
    final database = createTestDatabase();
    await DevelopmentSeed(
      database,
      clock: Clock.fixed(DateTime.utc(2026, 8, 29, 12)),
    ).run();
    await DriftScreenshotImportStateRepository(database)
        .write(const ScreenshotImportState(initialImportCompleted: true));
    final photoLibrary = FakePhotoLibraryRepository();
    appRouter.go('/inbox');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          photoLibraryRepositoryProvider.overrideWithValue(photoLibrary),
        ],
        child: const KiptoApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kipto'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    expect(find.text('8 active items'), findsOneWidget);

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(find.byType(SearchBar), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Local mode'), findsOneWidget);

    await tester.tap(find.text('Inbox'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('The National at Auditorio Central'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    expect(find.text('Saved item'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await photoLibrary.dispose();
  });
}
