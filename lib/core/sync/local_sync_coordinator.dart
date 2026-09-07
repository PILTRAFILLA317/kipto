import 'package:drift/drift.dart';
// ignore_for_file: prefer_initializing_formals

import 'package:clock/clock.dart';
import 'package:kipto/core/auth/auth_repository.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:uuid/uuid.dart';

final class LocalSyncCoordinator {
  LocalSyncCoordinator({
    required AppDatabase database,
    required AuthRepository auth,
    required void Function() onLocalChange,
    Clock? clock,
    Uuid? uuid,
  }) : _database = database,
       _auth = auth,
       _onLocalChange = onLocalChange,
       _clock = clock ?? const Clock(),
       _uuid = uuid ?? const Uuid();

  final AppDatabase _database;
  final AuthRepository _auth;
  final void Function() _onLocalChange;
  final Clock _clock;
  final Uuid _uuid;

  String? get activeOwnerId => _auth.userId;
  bool canSyncOwner(String? ownerId) =>
      ownerId != null && ownerId == _auth.userId;

  Future<void> enqueue({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperation operation,
  }) => _database.syncQueueDao.enqueue(
    SyncQueueCompanion.insert(
      id: _uuid.v4(),
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      createdAt: _clock.now().toUtc(),
    ),
  );

  Future<void> claimLocalOnlyData(String userId) async {
    await _database.transaction(() async {
      if (activeOwnerId != userId) throw StateError("Account changed");
      final localItems = await (_database.select(
        _database.items,
      )..where((row) => row.ownerId.isNull() & row.deletedAt.isNull())).get();
      for (final item in localItems) {
        await _database.itemsDao.updateFields(
          item.id,
          ItemsCompanion(
            ownerId: Value(userId),
            syncStatus: const Value(SyncStatus.pendingCreate),
          ),
        );
        await enqueue(
          entityType: SyncEntityType.item,
          entityId: item.id,
          operation: SyncOperation.create,
        );
      }
      final localSources = await (_database.select(
        _database.sources,
      )..where((r) => r.ownerId.isNull() & r.deletedAt.isNull())).get();
      for (final source in localSources) {
        await (_database.update(
          _database.sources,
        )..where((r) => r.id.equals(source.id))).write(
          SourcesCompanion(
            ownerId: Value(userId),
            syncStatus: const Value(SyncStatus.pendingCreate),
          ),
        );
        await enqueue(
          entityType: SyncEntityType.source,
          entityId: source.id,
          operation: SyncOperation.create,
        );
      }
      final localFacts = await (_database.select(
        _database.facts,
      )..where((r) => r.ownerId.isNull() & r.deletedAt.isNull())).get();
      for (final row in localFacts) {
        await (_database.update(
          _database.facts,
        )..where((r) => r.id.equals(row.id))).write(
          FactsCompanion(
            ownerId: Value(userId),
            syncStatus: const Value(SyncStatus.pendingCreate),
          ),
        );
        await enqueue(
          entityType: SyncEntityType.fact,
          entityId: row.id,
          operation: SyncOperation.create,
        );
      }
      final localActions = await (_database.select(
        _database.itemActions,
      )..where((r) => r.ownerId.isNull() & r.deletedAt.isNull())).get();
      for (final row in localActions) {
        await (_database.update(
          _database.itemActions,
        )..where((r) => r.id.equals(row.id))).write(
          ItemActionsCompanion(
            ownerId: Value(userId),
            syncStatus: const Value(SyncStatus.pendingCreate),
          ),
        );
        await enqueue(
          entityType: SyncEntityType.action,
          entityId: row.id,
          operation: SyncOperation.create,
        );
      }
      final localReminders = await (_database.select(
        _database.reminders,
      )..where((row) => row.ownerId.isNull() & row.deletedAt.isNull())).get();
      for (final reminder in localReminders) {
        await _database.remindersDao.updateFields(
          reminder.id,
          RemindersCompanion(
            ownerId: Value(userId),
            syncStatus: const Value(SyncStatus.pendingCreate),
          ),
        );
        await enqueue(
          entityType: SyncEntityType.reminder,
          entityId: reminder.id,
          operation: SyncOperation.create,
        );
      }
      if (activeOwnerId != userId) throw StateError("Account changed");
    });
  }

  void notifyAfterCommit() => _onLocalChange();
}
