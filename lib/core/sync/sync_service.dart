import 'package:kipto/core/repositories/life_admin_mapper.dart';
import 'package:kipto/core/domain/models/source.dart';
import 'package:kipto/core/repositories/source_mapper.dart';
// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:kipto/core/auth/auth_repository.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/sync/remote_data_source.dart';
import 'package:kipto/core/sync/remote_mappers.dart';
import 'package:kipto/core/sync/remote_models.dart';
import 'package:kipto/core/sync/sync_status.dart';
import 'package:uuid/uuid.dart';

final class SyncService {
  SyncService({
    required AppDatabase database,
    required AuthRepository auth,
    required KiptoRemoteDataSource? remote,
    Clock? clock,
    Uuid? uuid,
    this.pushBatchSize = 100,
    this.pullPageSize = 500,
    this.onRemindersChanged,
    this.canSync,
  }) : _database = database,
       _auth = auth,
       _remote = remote,
       _clock = clock ?? const Clock(),
       _uuid = uuid ?? const Uuid();

  final AppDatabase _database;
  final AuthRepository _auth;
  final KiptoRemoteDataSource? _remote;
  final Clock _clock;
  final Uuid _uuid;
  final int pushBatchSize;
  final int pullPageSize;
  final Future<void> Function()? onRemindersChanged;
  final bool Function()? canSync;
  bool _stopping = false;
  final StreamController<SyncStatusSnapshot> _statusController =
      StreamController.broadcast();

  SyncStatusSnapshot _status = const SyncStatusSnapshot(phase: SyncPhase.idle);
  Future<void>? _inFlight;
  bool _runAgain = false;
  bool _initialized = false;
  Timer? _localDebounce;
  Timer? _realtimeDebounce;
  RemoteInvalidationSubscription? _realtime;
  StreamSubscription<void>? _realtimeEvents;
  String? _boundUserId;

  SyncStatusSnapshot get currentStatus => _status;
  Stream<SyncStatusSnapshot> watchStatus() async* {
    yield _status;
    yield* _statusController.stream;
  }

  Future<void> initialize() async {
    if (_initialized || _remote == null || canSync?.call() == false) return;
    _stopping = false;
    _initialized = true;
    await syncNow(SyncReason.startup);
  }

  bool _canContinue(String userId) =>
      !_stopping && canSync?.call() != false && _auth.userId == userId;

  void scheduleSync([SyncReason reason = SyncReason.localChange]) {
    if (_remote == null || _stopping || canSync?.call() == false) return;
    _localDebounce?.cancel();
    _localDebounce = Timer(
      const Duration(milliseconds: 800),
      () => unawaited(syncNow(reason)),
    );
  }

  Future<void> syncNow([SyncReason reason = SyncReason.manual]) {
    if (_remote == null || _stopping || canSync?.call() == false) {
      return Future.value();
    }
    final inFlight = _inFlight;
    if (inFlight != null) {
      _runAgain = true;
      return inFlight;
    }
    final operation = _run(reason);
    _inFlight = operation;
    return operation.whenComplete(() => _inFlight = null);
  }

