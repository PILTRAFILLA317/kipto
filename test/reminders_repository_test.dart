import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/repositories/drift_reminders_repository.dart';
import 'package:kipto/core/repositories/drift_saved_items_repository.dart';

import 'test_helpers.dart';

void main() {
  test(
    'create, query, complete, delete, and future pending reminders',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final now = DateTime.utc(2026, 8, 29, 12);
      var nextId = 0;
      final savedItems = DriftSavedItemsRepository(
        database,
        clock: Clock.fixed(now),
      );
      final repository = DriftRemindersRepository(
        database,
        clock: Clock.fixed(now),
        idGenerator: () => 'reminder-${++nextId}',
      );
      await savedItems.create(testSavedItem(id: 'item', now: now));

      final future = await repository.create(
        savedItemId: 'item',
        remindAt: now.add(const Duration(hours: 3)),
        kind: ReminderKind.followUp,
      );
      await repository.create(
        savedItemId: 'item',
        remindAt: now.subtract(const Duration(hours: 1)),
      );

      expect((await repository.watchForSavedItem('item').first).length, 2);
      expect((await repository.futurePending()).single.id, future.id);

      await repository.complete(future.id);
      expect(await repository.futurePending(), isEmpty);

      await repository.delete('reminder-2');
      final visible = await repository.watchForSavedItem('item').first;
      expect(visible.map((item) => item.id), [future.id]);
    },
  );
}
