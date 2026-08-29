// ignore_for_file: prefer_initializing_formals

import 'package:clock/clock.dart';
import 'package:kipto/core/auth/auth_repository.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/dev/seed/development_seed.dart';
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
  bool isDemoId(String id) => DevelopmentSeed.knownItemIds.contains(id);

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

  void notifyAfterCommit() => _onLocalChange();
}
