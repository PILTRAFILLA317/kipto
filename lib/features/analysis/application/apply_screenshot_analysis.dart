// ignore_for_file: prefer_initializing_formals

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/features/analysis/domain/analysis_acceptance_policy.dart';
import 'package:kipto/features/analysis/domain/screenshot_analysis_result.dart';

final class ApplyScreenshotAnalysis {
  ApplyScreenshotAnalysis({
    required AppDatabase database,
    LocalSyncCoordinator? syncCoordinator,
    AnalysisAcceptancePolicy policy = const AnalysisAcceptancePolicy(),
    Clock? clock,
  }) : _database = database,
       _syncCoordinator = syncCoordinator,
       _policy = policy,
       _clock = clock ?? const Clock();

  final AppDatabase _database;
  final LocalSyncCoordinator? _syncCoordinator;
  final AnalysisAcceptancePolicy _policy;
  final Clock _clock;

  Future<void> apply(
    String savedItemId,
    ScreenshotAnalysisEnvelope envelope,
  ) async {
    final existing = await _database.savedItemsDao.findById(
      savedItemId,
      includeDeleted: true,
    );
    if (existing == null) throw StateError('SavedItem does not exist');
    final result = envelope.result;
    if (!result.isCurrentSchema) {
      throw StateError('Unsupported analysis schema');
    }
    final currentMetadata = _metadata(existing.entities);
    final titleSource = SavedItemMetadataSourceStorage.fromStorage(
      currentMetadata['titleSource'],
    );
    final categorySource = SavedItemMetadataSourceStorage.fromStorage(
      currentMetadata['categorySource'],
    );
    final actions = _policy.validActions(result);
    final now = _clock.now().toUtc();
    final entities = <String, Object?>{
      ...result.entities,
      SavedItem.analysisMetadataEntityKey: {
        'model': envelope.model,
        'promptVersion': envelope.promptVersion,
        'analyzedAt': now.toIso8601String(),
        'titleSource':
            (titleSource == SavedItemMetadataSource.user
                    ? titleSource
                    : SavedItemMetadataSource.analysis)
                .storageValue,
        'categorySource':
            (categorySource == SavedItemMetadataSource.user
                    ? categorySource
                    : SavedItemMetadataSource.analysis)
                .storageValue,
        'sourceApp': result.sourceApp,
        'requiresAction': result.requiresAction,
        'relevance': result.relevance.storageValue,
        'uncertainFields': result.uncertainFields,
        'searchKeywords': result.searchKeywords,
        'location': result.location?.toJson(),
      },
    };
    final note = existing.entities[SavedItem.userNoteEntityKey];
    if (note is String) entities[SavedItem.userNoteEntityKey] = note;
    final pixelWidth = existing.entities['pixelWidth'];
    if (pixelWidth != null) entities['pixelWidth'] = pixelWidth;
    final pixelHeight = existing.entities['pixelHeight'];
    if (pixelHeight != null) entities['pixelHeight'] = pixelHeight;
    final fields = SavedItemsCompanion(
      title: Value(
        titleSource == SavedItemMetadataSource.user
            ? existing.title
            : result.title,
      ),
      summary: Value(result.summary),
      category: Value(
        categorySource == SavedItemMetadataSource.user
            ? existing.category
            : result.category,
      ),
      subtype: Value(result.subtype),
      intent: Value(result.intent.storageValue),
      status: Value(_policy.statusFor(existing.status, result, actions)),
      eventAt: Value(result.eventAt),
      expiresAt: Value(result.expiresAt),
      location: Value(result.location?.displayValue),
      entities: Value(entities),
      availableActions: Value(actions),
      analysisStatus: Value(_policy.analysisStatusFor(result)),
      analysisVersion: Value(result.schemaVersion),
      confidence: Value(result.confidence),
      updatedAt: Value(now),
    );
    await _writeFinal(existing, fields, removeQueue: true);
  }

  Future<void> markProcessing(String savedItemId) =>
      _database.savedItemsDao.updateFields(
        savedItemId,
        const SavedItemsCompanion(
          analysisStatus: Value(AnalysisStatus.processing),
        ),
      );

  Future<void> markWaitingForRetry(String savedItemId) =>
      _database.savedItemsDao.updateFields(
        savedItemId,
        const SavedItemsCompanion(
          analysisStatus: Value(AnalysisStatus.unprocessed),
        ),
      );

  Future<void> markFailed(String savedItemId) async {
    final existing = await _database.savedItemsDao.findById(
      savedItemId,
      includeDeleted: true,
    );
    if (existing == null) {
      await _database.customStatement(
        'DELETE FROM analysis_queue WHERE saved_item_id = ?',
        [savedItemId],
      );
      return;
    }
    await _writeFinal(
      existing,
      SavedItemsCompanion(
        analysisStatus: const Value(AnalysisStatus.failed),
        updatedAt: Value(_clock.now().toUtc()),
      ),
      removeQueue: true,
    );
  }

  Future<void> _writeFinal(
    SavedItemRow existing,
    SavedItemsCompanion fields, {
    required bool removeQueue,
  }) async {
    final coordinator = _syncCoordinator;
    final shouldSync =
        coordinator != null &&
        coordinator.canSyncOwner(existing.ownerId) &&
        !coordinator.isDemoId(existing.id);
    final pendingStatus = existing.syncStatus == SyncStatus.pendingCreate
        ? SyncStatus.pendingCreate
        : SyncStatus.pendingUpdate;
    final synchronized = shouldSync
        ? fields.copyWith(syncStatus: Value(pendingStatus))
        : fields;
    await _database.transaction(() async {
      await _database.savedItemsDao.updateFields(existing.id, synchronized);
      if (shouldSync) {
        await coordinator.enqueue(
          entityType: SyncEntityType.savedItem,
          entityId: existing.id,
          operation: SyncOperation.update,
        );
      }
      if (removeQueue) {
        await _database.customStatement(
          'DELETE FROM analysis_queue WHERE saved_item_id = ?',
          [existing.id],
        );
      }
    });
    if (shouldSync) coordinator.notifyAfterCommit();
  }

  Map<String, Object?> _metadata(Map<String, Object?> entities) {
    final value = entities[SavedItem.analysisMetadataEntityKey];
    return value is Map ? Map<String, Object?>.from(value) : const {};
  }
}
