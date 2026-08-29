import 'package:kipto/core/domain/enums/saved_item_enums.dart';

final class Reminder {
  const Reminder({
    required this.id,
    required this.savedItemId,
    required this.remindAt,
    required this.kind,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    this.ownerId,
    this.completedAt,
    this.deletedAt,
    this.lastSyncedAt,
    this.remoteServerUpdatedAt,
  });

  final String id;
  final String? ownerId;
  final String savedItemId;
  final DateTime remindAt;
  final ReminderKind kind;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;
  final DateTime? lastSyncedAt;
  final DateTime? remoteServerUpdatedAt;
}