  Future<void> _run(SyncReason reason) async {
    do {
      _runAgain = false;
      if (_stopping || canSync?.call() == false) return;
      try {
        final session = await _auth.recoverSession();
        if (session == null || !_canContinue(session.user.id)) return;
        if (_boundUserId != session.user.id) await _bindUser(session.user.id);
        if (!_canContinue(session.user.id)) return;
        final now = _clock.now().toUtc();
        _setStatus(
          SyncStatusSnapshot(
            phase: SyncPhase.syncing,
            lastSuccessAt: _status.lastSuccessAt,
            lastAttemptAt: now,
            pendingCount: (await _database.syncQueueDao.pending()).length,
          ),
        );
        final state = await _ensureLocalState();
        if (!_canContinue(session.user.id)) return;
        await _remote!.upsertDevice(
          RemoteDevice(
            id: state.installationId,
            userId: session.user.id,
            platform: defaultTargetPlatform.name,
            lastSeenAt: now,
          ),
        );
        if (!_canContinue(session.user.id)) return;
        // Claiming local-only data belongs to the explicit start/analysis
        // flow. Restoring an existing account never silently merges a library.
        await _pushItems(session.user.id);
        await _pushSources(session.user.id);
        await _pushFacts(session.user.id);
        await _pushActions(session.user.id);
        await _pushReminders(session.user.id);
        await _pullItems(session.user.id);
        await _pullSources(session.user.id);
        await _pullFacts(session.user.id);
        await _pullActions(session.user.id);
        await _pullReminders(session.user.id);
        if (!_canContinue(session.user.id)) return;
        await (_database.update(
          _database.cloudSyncStates,
        )..where((row) => row.id.equals('local'))).write(
          CloudSyncStatesCompanion(
            lastSuccessfulSyncAt: Value(now),
            lastAttemptAt: Value(now),
            lastError: const Value(null),
          ),
        );
        _setStatus(
          SyncStatusSnapshot(
            phase: SyncPhase.idle,
            lastSuccessAt: now,
            lastAttemptAt: now,
            pendingCount: (await _database.syncQueueDao.pending()).length,
          ),
        );
        _log('sync.completed', {
          'reason': reason.name,
          'installation': state.installationId,
        });
      } on Object catch (error) {
        if (_stopping || canSync?.call() == false) return;
        await _recordFailure(error);
      }
    } while (_runAgain);
  }

  Future<void> _bindUser(String userId) async {
    if (_boundUserId != null && _boundUserId != userId) {
      throw StateError('Account changed; local data must be reset first');
    }
    _boundUserId = userId;
    final state = await _ensureLocalState();
    if (state.userId != null && state.userId != userId) {
      throw StateError('Local cloud state belongs to another account');
    }
    await (_database.update(_database.cloudSyncStates)
          ..where((row) => row.id.equals('local')))
        .write(CloudSyncStatesCompanion(userId: Value(userId)));
    if (!_canContinue(userId)) return;
    _realtime ??= await _remote!.subscribeToInvalidations(userId);
    if (!_canContinue(userId)) return;
    _realtimeEvents ??= _realtime!.invalidations.listen((_) {
      _realtimeDebounce?.cancel();
      _realtimeDebounce = Timer(
        const Duration(milliseconds: 500),
        () => unawaited(syncNow(SyncReason.realtime)),
      );
    });
    _log('sync.user.bound', {'installation': state.installationId});
  }

  Future<CloudSyncStateRow> _ensureLocalState() async {
    final existing = await (_database.select(
      _database.cloudSyncStates,
    )..where((row) => row.id.equals('local'))).getSingleOrNull();
    if (existing != null) return existing;
    await _database
        .into(_database.cloudSyncStates)
        .insert(CloudSyncStatesCompanion.insert(installationId: _uuid.v4()));
    return (await (_database.select(
      _database.cloudSyncStates,
    )..where((row) => row.id.equals('local'))).getSingle());
  }

  Future<void> _pushItems(String userId) async {
    final entries = await _latestEntries(SyncEntityType.item);
    for (final chunk in _chunks(entries, pushBatchSize)) {
      if (!_canContinue(userId)) return;
      final rows = await _database.itemsDao.findByIds(chunk.keys);
      final state = await _ensureLocalState();
      final eligible = rows
          .where((row) => row.ownerId == userId)
          .map(
            (row) => itemRowToRemote(
              row,
              userId: userId,
              installationId: state.installationId,
            ),
          )
          .toList(growable: false);
      if (eligible.isNotEmpty) {
        if (!_canContinue(userId)) return;
        final returned = await _remote!.upsertItems(eligible);
        if (!_canContinue(userId)) return;
        await _database.transaction(() async {
          final pendingIds = (await _database.syncQueueDao.pending())
              .map((e) => e.id)
              .toSet();
          for (final remote in returned) {
            if (remote.userId != userId ||
                !pendingIds.contains(chunk[remote.id]?.id)) {
              continue;
            }
            await _database.itemsDao.updateFields(
              remote.id,
              remoteItemUpdate(remote),
            );
          }
          await _removeQueueRows(chunk.values);
        });
      } else {
        await _removeQueueRows(chunk.values);
      }
    }
  }

