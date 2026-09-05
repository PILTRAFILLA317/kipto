import 'package:kipto/core/domain/models/sync_queue_entry.dart';

abstract interface class SyncQueueRepository {
  Future<List<SyncQueueEntry>> pending();
}
