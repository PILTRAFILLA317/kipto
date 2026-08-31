// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:kipto/core/auth/auth_repository.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/features/cloud_preview/data/cloud_preview_preferences.dart';
import 'package:kipto/features/cloud_preview/domain/cloud_preview_cache.dart';
import 'package:kipto/features/cloud_preview/domain/cloud_preview_generator.dart';
import 'package:kipto/features/cloud_preview/domain/cloud_preview_models.dart';
import 'package:kipto/features/cloud_preview/domain/cloud_preview_repository.dart';

final class CloudPreviewBackupService {
  CloudPreviewBackupService({
    required AppDatabase database,
    required AuthRepository auth,
    required CloudPreviewGenerator generator,
    required CloudPreviewRepository? remote,
    required CloudPreviewCache cache,
    required CloudPreviewPreferences preferences,
    required LocalSyncCoordinator syncCoordinator,
    Clock? clock,
    this.maxConcurrentUploads = 2,
    this.maxAttempts = 3,
  }) : _database = database,
       _auth = auth,
       _generator = generator,
       _remote = remote,
       _cache = cache,
       _preferences = preferences,
       _syncCoordinator = syncCoordinator,
       _clock = clock ?? const Clock();

  final AppDatabase _database;
  final AuthRepository _auth;
  final CloudPreviewGenerator _generator;
  final CloudPreviewRepository? _remote;
  final CloudPreviewCache _cache;
  final CloudPreviewPreferences _preferences;
  final LocalSyncCoordinator _syncCoordinator;
  final Clock _clock;
  final int maxConcurrentUploads;
  final int maxAttempts;

  CloudPreviewPreferenceState _preferenceState =
      const CloudPreviewPreferenceState();
  Future<void>? _inFlight;
  bool _foreground = false;
  bool _initialized = false;
  Timer? _retryTimer;

  CloudPreviewPreferenceState get preferenceState => _preferenceState;

  Future<void> initialize({bool foreground = true}) async {
    if (_initialized) {
      _foreground = foreground;
      if (foreground) await run();
      return;
    }
    _initialized = true;
    _preferenceState = await _preferences.load();
    _foreground = foreground;
    await (_database.update(_database.previewTransferJobs)..where(
          (job) => job.state.equals(PreviewTransferState.uploading.name),
        ))
        .write(
          PreviewTransferJobsCompanion(
            state: Value(
              _preferenceState.userPaused
                  ? PreviewTransferState.paused.name
                  : PreviewTransferState.queued.name,
            ),
          ),
        );
    if (!_preferenceState.userPaused) await run();
  }

  Future<void> onForeground() async {
    _foreground = true;
    await run();
  }

  void onBackground() {
    _foreground = false;
    _retryTimer?.cancel();
  }

  Future<void> setMode(CloudImageSyncMode mode) async {
    await _preferences.setMode(mode);
    _preferenceState = _preferenceState.copyWith(mode: mode, loaded: true);
    if (mode == CloudImageSyncMode.optimizedPreviews) await run();
  }

  Future<void> pause() async {
    await _preferences.setUserPaused(true);
    _preferenceState = _preferenceState.copyWith(
      userPaused: true,
      loaded: true,
    );
    await (_database.update(_database.previewTransferJobs)..where(
          (job) =>
              job.operation.equals(PreviewTransferOperation.upload.name) &
              job.state.isIn([
                PreviewTransferState.queued.name,
                PreviewTransferState.retryScheduled.name,
              ]),
        ))
        .write(
          PreviewTransferJobsCompanion(
            state: Value(PreviewTransferState.paused.name),
            lastErrorCode: const Value(null),
          ),
        );
  }

  Future<void> resume() async {
    await _preferences.setUserPaused(false);
    _preferenceState = _preferenceState.copyWith(
      userPaused: false,
      loaded: true,
    );
    await (_database.update(_database.previewTransferJobs)..where(
          (job) =>
              job.operation.equals(PreviewTransferOperation.upload.name) &
              job.state.equals(PreviewTransferState.paused.name) &
              job.lastErrorCode.isNull(),
        ))
        .write(
          PreviewTransferJobsCompanion(
            state: Value(PreviewTransferState.queued.name),
          ),
        );
    await run();
  }

  Future<void> enqueueSavedItem(String savedItemId) async {
    if (_preferenceState.mode != CloudImageSyncMode.optimizedPreviews) return;
    final row = await _database.savedItemsDao.findById(savedItemId);
    final userId = _auth.userId;
    if (row == null ||
        userId == null ||
        row.ownerId != userId ||
        row.localAssetId == null ||
        !row.originalAvailable ||
        row.cloudPreviewPath != null) {
      return;
    }
    await _enqueue(row.id, PreviewTransferOperation.upload);
    _log('preview.queued', {'savedItemId': row.id});
    await run();
  }

