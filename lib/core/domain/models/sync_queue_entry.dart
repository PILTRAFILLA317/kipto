import 'package:kipto/core/domain/enums/item_enums.dart';

final class SyncQueueEntry {
  const SyncQueueEntry({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.createdAt,
    required this.attempts,
    this.lastAttemptAt,
    this.lastError,
  });

  final String id;
  final SyncEntityType entityType;
  final String entityId;
  final SyncOperation operation;
  final DateTime createdAt;
  final int attempts;
  final DateTime? lastAttemptAt;
  final String? lastError;
}
