import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/repositories/drift_saved_items_repository.dart';
import 'package:kipto/core/domain/models/library_query.dart';

import 'test_helpers.dart';

void main() {
  late DateTime now;
  late DriftSavedItemsRepository repository;
  late AppDatabase database;

  setUp(() {
    now = DateTime.utc(2026, 8, 29, 12);
    database = createTestDatabase();
    repository = DriftSavedItemsRepository(database, clock: Clock.fixed(now));
  });

  tearDown(() => database.close());

  test('watchInbox excludes archived, done, and soft-deleted items', () async {
    await repository.create(testSavedItem(id: 'new', now: now));
    await repository.create(
      testSavedItem(
        id: 'action',
        now: now,
        status: SavedItemStatus.needsAction,
      ),
    );
    await repository.create(
      testSavedItem(id: 'done', now: now, status: SavedItemStatus.done),
    );
    await repository.create(
      testSavedItem(id: 'archived', now: now, status: SavedItemStatus.archived),
    );
    await repository.softDelete('new');

    final inbox = await repository.watchInboxOverview(now).first;
    expect(
      inbox.sections.expand((section) => section.items).map((item) => item.id),
      ['action'],
    );
  });

  test('category streams return only the requested category', () async {
    await repository.create(
      testSavedItem(id: 'event', now: now, category: SavedItemCategory.event),
    );
    await repository.create(
      testSavedItem(id: 'place', now: now, category: SavedItemCategory.place),
    );

    final events = await repository
        .watchByCategory(SavedItemCategory.event)
        .first;
    expect(events.map((item) => item.id), ['event']);
  });

  test('inbox orders action, expiry, snoozed, then recent', () async {
    await repository.create(testSavedItem(id: 'recent', now: now));
    await repository.create(
      testSavedItem(id: 'snoozed', now: now, status: SavedItemStatus.snoozed),
    );
    await repository.create(
      testSavedItem(
        id: 'expiring',
        now: now,
        expiresAt: now.add(const Duration(days: 1)),
      ),
    );
    await repository.create(
      testSavedItem(
        id: 'action',
        now: now,
        status: SavedItemStatus.needsAction,
      ),
    );

    final overview = await repository.watchInboxOverview(now).first;
    expect(overview.attentionCount, 2);
    expect(
      overview.sections
          .expand((section) => section.items)
          .map((item) => item.id),
      ['action', 'expiring', 'snoozed', 'recent'],
    );
  });

  test(
    'favorite, done, archive, snooze, and updatedAt are persisted',
    () async {
      await repository.create(testSavedItem(id: 'item', now: now));

      await repository.toggleFavorite('item');
      var item = await repository.watchById('item').first;
      expect(item?.favorite, isTrue);
      expect(item?.updatedAt, now);

      await repository.markDone('item');
      expect(
        (await repository.watchById('item').first)?.status,
        SavedItemStatus.done,
      );

      await repository.archive('item');
      expect(
        (await repository.watchById('item').first)?.status,
        SavedItemStatus.archived,
      );

      final until = now.add(const Duration(days: 2));
      await repository.snooze('item', until);
      item = await repository.watchById('item').first;
      expect(item?.status, SavedItemStatus.snoozed);
      expect(item?.snoozedUntil, until);
    },
  );

  test('local search covers fields and ignores soft-deleted rows', () async {
    await repository.create(
      testSavedItem(
        id: 'concert',
        now: now,
        title: 'Midnight concert',
        category: SavedItemCategory.event,
      ),
    );
    await repository.create(
      testSavedItem(id: 'deleted', now: now, title: 'Needle note'),
    );
    await repository.create(
      testSavedItem(
        id: 'summary',
        now: now,
        summary: 'A quiet ramen restaurant',
      ),
    );
    await repository.softDelete('deleted');

    expect((await repository.search('concert')).single.id, 'concert');
    expect((await repository.search('event')).single.id, 'concert');
    expect((await repository.search('events')).single.id, 'concert');
    expect((await repository.search('ramen')).single.id, 'summary');
    expect(await repository.search('needle note'), isEmpty);
  });

  test('library filters and sorts without excluding archived items', () async {
    await repository.create(
      testSavedItem(
        id: 'older',
        now: now,
        capturedAt: now.subtract(const Duration(days: 5)),
        category: SavedItemCategory.event,
        favorite: true,
      ),
    );
    await repository.create(
      testSavedItem(
        id: 'newer',
        now: now,
        capturedAt: now.subtract(const Duration(days: 1)),
        status: SavedItemStatus.archived,
        category: SavedItemCategory.event,
        favorite: true,
      ),
    );
    await repository.create(
      testSavedItem(id: 'place', now: now, category: SavedItemCategory.place),
    );

    final newest = await repository
        .watchLibrary(
          const LibraryQuery(
            filter: LibraryFilter(
              category: SavedItemCategory.event,
              favoriteOnly: true,
            ),
          ),
        )
        .first;
    expect(newest.map((item) => item.id), ['newer', 'older']);

    final oldest = await repository
        .watchLibrary(
          const LibraryQuery(
            filter: LibraryFilter(category: SavedItemCategory.event),
            sort: LibrarySort.oldest,
          ),
        )
        .first;
    expect(oldest.map((item) => item.id), ['older', 'newer']);

    final archived = await repository
        .watchLibrary(
          const LibraryQuery(
            filter: LibraryFilter(status: SavedItemStatus.archived),
          ),
        )
        .first;
    expect(archived.single.id, 'newer');
  });

  test('library counts include category and unprocessed totals', () async {
    await repository.create(
      testSavedItem(
        id: 'raw',
        now: now,
        category: SavedItemCategory.other,
        analysisStatus: AnalysisStatus.unprocessed,
      ),
    );
    await repository.create(
      testSavedItem(id: 'event', now: now, category: SavedItemCategory.event),
    );

    final counts = await repository.watchLibraryCounts().first;
    expect(counts.total, 2);
    expect(counts.unprocessed, 1);
    expect(counts.byCategory[SavedItemCategory.event], 1);

    final unprocessed = await repository
        .watchLibrary(
          const LibraryQuery(
            filter: LibraryFilter(analysisStatus: AnalysisStatus.unprocessed),
          ),
        )
        .first;
    expect(unprocessed.single.id, 'raw');
  });

  test('title and category edits persist local-first', () async {
    await repository.create(testSavedItem(id: 'edit', now: now));
    await repository.updateTitle('edit', 'Restaurant for Ane');
    await repository.updateCategory('edit', SavedItemCategory.place);
    await repository.updateNote('edit', 'Book a table for Friday');

    final item = await repository.watchById('edit').first;
    expect(item?.title, 'Restaurant for Ane');
    expect(item?.category, SavedItemCategory.place);
    expect(item?.titleSource, SavedItemMetadataSource.user);
    expect(item?.categorySource, SavedItemMetadataSource.user);
    expect(item?.userNote, 'Book a table for Friday');
    expect(item?.detectedEntities, isNot(contains('userNote')));
    expect(item?.updatedAt, now);

    expect((await repository.search('book a table')).single.id, 'edit');
  });
}
