import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/sync_queue_entry.dart';

abstract interface class SyncQueueRepository {
  Future<SyncQueueEntry> enqueue({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperation operation,
  });
  Stream<List<SyncQueueEntry>> watchPending();
  Future<List<SyncQueueEntry>> pending();
  Future<void> markCompleted(String id);
  Future<void> registerError(String id, String error);
}
