import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/repositories/drift_sync_queue_repository.dart';

import 'test_helpers.dart';

void main() {
  test('enqueue, list, register error, and remove queue entries', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final now = DateTime.utc(2026, 8, 29, 12);
    final repository = DriftSyncQueueRepository(
      database,
      clock: Clock.fixed(now),
      idGenerator: () => 'queue-1',
    );

    final entry = await repository.enqueue(
      entityType: SyncEntityType.savedItem,
      entityId: 'item-1',
      operation: SyncOperation.create,
    );
    expect((await repository.pending()).single.id, entry.id);
    expect((await repository.watchPending().first).single.attempts, 0);

    await repository.registerError(entry.id, 'Offline');
    final attempted = (await repository.pending()).single;
    expect(attempted.attempts, 1);
    expect(attempted.lastError, 'Offline');
    expect(attempted.lastAttemptAt, now);

    await repository.markCompleted(entry.id);
    expect(await repository.pending(), isEmpty);
  });
}