  Future<void> _pushReminders(String userId) async {
    final entries = await _latestEntries(SyncEntityType.reminder);
    for (final chunk in _chunks(entries, pushBatchSize)) {
      if (!_canContinue(userId)) return;
      final rows = await _database.remindersDao.findByIds(chunk.keys);
      final state = await _ensureLocalState();
      final eligible = rows
          .where((row) => row.ownerId == userId)
          .map(
            (row) => reminderRowToRemote(
              row,
              userId: userId,
              installationId: state.installationId,
            ),
          )
          .toList(growable: false);
      if (eligible.isNotEmpty) {
        if (!_canContinue(userId)) return;
        final returned = await _remote!.upsertReminders(eligible);
        if (!_canContinue(userId)) return;
        await _database.transaction(() async {
          final pendingIds = (await _database.syncQueueDao.pending())
              .map((e) => e.id)
              .toSet();
          for (final remote in returned) {
            if (remote.userId != userId ||
                !pendingIds.contains(chunk[remote.id]?.id)) {
              continue;
            }
            await _database.remindersDao.updateFields(
              remote.id,
              remoteReminderUpdate(remote),
            );
          }
          await _removeQueueRows(chunk.values);
        });
      } else {
        await _removeQueueRows(chunk.values);
      }
    }
  }

  SourcesCompanion _sourceCompanion(Source source) => SourcesCompanion.insert(
    id: source.id,
    itemId: source.itemId,
    ownerId: Value(source.ownerId),
    kind: source.kind.name,
    origin: source.origin.name,
    originalName: source.originalName,
    mimeType: source.mimeType,
    byteSize: source.byteSize,
    contentHash: source.contentHash,
    revision: Value(source.revision),
    textContent: Value(source.textContent),
    pageCount: Value(source.pageCount),
    createdAt: source.createdAt,
    updatedAt: source.updatedAt,
    remoteServerUpdatedAt: Value(source.serverUpdatedAt),
    deletedAt: Value(source.deletedAt),
    syncStatus: SyncStatus.synced,
  );

  Future<void> _pushSources(String userId) async {
    final entries = await _latestEntries(SyncEntityType.source);
    for (final chunk in _chunks(entries, pushBatchSize)) {
      if (!_canContinue(userId)) return;
      final rows = await (_database.select(
        _database.sources,
      )..where((r) => r.id.isIn(chunk.keys) & r.ownerId.equals(userId))).get();
      if (!_canContinue(userId)) return;
      final returned = await _remote!.upsertSources(
        rows.map(sourceFromRow).toList(),
      );
      if (!_canContinue(userId)) return;
      await _database.transaction(() async {
        final pendingIds = (await _database.syncQueueDao.pending())
            .map((e) => e.id)
            .toSet();
        for (final source in returned) {
          if (source.ownerId != userId ||
              !pendingIds.contains(chunk[source.id]?.id)) {
            continue;
          }
          await _database
              .into(_database.sources)
              .insertOnConflictUpdate(_sourceCompanion(source));
        }
        await _removeQueueRows(chunk.values);
      });
    }
  }

  Future<void> _pullSources(String userId) async {
    final state = await _ensureLocalState();
    var offset = 0;
    var cursor = state.lastSourcesCursor;
    while (true) {
      if (!_canContinue(userId)) return;
      final page = await _remote!.fetchSourcesChangedSince(
        cursor: state.lastSourcesCursor,
        offset: offset,
        limit: pullPageSize,
      );
      if (!_canContinue(userId)) return;
      await _database.transaction(() async {
        for (final source in page) {
          if (source.ownerId != userId) continue;
          final parent = await _database.itemsDao.findById(
            source.itemId,
            includeDeleted: true,
          );
          if (parent?.ownerId != userId) {
            throw StateError('Source parent owner mismatch');
          }
          final local = await (_database.select(
            _database.sources,
          )..where((r) => r.id.equals(source.id))).getSingleOrNull();
          if (local == null ||
              _remoteWins(
                local.syncStatus,
                local.updatedAt,
                source.updatedAt,
              )) {
            await _database
                .into(_database.sources)
                .insertOnConflictUpdate(_sourceCompanion(source));
            if (local == null) {
              await _database
                  .into(_database.sourceFiles)
                  .insert(
                    SourceFilesCompanion.insert(
                      sourceId: source.id,
                      availability: const Value('remoteOnly'),
                    ),
                  );
            }
            await _removeEntityQueue(SyncEntityType.source, source.id);
          }
          if (source.serverUpdatedAt != null &&
              (cursor == null || source.serverUpdatedAt!.isAfter(cursor!))) {
            cursor = source.serverUpdatedAt;
          }
        }
      });
      if (page.length < pullPageSize) break;
      offset += page.length;
    }
    await (_database.update(_database.cloudSyncStates)
          ..where((r) => r.id.equals('local')))
        .write(CloudSyncStatesCompanion(lastSourcesCursor: Value(cursor)));
  }

