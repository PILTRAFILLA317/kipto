import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/repositories/drift_saved_items_repository.dart';

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

    final inbox = await repository.watchInbox().first;
    expect(inbox.map((item) => item.id), ['action']);
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

    expect((await repository.watchInbox().first).map((item) => item.id), [
      'action',
      'expiring',
      'snoozed',
      'recent',
    ]);
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
    await repository.softDelete('deleted');

    expect((await repository.search('concert')).single.id, 'concert');
    expect((await repository.search('event')).single.id, 'concert');
    expect(await repository.search('needle note'), isEmpty);
  });
}
