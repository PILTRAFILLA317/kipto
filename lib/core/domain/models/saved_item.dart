import 'package:kipto/core/domain/enums/saved_item_enums.dart';

final class SavedItem {
  const SavedItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.status,
    required this.favorite,
    required this.capturedAt,
    required this.entities,
    required this.availableActions,
    required this.analysisStatus,
    required this.analysisVersion,
    required this.createdAt,
    required this.updatedAt,
    required this.originalAvailable,
    required this.syncStatus,
    this.ownerId,
    this.subtype,
    this.intent,
    this.eventAt,
    this.expiresAt,
    this.snoozedUntil,
    this.location,
    this.cloudPreviewPath,
    this.imageHash,
    this.confidence,
    this.deletedAt,
    this.localAssetId,
    this.previewCachePath,
    this.lastSyncedAt,
  });

  final String id;
  final String? ownerId;
  final String title;
  final String summary;
  final SavedItemCategory category;
  final String? subtype;
  final String? intent;
  final SavedItemStatus status;
  final bool favorite;
  final DateTime capturedAt;
  final DateTime? eventAt;
  final DateTime? expiresAt;
  final DateTime? snoozedUntil;
  final String? location;
  final Map<String, Object?> entities;
  final List<SavedItemActionType> availableActions;
  final String? cloudPreviewPath;
  final String? imageHash;
  final AnalysisStatus analysisStatus;
  final int analysisVersion;
  final double? confidence;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? localAssetId;
  final bool originalAvailable;
  final String? previewCachePath;
  final SyncStatus syncStatus;
  final DateTime? lastSyncedAt;
}
