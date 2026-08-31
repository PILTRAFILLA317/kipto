// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:kipto/core/auth/auth_repository.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/sync/remote_data_source.dart';
import 'package:kipto/core/sync/remote_mappers.dart';
import 'package:kipto/core/sync/remote_models.dart';
import 'package:kipto/core/sync/sync_status.dart';
import 'package:kipto/dev/seed/development_seed.dart';
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
  StreamSubscription<Object?>? _authEvents;
  String? _boundUserId;

  SyncStatusSnapshot get currentStatus => _status;

  Stream<SyncStatusSnapshot> watchStatus() async* {
    yield _status;
    yield* _statusController.stream;
  }

  Future<void> initialize() async {
    if (_initialized || _remote == null) return;
    _initialized = true;
    try {
      final session = await _auth.recoverSession();
      if (session == null) return;
      await _bindUser(session.user.id);
      _authEvents = _auth.watchAuthState().listen((state) {
        final next = state.userId;
        if (next != null && _boundUserId != null && next != _boundUserId) {
          _setStatus(
            SyncStatusSnapshot(
              phase: SyncPhase.offlineOrFailed,
              lastSuccessAt: _status.lastSuccessAt,
              pendingCount: _status.pendingCount,
              errorMessage:
                  'Account changed; cloud reconciliation is required.',
            ),
          );
        }
      });
      await syncNow(SyncReason.startup);
    } on Object catch (error) {
      await _recordFailure(error);
    }
  }

  void scheduleSync([SyncReason reason = SyncReason.localChange]) {
    if (_remote == null) return;
    _localDebounce?.cancel();
    _localDebounce = Timer(
      const Duration(milliseconds: 800),
      () => unawaited(syncNow(reason)),
    );
  }

  Future<void> syncNow([SyncReason reason = SyncReason.manual]) {
    if (_remote == null) return Future.value();
    final active = _inFlight;
    if (active != null) {
      _runAgain = true;
      return active;
    }
    final operation = _runSerial(reason);
    _inFlight = operation;
    return operation.whenComplete(() => _inFlight = null);
  }

  Future<void> _runSerial(SyncReason reason) async {
    var nextReason = reason;
    do {
      _runAgain = false;
      await _runOnce(nextReason);
      nextReason = SyncReason.retry;
    } while (_runAgain);
  }

  Future<void> _runOnce(SyncReason reason) async {
    final started = _clock.now().toUtc();
    final session = await _auth.recoverSession();
    final userId = session?.user.id;
    if (userId == null) return;
    if (_boundUserId == null) await _bindUser(userId);
    if (_boundUserId != userId) {
      throw StateError('Account switch requires reconciliation');
    }
    final state = await _ensureLocalState();
    if (state.userId != null && state.userId != userId) {
      throw StateError('Local cloud state belongs to another account');
    }
    final pendingBefore = await _database.syncQueueDao.pending();
    _setStatus(
      SyncStatusSnapshot(
        phase: SyncPhase.syncing,
        lastSuccessAt: state.lastSuccessfulSyncAt,
        lastAttemptAt: started,
        pendingCount: pendingBefore.length,
      ),
    );
    _log('sync.started', {'reason': reason.name});
    await _database
        .into(_database.cloudSyncStates)
        .insertOnConflictUpdate(
          CloudSyncStatesCompanion(
            id: const Value('local'),
            installationId: Value(state.installationId),
            userId: Value(userId),
            lastAttemptAt: Value(started),
            lastError: const Value(null),
          ),
        );
    try {
      await _claimUnownedData(userId);
      await _remote!.upsertDevice(
        RemoteDevice(
          id: state.installationId,
          userId: userId,
          platform: defaultTargetPlatform.name,
          lastSeenAt: started,
        ),
      );
      await _push(userId, state.installationId);
      await _pullSavedItems(userId);
      await _pullReminders(userId);
      try {
        await onRemindersChanged?.call();
      } on Object {
        // Notifications are a device-local projection and never fail sync.
      }
      final completed = _clock.now().toUtc();
      await (_database.update(
        _database.cloudSyncStates,
      )..where((row) => row.id.equals('local'))).write(
        CloudSyncStatesCompanion(
          lastSuccessfulSyncAt: Value(completed),
          lastAttemptAt: Value(started),
          lastError: const Value(null),
        ),
      );
      final pending = await _database.syncQueueDao.pending();
      _setStatus(
        SyncStatusSnapshot(
          phase: SyncPhase.idle,
          lastSuccessAt: completed,
          lastAttemptAt: started,
          pendingCount: pending.length,
        ),
      );
      _log('sync.completed', {
        'durationMs': completed.difference(started).inMilliseconds,
        'pending': pending.length,
      });
    } on Object catch (error) {
      await _registerQueueFailure(error);
      await _recordFailure(error, attemptedAt: started);
    }
  }

  Future<void> _bindUser(String userId) async {
    _boundUserId = userId;
    await _realtimeEvents?.cancel();
    await _realtime?.dispose();
    _realtime = await _remote!.subscribeToInvalidations(userId);
    _realtimeEvents = _realtime!.invalidations.listen((_) {
      _log('sync.realtime.invalidated', const {});
      _realtimeDebounce?.cancel();
      _realtimeDebounce = Timer(
        const Duration(milliseconds: 600),
        () => unawaited(syncNow(SyncReason.realtime)),
      );
    });
  }

  Future<CloudSyncStateRow> _ensureLocalState() async {
    final existing = await (_database.select(
      _database.cloudSyncStates,
    )..where((row) => row.id.equals('local'))).getSingleOrNull();
    if (existing != null) return existing;
    final companion = CloudSyncStatesCompanion.insert(
      installationId: _uuid.v4(),
    );
    await _database.into(_database.cloudSyncStates).insert(companion);
    return (_database.select(
      _database.cloudSyncStates,
    )..where((row) => row.id.equals('local'))).getSingle();
  }

  Future<void> _claimUnownedData(String userId) async {
    final unownedItems =
        await (_database.select(_database.savedItems)..where(
              (row) =>
                  row.ownerId.isNull() &
                  row.id.isNotIn(DevelopmentSeed.knownItemIds),
            ))
            .get();
    final unownedReminders =
        await (_database.select(_database.reminders)..where(
              (row) =>
                  row.ownerId.isNull() &
                  row.savedItemId.isNotIn(DevelopmentSeed.knownItemIds),
            ))
            .get();
    if (unownedItems.isEmpty && unownedReminders.isEmpty) return;
    await _database.transaction(() async {
      for (final item in unownedItems) {
        await _database.savedItemsDao.updateFields(
          item.id,
          SavedItemsCompanion(
            ownerId: Value(userId),
            syncStatus: const Value(SyncStatus.pendingCreate),
          ),
        );
        await _enqueue(item.id, SyncEntityType.savedItem, SyncOperation.create);
      }
      for (final reminder in unownedReminders) {
        await _database.remindersDao.updateFields(
          reminder.id,
          RemindersCompanion(
            ownerId: Value(userId),
            syncStatus: const Value(SyncStatus.pendingCreate),
          ),
        );
        await _enqueue(
          reminder.id,
          SyncEntityType.reminder,
          SyncOperation.create,
        );
      }
    });
  }

  Future<void> _enqueue(
    String entityId,
    SyncEntityType type,
    SyncOperation operation,
  ) => _database.syncQueueDao.enqueue(
    SyncQueueCompanion.insert(
      id: _uuid.v4(),
      entityType: type,
      entityId: entityId,
      operation: operation,
      createdAt: _clock.now().toUtc(),
    ),
  );

  Future<void> _push(String userId, String installationId) async {
    final queue = await _database.syncQueueDao.pending();
    final grouped = <String, List<SyncQueueRow>>{};
    for (final entry in queue) {
      grouped
          .putIfAbsent('${entry.entityType.name}:${entry.entityId}', () => [])
          .add(entry);
    }
    final savedEntries = grouped.values
        .where(
          (entries) => entries.first.entityType == SyncEntityType.savedItem,
        )
        .toList();
    final reminderEntries = grouped.values
        .where((entries) => entries.first.entityType == SyncEntityType.reminder)
        .toList();
    await _pushSavedItems(savedEntries, userId, installationId);
    await _pushReminders(reminderEntries, userId, installationId);
  }

  Future<void> _pushSavedItems(
    List<List<SyncQueueRow>> groups,
    String userId,
    String installationId,
  ) async {
    final pending = <(SavedItemRow, List<SyncQueueRow>)>[];
    for (final group in groups) {
      final row = await _database.savedItemsDao.findById(
        group.first.entityId,
        includeDeleted: true,
      );
      if (row == null) {
        await _removeQueueRows(group);
        continue;
      }
      if (row.ownerId != userId) continue;
      if (row.deletedAt != null && row.remoteServerUpdatedAt == null) {
        await _completeGroup(group, savedItemId: row.id);
      } else {
        pending.add((row, group));
      }
    }
    for (var offset = 0; offset < pending.length; offset += pushBatchSize) {
      final batch = pending.sublist(
        offset,
        (offset + pushBatchSize).clamp(0, pending.length),
      );
      final response = await _remote!.upsertSavedItems(
        batch
            .map(
              (entry) => savedItemRowToRemote(
                entry.$1,
                userId: userId,
                installationId: installationId,
              ),
            )
            .toList(),
      );
      final byId = {for (final row in response) row.id: row};
      await _database.transaction(() async {
        for (final entry in batch) {
          final remote = byId[entry.$1.id];
          if (remote == null) throw StateError('Upsert omitted saved item');
          final current = await _database.savedItemsDao.findById(
            entry.$1.id,
            includeDeleted: true,
          );
          if (current == null ||
              !current.updatedAt.isAtSameMomentAs(entry.$1.updatedAt)) {
            continue;
          }
          await _database.savedItemsDao.updateFields(
            entry.$1.id,
            remote.clientUpdatedAt.isAfter(entry.$1.updatedAt)
                ? remoteSavedItemUpdate(remote, localEntities: current.entities)
                : SavedItemsCompanion(
                    syncStatus: const Value(SyncStatus.synced),
                    lastSyncedAt: Value(remote.serverUpdatedAt),
                    remoteServerUpdatedAt: Value(remote.serverUpdatedAt),
                  ),
          );
          await _removeQueueRows(entry.$2);
        }
      });
    }
  }

  Future<void> _pushReminders(
    List<List<SyncQueueRow>> groups,
    String userId,
    String installationId,
  ) async {
    final pending = <(ReminderRow, List<SyncQueueRow>)>[];
    for (final group in groups) {
      final row = await _database.remindersDao.findById(group.first.entityId);
      if (row == null) {
        await _removeQueueRows(group);
        continue;
      }
      if (row.ownerId != userId) continue;
      if (row.deletedAt != null && row.remoteServerUpdatedAt == null) {
        await _completeGroup(group, reminderId: row.id);
      } else {
        pending.add((row, group));
      }
    }
    for (var offset = 0; offset < pending.length; offset += pushBatchSize) {
      final batch = pending.sublist(
        offset,
        (offset + pushBatchSize).clamp(0, pending.length),
      );
      final response = await _remote!.upsertReminders(
        batch
            .map(
              (entry) => reminderRowToRemote(
                entry.$1,
                userId: userId,
                installationId: installationId,
              ),
            )
            .toList(),
      );
      final byId = {for (final row in response) row.id: row};
      await _database.transaction(() async {
        for (final entry in batch) {
          final remote = byId[entry.$1.id];
          if (remote == null) throw StateError('Upsert omitted reminder');
          final current = await _database.remindersDao.findById(entry.$1.id);
          if (current == null ||
              !current.updatedAt.isAtSameMomentAs(entry.$1.updatedAt)) {
            continue;
          }
          await _database.remindersDao.updateFields(
            entry.$1.id,
            remote.clientUpdatedAt.isAfter(entry.$1.updatedAt)
                ? remoteReminderUpdate(remote)
                : RemindersCompanion(
                    syncStatus: const Value(SyncStatus.synced),
                    lastSyncedAt: Value(remote.serverUpdatedAt),
                    remoteServerUpdatedAt: Value(remote.serverUpdatedAt),
                  ),
          );
          await _removeQueueRows(entry.$2);
        }
      });
    }
  }

  Future<void> _completeGroup(
    List<SyncQueueRow> group, {
    String? savedItemId,
    String? reminderId,
  }) async {
    await _database.transaction(() async {
      if (savedItemId != null) {
        await _database.savedItemsDao.updateFields(
          savedItemId,
          const SavedItemsCompanion(syncStatus: Value(SyncStatus.synced)),
        );
      }
      if (reminderId != null) {
        await _database.remindersDao.updateFields(
          reminderId,
          const RemindersCompanion(syncStatus: Value(SyncStatus.synced)),
        );
      }
      await _removeQueueRows(group);
    });
  }

  Future<void> _pullSavedItems(String userId) async {
    final state = await _ensureLocalState();
    var offset = 0;
    DateTime? maxCursor = state.lastSavedItemsCursor;
    while (true) {
      final page = await _remote!.fetchSavedItemsChangedSince(
        cursor: state.lastSavedItemsCursor,
        offset: offset,
        limit: pullPageSize,
      );
      await _database.transaction(() async {
        for (final remote in page) {
          if (remote.userId != userId) continue;
          final local = await _database.savedItemsDao.findById(
            remote.id,
            includeDeleted: true,
          );
          if (local == null) {
            await _database.savedItemsDao.insertItem(
              remoteSavedItemInsert(remote),
            );
          } else if (_remoteWins(local.syncStatus, local.updatedAt, remote)) {
            await _database.savedItemsDao.updateFields(
              remote.id,
              remoteSavedItemUpdate(remote, localEntities: local.entities),
            );
            await _removeEntityQueue(SyncEntityType.savedItem, remote.id);
          }
          if (maxCursor == null || remote.serverUpdatedAt.isAfter(maxCursor!)) {
            maxCursor = remote.serverUpdatedAt;
          }
        }
      });
      if (page.length < pullPageSize) break;
      offset += page.length;
    }
    await (_database.update(
      _database.cloudSyncStates,
    )..where((row) => row.id.equals('local'))).write(
      CloudSyncStatesCompanion(lastSavedItemsCursor: Value(maxCursor)),
    );
  }

  bool _remoteWins(
    SyncStatus localStatus,
    DateTime localUpdatedAt,
    RemoteSavedItem remote,
  ) =>
      localStatus == SyncStatus.synced ||
      localStatus == SyncStatus.localOnly ||
      !localUpdatedAt.toUtc().isAfter(remote.clientUpdatedAt);

  Future<void> _pullReminders(String userId) async {
    final state = await _ensureLocalState();
    var offset = 0;
    DateTime? maxCursor = state.lastRemindersCursor;
    while (true) {
      final page = await _remote!.fetchRemindersChangedSince(
        cursor: state.lastRemindersCursor,
        offset: offset,
        limit: pullPageSize,
      );
      await _database.transaction(() async {
        for (final remote in page) {
          if (remote.userId != userId) continue;
          final local = await _database.remindersDao.findById(remote.id);
          if (local == null) {
            await _database.remindersDao.insertReminder(
              remoteReminderInsert(remote),
            );
          } else {
            final remoteWins =
                local.syncStatus == SyncStatus.synced ||
                local.syncStatus == SyncStatus.localOnly ||
                !local.updatedAt.toUtc().isAfter(remote.clientUpdatedAt);
            if (remoteWins) {
              await _database.remindersDao.updateFields(
                remote.id,
                remoteReminderUpdate(remote),
              );
              await _removeEntityQueue(SyncEntityType.reminder, remote.id);
            }
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
  }

  Future<void> _removeQueueRows(List<SyncQueueRow> entries) async {
    for (final entry in entries) {
      await _database.syncQueueDao.remove(entry.id);
    }
  }

  Future<void> _removeEntityQueue(SyncEntityType type, String entityId) async {
    await (_database.delete(_database.syncQueue)..where(
          (row) =>
              row.entityType.equalsValue(type) & row.entityId.equals(entityId),
        ))
        .go();
  }

  Future<void> _registerQueueFailure(Object error) async {
    final message = error.runtimeType.toString();
    for (final entry in await _database.syncQueueDao.pending()) {
      await _database.syncQueueDao.updateFields(
        entry.id,
        SyncQueueCompanion(
          attempts: Value(entry.attempts + 1),
          lastAttemptAt: Value(_clock.now().toUtc()),
          lastError: Value(message),
        ),
      );
    }
  }

  Future<void> _recordFailure(Object error, {DateTime? attemptedAt}) async {
    final message = error.runtimeType.toString();
    final pending = await _database.syncQueueDao.pending();
    final state = await _ensureLocalState();
    await (_database.update(
      _database.cloudSyncStates,
    )..where((row) => row.id.equals('local'))).write(
      CloudSyncStatesCompanion(
        lastAttemptAt: Value(attemptedAt ?? _clock.now().toUtc()),
        lastError: Value(message),
      ),
    );
    _setStatus(
      SyncStatusSnapshot(
        phase: SyncPhase.offlineOrFailed,
        lastSuccessAt: state.lastSuccessfulSyncAt,
        lastAttemptAt: attemptedAt ?? _clock.now().toUtc(),
        pendingCount: pending.length,
        errorMessage: 'Your changes are safe on this device.',
      ),
    );
    _log('sync.failed', {'type': message});
  }

  void _setStatus(SyncStatusSnapshot value) {
    _status = value;
    if (!_statusController.isClosed) _statusController.add(value);
  }

  void _log(String event, Map<String, Object?> fields) {
    if (kDebugMode) debugPrint('$event $fields');
  }

  Future<void> dispose() async {
    await stopForAccountChange();
    await _statusController.close();
  }

  Future<void> stopForAccountChange() async {
    _localDebounce?.cancel();
    _realtimeDebounce?.cancel();
    await _authEvents?.cancel();
    await _realtimeEvents?.cancel();
    await _realtime?.dispose();
    _authEvents = null;
    _realtimeEvents = null;
    _realtime = null;
    _boundUserId = null;
    _initialized = false;
  }
}
