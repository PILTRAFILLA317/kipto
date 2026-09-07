import 'package:kipto/core/domain/enums/item_enums.dart';

final class Reminder {
  const Reminder({
    required this.id,
    required this.itemId,
    required this.remindAt,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    this.ownerId,
    this.actionId,
    this.title,
    this.timeZone,
    this.completedAt,
    this.deletedAt,
    this.lastSyncedAt,
    this.remoteServerUpdatedAt,
    this.sourceDeviceId,
  });

  final String id;
  final String? ownerId;
  final String? actionId, title, timeZone;
  final String itemId;
  final DateTime remindAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;
  final DateTime? lastSyncedAt;
  final DateTime? remoteServerUpdatedAt;
  final String? sourceDeviceId;
}