  Future<void> _pushFacts(String userId) async {
    final entries = await _latestEntries(SyncEntityType.fact);
    for (final chunk in _chunks(entries, pushBatchSize)) {
      if (!_canContinue(userId)) return;
      final rows = await (_database.select(
        _database.facts,
      )..where((r) => r.id.isIn(chunk.keys) & r.ownerId.equals(userId))).get();
      if (!_canContinue(userId)) return;
      final returned = await _remote!.upsertFacts(
        rows.map(factFromRow).toList(),
      );
      if (!_canContinue(userId)) return;
      await _database.transaction(() async {
        final pending = (await _database.syncQueueDao.pending())
            .map((e) => e.id)
            .toSet();
        for (final entity in returned) {
          if (entity.ownerId != userId ||
              !pending.contains(chunk[entity.id]?.id)) {
            continue;
          }
          await _database
              .into(_database.facts)
              .insertOnConflictUpdate(factCompanion(entity, SyncStatus.synced));
        }
        await _removeQueueRows(chunk.values);
      });
    }
  }

  Future<void> _pullFacts(String userId) async {
    final state = await _ensureLocalState();
    var cursor = state.lastFactsCursor;
    var offset = 0;
    while (true) {
      if (!_canContinue(userId)) return;
      final page = await _remote!.fetchFactsChangedSince(
        cursor: state.lastFactsCursor,
        offset: offset,
        limit: pullPageSize,
      );
      if (!_canContinue(userId)) return;
      await _database.transaction(() async {
        for (final entity in page) {
          if (entity.ownerId != userId) continue;
          final local = await (_database.select(
            _database.facts,
          )..where((r) => r.id.equals(entity.id))).getSingleOrNull();
          if (local == null ||
              _remoteWins(
                local.syncStatus,
                local.updatedAt,
                entity.updatedAt,
              )) {
            await _database
                .into(_database.facts)
                .insertOnConflictUpdate(
                  factCompanion(entity, SyncStatus.synced),
                );
            await _removeEntityQueue(SyncEntityType.fact, entity.id);
          }
          if (entity.serverUpdatedAt != null &&
              (cursor == null || entity.serverUpdatedAt!.isAfter(cursor!))) {
            cursor = entity.serverUpdatedAt;
          }
        }
      });
      if (page.length < pullPageSize) break;
      offset += page.length;
    }
    await (_database.update(_database.cloudSyncStates)
          ..where((r) => r.id.equals('local')))
        .write(CloudSyncStatesCompanion(lastFactsCursor: Value(cursor)));
  }

  Future<void> _pushActions(String userId) async {
    final entries = await _latestEntries(SyncEntityType.action);
    for (final chunk in _chunks(entries, pushBatchSize)) {
      if (!_canContinue(userId)) return;
      final rows = await (_database.select(
        _database.itemActions,
      )..where((r) => r.id.isIn(chunk.keys) & r.ownerId.equals(userId))).get();
      if (!_canContinue(userId)) return;
      final returned = await _remote!.upsertActions(
        rows.map(actionFromRow).toList(),
      );
      if (!_canContinue(userId)) return;
      await _database.transaction(() async {
        final pending = (await _database.syncQueueDao.pending())
            .map((e) => e.id)
            .toSet();
        for (final entity in returned) {
          if (entity.ownerId != userId ||
              !pending.contains(chunk[entity.id]?.id)) {
            continue;
          }
          await _database
              .into(_database.itemActions)
              .insertOnConflictUpdate(
                actionCompanion(entity, SyncStatus.synced),
              );
        }
        await _removeQueueRows(chunk.values);
      });
    }
  }

