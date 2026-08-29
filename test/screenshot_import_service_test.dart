import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/repositories/drift_screenshot_import_state_repository.dart';
import 'package:kipto/core/repositories/drift_screenshot_items_repository.dart';
import 'package:kipto/dev/seed/demo_seed_service.dart';
import 'package:kipto/features/photo_library/application/screenshot_import_service.dart';
import 'package:kipto/features/photo_library/domain/photo_library_models.dart';

import 'fakes/fake_photo_library_repository.dart';
import 'test_helpers.dart';

void main() {
  final now = DateTime.utc(2026, 8, 29, 12);

  List<LocalScreenshotAsset> assets(int count) => List.generate(
    count,
    (index) => LocalScreenshotAsset(
      id: 'asset-$index',
      capturedAt: now.subtract(Duration(hours: index)),
      width: 1170,
      height: 2532,
    ),
  );

  late AppDatabase database;
  late FakePhotoLibraryRepository photoLibrary;
  late DriftScreenshotItemsRepository itemsRepository;
  late ScreenshotImportService service;

  void configure({
    Iterable<LocalScreenshotAsset> source = const [],
    PhotoAccessStatus permission = PhotoAccessStatus.authorized,
    int pageSize = 100,
  }) {
    photoLibrary = FakePhotoLibraryRepository(
      permission: permission,
      assets: source,
    );
    itemsRepository = DriftScreenshotItemsRepository(
      database,
      clock: Clock.fixed(now),
    );
    service = ScreenshotImportService(
      photoLibrary: photoLibrary,
      screenshotItems: itemsRepository,
      importState: DriftScreenshotImportStateRepository(database),
      demoSeedService: DemoSeedService(database),
      clock: Clock.fixed(now),
      pageSize: pageSize,
    );
  }

  setUp(() {
    database = createTestDatabase();
  });

  tearDown(() async {
    await photoLibrary.dispose();
    await database.close();
  });

  test('recent100 imports exactly the 100 most recent of 150', () async {
    configure(source: assets(150));

    final result = await service.import(ScreenshotImportScope.recent100);
    final imported = await itemsRepository.importedAssetAvailability();

    expect(result.imported, 100);
    expect(imported.length, 100);
    expect(imported, contains('asset-0'));
    expect(imported, contains('asset-99'));
    expect(imported, isNot(contains('asset-100')));
  });

  test('last30Days imports only assets inside the date window', () async {
    configure(
      source: [
        ...assets(3),
        LocalScreenshotAsset(
          id: 'old',
          capturedAt: now.subtract(const Duration(days: 31)),
          width: 100,
          height: 200,
        ),
      ],
    );

    final result = await service.import(ScreenshotImportScope.last30Days);

    expect(result.imported, 3);
    expect(
      await itemsRepository.importedAssetAvailability(),
      isNot(contains('old')),
    );
  });

  test(
    'all is paginated and idempotent for a collection above page size',
    () async {
      configure(source: assets(1500), pageSize: 73);

      final first = await service.import(ScreenshotImportScope.all);
      final second = await service.import(ScreenshotImportScope.all);

      expect(first.imported, 1500);
      expect(second.imported, 0);
      expect(second.skipped, 1500);
      expect(await itemsRepository.countImported(), 1500);
    },
  );

  test('incremental scan imports only a newly appearing asset', () async {
    configure(source: assets(3));
    await service.import(ScreenshotImportScope.all);
    photoLibrary.add(
      LocalScreenshotAsset(
        id: 'asset-new',
        capturedAt: now.add(const Duration(minutes: 1)),
        width: 100,
        height: 200,
      ),
    );

    final result = await service.scanIncremental();

    expect(result.imported, 1);
    expect(await itemsRepository.countImported(), 4);
  });

  test('reconciliation keeps item and toggles original availability', () async {
    configure(source: assets(1));
    await service.import(ScreenshotImportScope.all);

    photoLibrary.remove('asset-0');
    await service.scanIncremental(forceReconcile: true);
    var availability = await itemsRepository.importedAssetAvailability();
    expect(availability['asset-0'], isFalse);
    expect(await itemsRepository.countImported(), 1);

    photoLibrary.add(assets(1).single);
    await service.scanIncremental(forceFullScan: true, forceReconcile: true);
    availability = await itemsRepository.importedAssetAvailability();
    expect(availability['asset-0'], isTrue);
    expect(await itemsRepository.countImported(), 1);
  });

  test(
    'limited access imports accessible assets and empty library is valid',
    () async {
      configure(source: assets(2), permission: PhotoAccessStatus.limited);
      expect((await service.import(ScreenshotImportScope.all)).imported, 2);

      await database.close();
      await photoLibrary.dispose();
      database = createTestDatabase();
      configure(permission: PhotoAccessStatus.authorized);
      final empty = await service.import(ScreenshotImportScope.all);
      expect(empty.processed, 0);
      expect(await itemsRepository.countImported(), 0);
    },
  );
}
