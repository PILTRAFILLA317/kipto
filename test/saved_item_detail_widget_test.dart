import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/app/app.dart';
import 'package:kipto/app/router/app_router.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/repositories/drift_saved_items_repository.dart';
import 'package:kipto/core/repositories/drift_screenshot_import_state_repository.dart';
import 'package:kipto/features/photo_library/domain/screenshot_import_state.dart';
import 'package:kipto/features/photo_library/presentation/providers/photo_library_providers.dart';

import 'fakes/fake_photo_library_repository.dart';
import 'test_helpers.dart';

void main() {
  testWidgets('detail edits metadata and favorite locally', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final now = DateTime.utc(2026, 8, 30, 12);
    final database = createTestDatabase();
    final repository = DriftSavedItemsRepository(database);
    final photoLibrary = FakePhotoLibraryRepository();
    addTearDown(database.close);
    addTearDown(photoLibrary.dispose);
    await repository.create(
      testSavedItem(
        id: 'detail',
        now: now,
        summary: '',
        subtype: null,
        intent: null,
        entities: const {},
        availableActions: const [],
      ),
    );
    await DriftScreenshotImportStateRepository(database)
        .write(const ScreenshotImportState(initialImportCompleted: true));
    appRouter.go('/item/detail');

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

    Future<void> center(Finder finder) async {
      expect(finder, findsOneWidget);
      await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byTooltip('Edit title'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Restaurant for Ane');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Restaurant for Ane'), findsOneWidget);

    await center(find.byType(ActionChip));
    await tester.tap(find.byType(ActionChip));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Place'));
    await tester.pumpAndSettle();
    expect(find.text('Place'), findsOneWidget);

    await tester.tap(find.byTooltip('Add favorite'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remove favorite'), findsOneWidget);

    final item = await database.savedItemsDao.findById('detail');
    expect(item?.title, 'Restaurant for Ane');
    expect(item?.category, SavedItemCategory.place);
    expect(item?.favorite, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
