import 'package:drift/native.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';

AppDatabase createTestDatabase() => AppDatabase(NativeDatabase.memory());

SavedItem testSavedItem({
  required String id,
  required DateTime now,
  String title = 'Test item',
  String summary = 'A searchable summary',
  String? subtype = 'reference',
  String? intent = 'Keep for later',
  Map<String, Object?> entities = const {'keyword': 'needle'},
  List<SavedItemActionType> availableActions = const [SavedItemActionType.save],
  SavedItemCategory category = SavedItemCategory.information,
  SavedItemStatus status = SavedItemStatus.newItem,
  bool favorite = false,
  DateTime? capturedAt,
  DateTime? eventAt,
  DateTime? expiresAt,
  DateTime? snoozedUntil,
  AnalysisStatus analysisStatus = AnalysisStatus.processed,
  String? ownerId,
  String? localAssetId,
  bool originalAvailable = false,
  SyncStatus syncStatus = SyncStatus.localOnly,
}) {
  final created = now.subtract(const Duration(days: 1));
  return SavedItem(
    id: id,
    ownerId: ownerId,
    title: title,
    summary: summary,
    category: category,
    subtype: subtype,
    intent: intent,
    status: status,
    favorite: favorite,
    capturedAt: capturedAt ?? created,
    eventAt: eventAt,
    expiresAt: expiresAt,
    snoozedUntil: snoozedUntil,
    entities: entities,
    availableActions: availableActions,
    analysisStatus: analysisStatus,
    analysisVersion: 1,
    confidence: 0.9,
    createdAt: created,
    updatedAt: created,
    localAssetId: localAssetId,
    originalAvailable: originalAvailable,
    syncStatus: syncStatus,
  );
}

extension SavedItemTestCopy on SavedItem {
  SavedItem copyWithCloudPath(String path) => SavedItem(
    id: id,
    ownerId: ownerId,
    title: title,
    summary: summary,
    category: category,
    subtype: subtype,
    intent: intent,
    status: status,
    favorite: favorite,
    capturedAt: capturedAt,
    eventAt: eventAt,
    expiresAt: expiresAt,
    snoozedUntil: snoozedUntil,
    location: location,
    entities: entities,
    availableActions: availableActions,
    cloudPreviewPath: path,
    imageHash: imageHash,
    analysisStatus: analysisStatus,
    analysisVersion: analysisVersion,
    confidence: confidence,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    localAssetId: localAssetId,
    originalAvailable: originalAvailable,
    previewCachePath: previewCachePath,
    syncStatus: syncStatus,
    lastSyncedAt: lastSyncedAt,
    remoteServerUpdatedAt: remoteServerUpdatedAt,
  );
}
