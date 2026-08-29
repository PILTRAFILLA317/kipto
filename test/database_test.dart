import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/repositories/drift_reminders_repository.dart';
import 'package:kipto/core/repositories/drift_saved_items_repository.dart';

import 'test_helpers.dart';

void main() {
  test(
    'in-memory database creates, reads, updates, and soft-deletes',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final now = DateTime.utc(2026, 8, 29, 12);
      final repository = DriftSavedItemsRepository(
        database,
        clock: Clock.fixed(now),
      );
      final item = testSavedItem(id: 'item-1', now: now);

      await repository.create(item);
      expect((await repository.watchById(item.id).first)?.title, 'Test item');

      await repository.changeStatus(item.id, SavedItemStatus.needsAction);
      expect(
        (await repository.watchById(item.id).first)?.status,
        SavedItemStatus.needsAction,
      );

      await repository.softDelete(item.id);
      expect(await repository.watchById(item.id).first, isNull);
      final stored = await database.savedItemsDao.findById(
        item.id,
        includeDeleted: true,
      );
      expect(stored?.deletedAt, now);
    },
  );

  test('reminder remains related to its SavedItem', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final now = DateTime.utc(2026, 8, 29, 12);
    final savedItems = DriftSavedItemsRepository(
      database,
      clock: Clock.fixed(now),
    );
    final reminders = DriftRemindersRepository(
      database,
      clock: Clock.fixed(now),
      idGenerator: () => 'reminder-1',
    );
    await savedItems.create(testSavedItem(id: 'item-1', now: now));

    await reminders.create(
      savedItemId: 'item-1',
      remindAt: now.add(const Duration(hours: 2)),
    );

    final stored = await reminders.watchForSavedItem('item-1').first;
    expect(stored.single.savedItemId, 'item-1');
    expect(stored.single.id, 'reminder-1');
  });
}