  Future<void> _pullActions(String userId) async {
    final state = await _ensureLocalState();
    var cursor = state.lastActionsCursor;
    var offset = 0;
    while (true) {
      if (!_canContinue(userId)) return;
      final page = await _remote!.fetchActionsChangedSince(
        cursor: state.lastActionsCursor,
        offset: offset,
        limit: pullPageSize,
      );
      if (!_canContinue(userId)) return;
      await _database.transaction(() async {
        for (final entity in page) {
          if (entity.ownerId != userId) continue;
          final local = await (_database.select(
            _database.itemActions,
          )..where((r) => r.id.equals(entity.id))).getSingleOrNull();
          if (local == null ||
              _remoteWins(
                local.syncStatus,
                local.updatedAt,
                entity.updatedAt,
              )) {
            await _database
                .into(_database.itemActions)
                .insertOnConflictUpdate(
                  actionCompanion(entity, SyncStatus.synced),
                );
            await _removeEntityQueue(SyncEntityType.action, entity.id);
          }
          if (entity.serverUpdatedAt != null &&
              (cursor == null || entity.serverUpdatedAt!.isAfter(cursor!))) {
            cursor = entity.serverUpdatedAt;
          }
        }
      });
      if (page.length < pullPageSize) break;
      offset += page.length;
    }
    await (_database.update(_database.cloudSyncStates)
          ..where((r) => r.id.equals('local')))
        .write(CloudSyncStatesCompanion(lastActionsCursor: Value(cursor)));
  }

  Future<void> _pullItems(String userId) async {
    final state = await _ensureLocalState();
    var offset = 0;
    DateTime? maxCursor = state.lastItemsCursor;
    while (true) {
      if (!_canContinue(userId)) return;
      final page = await _remote!.fetchItemsChangedSince(
        cursor: state.lastItemsCursor,
        offset: offset,
        limit: pullPageSize,
      );
      if (!_canContinue(userId)) return;
      await _database.transaction(() async {
        for (final remote in page.where((row) => row.userId == userId)) {
          final local = await _database.itemsDao.findById(
            remote.id,
            includeDeleted: true,
          );
          if (local == null) {
            await _database.itemsDao.insertItem(remoteItemInsert(remote));
          } else if (_remoteWins(
            local.syncStatus,
            local.updatedAt,
            remote.clientUpdatedAt,
          )) {
            await _database.itemsDao.updateFields(
              remote.id,
              remoteItemUpdate(remote),
            );
            await _removeEntityQueue(SyncEntityType.item, remote.id);
          }
          if (maxCursor == null || remote.serverUpdatedAt.isAfter(maxCursor!)) {
            maxCursor = remote.serverUpdatedAt;
          }
        }
      });
      if (page.length < pullPageSize) break;
      offset += page.length;
    }
    await (_database.update(_database.cloudSyncStates)
          ..where((row) => row.id.equals('local')))
        .write(CloudSyncStatesCompanion(lastItemsCursor: Value(maxCursor)));
  }

  Future<void> _pullReminders(String userId) async {
    final state = await _ensureLocalState();
    var offset = 0;
    DateTime? maxCursor = state.lastRemindersCursor;
    var changed = false;
    while (true) {
      if (!_canContinue(userId)) return;
      final page = await _remote!.fetchRemindersChangedSince(
        cursor: state.lastRemindersCursor,
        offset: offset,
        limit: pullPageSize,
      );
      if (!_canContinue(userId)) return;
      await _database.transaction(() async {
        for (final remote in page.where((row) => row.userId == userId)) {
          final item = await _database.itemsDao.findById(
            remote.itemId,
            includeDeleted: true,
          );
          if (item == null) continue;
          final local = await _database.remindersDao.findById(remote.id);
          if (local == null) {
            await _database.remindersDao.insertReminder(
              remoteReminderInsert(remote),
            );
            changed = true;
          } else if (_remoteWins(
            local.syncStatus,
            local.updatedAt,
            remote.clientUpdatedAt,
          )) {
            await _database.remindersDao.updateFields(
              remote.id,
              remoteReminderUpdate(remote),
            );
            await _removeEntityQueue(SyncEntityType.reminder, remote.id);
            changed = true;
          }
          if (maxCursor == null || remote.serverUpdatedAt.isAfter(maxCursor!)) {
            maxCursor = remote.serverUpdatedAt;
          }
        }
      });
      if (page.length < pullPageSize) break;
      offset += page.length;
    }
    await (_database.update(_database.cloudSyncStates)
          ..where((row) => row.id.equals('local')))
        .write(CloudSyncStatesCompanion(lastRemindersCursor: Value(maxCursor)));
    if (changed) {
      try {
        await onRemindersChanged?.call();
      } on Object {
        // Notifications are a local projection. Their failure must not make
        // an already-converged cloud sync look like an unsynced write.
        _log('sync.reminder_projection_failed', const {});
      }
    }
  }

