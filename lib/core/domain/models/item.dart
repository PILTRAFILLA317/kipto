import 'package:kipto/core/domain/enums/item_enums.dart';

final class Item {
  const Item({
    required this.id,
    required this.title,
    required this.summary,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    this.ownerId,
    this.resolvedAt,
    this.deletedAt,
    this.lastSyncedAt,
    this.remoteServerUpdatedAt,
    this.sourceDeviceId,
  });

  final String id;
  final String? ownerId;
  final String title;
  final String summary;
  final ItemStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;
  final DateTime? lastSyncedAt;
  final DateTime? remoteServerUpdatedAt;
  final String? sourceDeviceId;
}