  Future<int> enqueueAllMissing() async {
    if (_preferenceState.mode != CloudImageSyncMode.optimizedPreviews) return 0;
    final userId = _auth.userId;
    if (userId == null) return 0;
    final rows =
        await (_database.select(_database.savedItems)..where(
              (item) =>
                  item.ownerId.equals(userId) &
                  item.deletedAt.isNull() &
                  item.localAssetId.isNotNull() &
                  item.originalAvailable.equals(true) &
                  item.cloudPreviewPath.isNull(),
            ))
            .get();
    for (var offset = 0; offset < rows.length; offset += 100) {
      final page = rows.sublist(offset, (offset + 100).clamp(0, rows.length));
      await _database.batch((batch) {
        for (final row in page) {
          batch.insert(
            _database.previewTransferJobs,
            PreviewTransferJobsCompanion.insert(
              savedItemId: row.id,
              operation: PreviewTransferOperation.upload.name,
              state: _preferenceState.userPaused
                  ? PreviewTransferState.paused.name
                  : PreviewTransferState.queued.name,
              createdAt: _clock.now().toUtc(),
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      });
      await Future<void>.delayed(Duration.zero);
    }
    await run();
    return rows.length;
  }

  Future<void> enqueueDelete(String savedItemId) async {
    final row = await _database.savedItemsDao.findById(
      savedItemId,
      includeDeleted: true,
    );
    if (row?.cloudPreviewPath == null) return;
    await _enqueue(savedItemId, PreviewTransferOperation.delete);
    await run();
  }

  Future<void> removeAllCloudPreviews() async {
    await setMode(CloudImageSyncMode.metadataOnly);
    final active = _inFlight;
    if (active != null) await active;
    final userId = _auth.userId;
    if (userId == null) return;
    final rows =
        await (_database.select(_database.savedItems)..where(
              (item) =>
                  item.ownerId.equals(userId) &
                  item.cloudPreviewPath.isNotNull(),
            ))
            .get();
    await _database.batch((batch) {
      for (final row in rows) {
        batch.insert(
          _database.previewTransferJobs,
          PreviewTransferJobsCompanion.insert(
            savedItemId: row.id,
            operation: PreviewTransferOperation.delete.name,
            state: PreviewTransferState.queued.name,
            createdAt: _clock.now().toUtc(),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
    await run();
    await clearDownloadedPreviews();
  }

  Future<void> retryFailed() async {
    await (_database.update(_database.previewTransferJobs)
          ..where((job) => job.state.equals(PreviewTransferState.paused.name)))
        .write(
          PreviewTransferJobsCompanion(
            state: Value(PreviewTransferState.queued.name),
            attemptCount: const Value(0),
            nextAttemptAt: const Value(null),
            lastErrorCode: const Value(null),
          ),
        );
    await run();
  }

  Future<void> clearDownloadedPreviews() async {
    await _cache.clear();
    await _database
        .update(_database.savedItems)
        .write(const SavedItemsCompanion(previewCachePath: Value(null)));
  }

  Stream<CloudPreviewCounts> watchCounts() {
    final userId = _auth.userId;
    if (userId == null) return Stream.value(const CloudPreviewCounts());
    return _database
        .customSelect(
          '''
          SELECT
            SUM(CASE WHEN deleted_at IS NULL AND local_asset_id IS NOT NULL
              AND original_available = 1 AND cloud_preview_path IS NULL
              THEN 1 ELSE 0 END) AS eligible,
            SUM(CASE WHEN deleted_at IS NULL AND cloud_preview_path IS NOT NULL
              THEN 1 ELSE 0 END) AS uploaded,
            (SELECT COUNT(*) FROM preview_transfer_jobs
              WHERE operation = 'upload' AND (
                state IN ('queued', 'uploading', 'retryScheduled') OR
                (state = 'paused' AND last_error_code IS NULL)
              )) AS waiting,
            (SELECT COUNT(*) FROM preview_transfer_jobs
              WHERE operation = 'upload' AND state = 'paused'
                AND last_error_code IS NOT NULL) AS failed
          FROM saved_items WHERE owner_id = ?
          ''',
          variables: [Variable.withString(userId)],
          readsFrom: {_database.savedItems, _database.previewTransferJobs},
        )
        .watchSingle()
        .map(
          (row) => CloudPreviewCounts(
            eligible: row.read<int?>('eligible') ?? 0,
            uploaded: row.read<int?>('uploaded') ?? 0,
            waiting: row.read<int>('waiting'),
            failed: row.read<int>('failed'),
          ),
        );
  }

  Future<void> _enqueue(
    String savedItemId,
    PreviewTransferOperation operation,
  ) => _database
      .into(_database.previewTransferJobs)
      .insertOnConflictUpdate(
        PreviewTransferJobsCompanion.insert(
          savedItemId: savedItemId,
          operation: operation.name,
          state:
              operation == PreviewTransferOperation.upload &&
                  _preferenceState.userPaused
              ? PreviewTransferState.paused.name
              : PreviewTransferState.queued.name,
          createdAt: _clock.now().toUtc(),
        ),
      );

  Future<void> run() {
    if (!_foreground || _remote == null) return Future.value();
    final active = _inFlight;
    if (active != null) {
      return active;
    }
    final operation = _runLoop();
    final tracked = operation.whenComplete(() => _inFlight = null);
    _inFlight = tracked;
    return tracked;
  }

  Future<void> _runLoop() async {
    do {
      final now = _clock.now().toUtc();
      final due =
          await (_database.select(_database.previewTransferJobs)
                ..where(
                  (job) =>
                      job.state.equals(PreviewTransferState.queued.name) |
                      (job.state.equals(
                            PreviewTransferState.retryScheduled.name,
                          ) &
                          (job.nextAttemptAt.isNull() |
                              job.nextAttemptAt.isSmallerOrEqualValue(now))),
                )
                ..orderBy([(job) => OrderingTerm.asc(job.createdAt)]))
              .get();
      if (due.isEmpty) {
        await _scheduleNextRetry();
        return;
      }
      final deletes = due
          .where((job) => job.operation == PreviewTransferOperation.delete.name)
          .take(100)
          .toList();
      if (deletes.isNotEmpty) {
        await _processDeleteBatch(deletes);
        continue;
      }
      if (_preferenceState.userPaused ||
          _preferenceState.mode != CloudImageSyncMode.optimizedPreviews) {
        return;
      }
      await Future.wait(
        due
            .where(
              (job) => job.operation == PreviewTransferOperation.upload.name,
            )
            .take(maxConcurrentUploads)
            .map(_processUpload),
      );
    } while (true);
  }

  Future<void> _scheduleNextRetry() async {
    _retryTimer?.cancel();
    if (!_foreground) return;
    final next =
        await (_database.select(_database.previewTransferJobs)
              ..where(
                (job) =>
                    job.state.equals(PreviewTransferState.retryScheduled.name) &
                    job.nextAttemptAt.isNotNull(),
              )
              ..orderBy([(job) => OrderingTerm.asc(job.nextAttemptAt)])
              ..limit(1))
            .getSingleOrNull();
    final at = next?.nextAttemptAt;
    if (at == null) return;
    final delay = at.difference(_clock.now().toUtc());
    _retryTimer = Timer(delay.isNegative ? Duration.zero : delay, run);
  }

  Future<void> _processUpload(PreviewTransferJobRow job) async {
    await _markUploading(job.savedItemId);
    final started = _clock.now().toUtc();
    try {
      final userId = _auth.userId;
      final item = await _database.savedItemsDao.findById(job.savedItemId);
      if (userId == null || item == null || item.ownerId != userId) {
        await _removeJob(job.savedItemId);
        return;
      }
      if (item.cloudPreviewPath != null) {
        await _removeJob(job.savedItemId);
        return;
      }
      final assetId = item.localAssetId;
      if (assetId == null || !item.originalAvailable) {
        await _failPermanently(job, 'missing_original');
        return;
      }
      _log('preview.upload.started', {'savedItemId': item.id});
      final preview = await _generator.generate(assetId);
      if (preview == null) {
        await _failPermanently(job, 'missing_original');
        return;
      }
      _log('preview.generated', {
        'savedItemId': item.id,
        'bytes': preview.bytes.lengthInBytes,
        'width': preview.width,
        'height': preview.height,
      });
      final path = deterministicCloudPreviewPath(userId, item.id);
      await _remote!.upload(path: path, preview: preview);
      await _database.transaction(() async {
        final current = await _database.savedItemsDao.findById(
          item.id,
          includeDeleted: true,
        );
        if (current == null) return;
        await _database.savedItemsDao.updateFields(
          current.id,
          SavedItemsCompanion(
            cloudPreviewPath: Value(path),
            updatedAt: Value(_clock.now().toUtc()),
            syncStatus: Value(
              current.syncStatus == SyncStatus.pendingCreate
                  ? SyncStatus.pendingCreate
                  : SyncStatus.pendingUpdate,
            ),
          ),
        );
        await _syncCoordinator.enqueue(
          entityType: SyncEntityType.savedItem,
          entityId: current.id,
          operation: SyncOperation.update,
        );
        if (current.deletedAt == null) {
          await _removeJob(current.id);
        } else {
          await _database
              .into(_database.previewTransferJobs)
              .insertOnConflictUpdate(
                PreviewTransferJobsCompanion.insert(
                  savedItemId: current.id,
                  operation: PreviewTransferOperation.delete.name,
                  state: PreviewTransferState.queued.name,
                  createdAt: _clock.now().toUtc(),
                ),
              );
        }
      });
      _syncCoordinator.notifyAfterCommit();
      _log('preview.upload.completed', {
        'savedItemId': item.id,
        'durationMs': _clock.now().toUtc().difference(started).inMilliseconds,
      });
    } on Object catch (error) {
      await _scheduleRetry(job, error);
    }
  }

  Future<void> _processDeleteBatch(List<PreviewTransferJobRow> jobs) async {
    for (final job in jobs) {
      await _markUploading(job.savedItemId);
    }
    final entries = <(PreviewTransferJobRow, SavedItemRow)>[];
    final userId = _auth.userId;
    for (final job in jobs) {
      final item = await _database.savedItemsDao.findById(
        job.savedItemId,
        includeDeleted: true,
      );
      final path = item?.cloudPreviewPath;
      if (item == null ||
          userId == null ||
          item.ownerId != userId ||
          path == null ||
          !path.startsWith('$userId/')) {
        await _removeJob(job.savedItemId);
      } else {
        entries.add((job, item));
      }
    }
    if (entries.isEmpty) return;
    try {
      await _remote!.delete(entries.map((entry) => entry.$2.cloudPreviewPath!));
      await _database.transaction(() async {
        for (final entry in entries) {
          final item = entry.$2;
          await _database.savedItemsDao.updateFields(
            item.id,
            SavedItemsCompanion(
              cloudPreviewPath: const Value(null),
              previewCachePath: const Value(null),
              updatedAt: Value(_clock.now().toUtc()),
              syncStatus: Value(
                item.deletedAt == null
                    ? SyncStatus.pendingUpdate
                    : SyncStatus.pendingDelete,
              ),
            ),
          );
          await _syncCoordinator.enqueue(
            entityType: SyncEntityType.savedItem,
            entityId: item.id,
            operation: item.deletedAt == null
                ? SyncOperation.update
                : SyncOperation.delete,
          );
          await _removeJob(item.id);
        }
      });
      _syncCoordinator.notifyAfterCommit();
    } on Object catch (error) {
      for (final entry in entries) {
        await _scheduleRetry(entry.$1, error);
      }
    }
  }

  Future<void> _markUploading(String id) =>
      (_database.update(
        _database.previewTransferJobs,
      )..where((job) => job.savedItemId.equals(id))).write(
        PreviewTransferJobsCompanion(
          state: Value(PreviewTransferState.uploading.name),
        ),
      );

  Future<void> _scheduleRetry(PreviewTransferJobRow job, Object error) async {
    final attempts = job.attemptCount + 1;
    final code = error.runtimeType.toString();
    if (attempts >= maxAttempts) {
      await (_database.update(
        _database.previewTransferJobs,
      )..where((row) => row.savedItemId.equals(job.savedItemId))).write(
        PreviewTransferJobsCompanion(
          state: Value(PreviewTransferState.paused.name),
          attemptCount: Value(attempts),
          nextAttemptAt: const Value(null),
          lastErrorCode: Value(code),
        ),
      );
    } else {
      await (_database.update(
        _database.previewTransferJobs,
      )..where((row) => row.savedItemId.equals(job.savedItemId))).write(
        PreviewTransferJobsCompanion(
          state: Value(PreviewTransferState.retryScheduled.name),
          attemptCount: Value(attempts),
          nextAttemptAt: Value(
            _clock.now().toUtc().add(
              Duration(seconds: 5 * (1 << (attempts - 1))),
            ),
          ),
          lastErrorCode: Value(code),
        ),
      );
    }
    _log('preview.upload.failed', {
      'savedItemId': job.savedItemId,
      'errorCode': code,
      'attempt': attempts,
    });
  }

  Future<void> _failPermanently(PreviewTransferJobRow job, String code) =>
      (_database.update(
        _database.previewTransferJobs,
      )..where((row) => row.savedItemId.equals(job.savedItemId))).write(
        PreviewTransferJobsCompanion(
          state: Value(PreviewTransferState.paused.name),
          lastErrorCode: Value(code),
        ),
      );

  Future<void> _removeJob(String id) => (_database.delete(
    _database.previewTransferJobs,
  )..where((job) => job.savedItemId.equals(id))).go();

  void _log(String event, Map<String, Object?> fields) {
    if (kDebugMode) debugPrint('$event $fields');
  }
}
