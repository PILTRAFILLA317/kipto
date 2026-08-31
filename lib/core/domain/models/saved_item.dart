import 'package:kipto/core/domain/enums/saved_item_enums.dart';

final class SavedItem {
  static const userNoteEntityKey = 'userNote';
  static const analysisMetadataEntityKey = '__kiptoAnalysis';
  static const completedActionsEntityKey = '__kiptoCompletedActions';

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
    this.remoteServerUpdatedAt,
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
  final DateTime? remoteServerUpdatedAt;

  String? get userNote {
    final value = entities[userNoteEntityKey];
    if (value is! String || value.trim().isEmpty) return null;
    return value.trim();
  }

  Map<String, Object?> get detectedEntities => Map.unmodifiable(
    Map<String, Object?>.from(entities)
      ..remove(userNoteEntityKey)
      ..remove(SavedItem.analysisMetadataEntityKey)
      ..remove(SavedItem.completedActionsEntityKey),
  );

  Map<SavedItemActionType, DateTime> get completedActions {
    final raw = entities[completedActionsEntityKey];
    if (raw is! Map) return const {};
    final output = <SavedItemActionType, DateTime>{};
    for (final entry in raw.entries) {
      if (entry.key is! String || entry.value is! String) continue;
      final action = SavedItemActionType.values
          .where((candidate) => candidate.storageValue == entry.key)
          .firstOrNull;
      final completedAt = DateTime.tryParse(entry.value as String)?.toUtc();
      if (action != null &&
          action != SavedItemActionType.none &&
          completedAt != null) {
        output[action] = completedAt;
      }
    }
    return Map.unmodifiable(output);
  }

  bool hasCompletedAction(SavedItemActionType action) =>
      completedActions.containsKey(action);

  Map<String, Object?> get analysisMetadata {
    final value = entities[SavedItem.analysisMetadataEntityKey];
    if (value is! Map) return const {};
    return Map.unmodifiable(Map<String, Object?>.from(value));
  }

  SavedItemMetadataSource get titleSource =>
      SavedItemMetadataSourceStorage.fromStorage(
        analysisMetadata['titleSource'],
      );

  SavedItemMetadataSource get categorySource =>
      SavedItemMetadataSourceStorage.fromStorage(
        analysisMetadata['categorySource'],
      );

  String? get analysisModel => analysisMetadata['model'] as String?;
  String? get analysisPromptVersion =>
      analysisMetadata['promptVersion'] as String?;
  String? get sourceApp => analysisMetadata['sourceApp'] as String?;
  bool get requiresAction => analysisMetadata['requiresAction'] == true;

  DateTime? get analyzedAt {
    final value = analysisMetadata['analyzedAt'];
    return value is String ? DateTime.tryParse(value)?.toUtc() : null;
  }

  AnalysisRelevance get relevance =>
      AnalysisRelevanceStorage.tryParse(
        analysisMetadata['relevance'] as String? ?? '',
      ) ??
      AnalysisRelevance.unknown;

  List<String> get uncertainFields => _metadataStrings('uncertainFields');
  List<String> get searchKeywords => _metadataStrings('searchKeywords');

  List<String> _metadataStrings(String key) {
    final value = analysisMetadata[key];
    if (value is! List) return const [];
    return List.unmodifiable(value.whereType<String>());
  }
}
