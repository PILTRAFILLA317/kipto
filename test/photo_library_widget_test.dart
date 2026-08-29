import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/app/app.dart';
import 'package:kipto/app/router/app_router.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/repositories/drift_screenshot_import_state_repository.dart';
import 'package:kipto/features/photo_library/domain/photo_library_models.dart';
import 'package:kipto/features/photo_library/domain/screenshot_import_state.dart';
import 'package:kipto/features/photo_library/presentation/providers/photo_library_providers.dart';
import 'package:kipto/features/photo_library/presentation/widgets/local_asset_thumbnail.dart';

import 'fakes/fake_photo_library_repository.dart';
import 'test_helpers.dart';

void main() {
  Future<void> pumpKipto(
    WidgetTester tester, {
    required FakePhotoLibraryRepository photoLibrary,
    bool initialImportCompleted = false,
  }) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    addTearDown(photoLibrary.dispose);
    if (initialImportCompleted) {
      await DriftScreenshotImportStateRepository(database)
          .write(const ScreenshotImportState(initialImportCompleted: true));
    }
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
  }

  Future<void> disposeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('not determined shows contextual allow CTA', (tester) async {
    await pumpKipto(
      tester,
      photoLibrary: FakePhotoLibraryRepository(
        permission: PhotoAccessStatus.notDetermined,
      ),
    );

    expect(find.text('Turn screenshots into useful actions'), findsOneWidget);
    expect(find.text('Allow access'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('denied shows Open Settings', (tester) async {
    final photoLibrary = FakePhotoLibraryRepository(
      permission: PhotoAccessStatus.denied,
    );
    await pumpKipto(tester, photoLibrary: photoLibrary);

    expect(find.text('Open Settings'), findsOneWidget);
    await tester.tap(find.text('Open Settings'));
    expect(photoLibrary.settingsOpened, isTrue);
    await disposeApp(tester);
  });

  testWidgets('limited access remains usable and offers management', (
    tester,
  ) async {
    await pumpKipto(
      tester,
      photoLibrary: FakePhotoLibraryRepository(
        permission: PhotoAccessStatus.limited,
      ),
      initialImportCompleted: true,
    );

    expect(
      find.text('Kipto only has access to selected photos.'),
      findsOneWidget,
    );
    expect(find.text('Manage access'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('import screen exposes typed scopes and live progress', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 8, 29, 12);
    final photoLibrary = FakePhotoLibraryRepository(
      assets: List.generate(
        150,
        (index) => LocalScreenshotAsset(
          id: 'asset-$index',
          capturedAt: now.subtract(Duration(minutes: index)),
          width: 100,
          height: 200,
        ),
      ),
    );
    await pumpKipto(tester, photoLibrary: photoLibrary);

    expect(find.text('Recent 100'), findsOneWidget);
    expect(find.text('Last 30 days'), findsOneWidget);
    expect(find.text('All screenshots'), findsOneWidget);

    photoLibrary.pageDelay = const Duration(seconds: 1);
    await tester.tap(find.text('Import screenshots'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    expect(find.text('Importing screenshots'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await disposeApp(tester);
  });

  testWidgets('thumbnail resolver has a safe fallback', (tester) async {
    final photoLibrary = FakePhotoLibraryRepository();
    addTearDown(photoLibrary.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          photoLibraryRepositoryProvider.overrideWithValue(photoLibrary),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: LocalAssetThumbnail(
              localAssetId: 'missing',
              originalAvailable: true,
              requestWidth: 200,
              requestHeight: 300,
              width: 100,
              height: 120,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
  });
}