  bool _remoteWins(
    SyncStatus localStatus,
    DateTime localUpdatedAt,
    DateTime remoteUpdatedAt,
  ) =>
      localStatus == SyncStatus.synced ||
      localStatus == SyncStatus.localOnly ||
      !localUpdatedAt.toUtc().isAfter(remoteUpdatedAt);

  Future<Map<String, SyncQueueRow>> _latestEntries(SyncEntityType type) async {
    final output = <String, SyncQueueRow>{};
    for (final entry in await _database.syncQueueDao.pending()) {
      if (entry.entityType == type) output[entry.entityId] = entry;
    }
    return output;
  }

  Iterable<Map<String, SyncQueueRow>> _chunks(
    Map<String, SyncQueueRow> source,
    int size,
  ) sync* {
    final entries = source.entries.toList(growable: false);
    for (var index = 0; index < entries.length; index += size) {
      yield Map.fromEntries(entries.skip(index).take(size));
    }
  }

  Future<void> _removeQueueRows(Iterable<SyncQueueRow> entries) async {
    for (final entry in entries) {
      await _database.syncQueueDao.remove(entry.id);
    }
  }

  Future<void> _removeEntityQueue(SyncEntityType type, String entityId) =>
      (_database.delete(_database.syncQueue)..where(
            (row) =>
                row.entityType.equalsValue(type) &
                row.entityId.equals(entityId),
          ))
          .go();

  Future<void> _recordFailure(Object error) async {
    final now = _clock.now().toUtc();
    for (final entry in await _database.syncQueueDao.pending()) {
      await _database.syncQueueDao.updateFields(
        entry.id,
        SyncQueueCompanion(
          attempts: Value(entry.attempts + 1),
          lastAttemptAt: Value(now),
          lastError: Value(error.runtimeType.toString()),
        ),
      );
    }
    final state = await _ensureLocalState();
    await (_database.update(
      _database.cloudSyncStates,
    )..where((row) => row.id.equals('local'))).write(
      CloudSyncStatesCompanion(
        lastAttemptAt: Value(now),
        lastError: Value(error.runtimeType.toString()),
      ),
    );
    _setStatus(
      SyncStatusSnapshot(
        phase: SyncPhase.offlineOrFailed,
        lastSuccessAt: state.lastSuccessfulSyncAt,
        lastAttemptAt: now,
        pendingCount: (await _database.syncQueueDao.pending()).length,
        errorMessage: 'Your changes are safe on this device.',
      ),
    );
    _log('sync.failed', {'type': error.runtimeType.toString()});
  }

  void _setStatus(SyncStatusSnapshot value) {
    _status = value;
    if (!_statusController.isClosed) _statusController.add(value);
  }

  void _log(String event, Map<String, Object?> fields) {
    if (kDebugMode) debugPrint('$event $fields');
  }

  Future<void> stopForAccountChange() async {
    _stopping = true;
    _runAgain = false;
    _localDebounce?.cancel();
    _realtimeDebounce?.cancel();
    await _inFlight;
    await _realtimeEvents?.cancel();
    await _realtime?.dispose();
    _realtimeDebounce?.cancel();
    _realtimeEvents = null;
    _realtime = null;
    _boundUserId = null;
    _initialized = false;
  }

  Future<void> dispose() async {
    await stopForAccountChange();
    await _statusController.close();
  }
}
