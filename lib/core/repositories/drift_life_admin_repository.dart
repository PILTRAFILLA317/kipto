import 'package:clock/clock.dart';

import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/domain/models/fact.dart';
import 'package:kipto/core/domain/models/fact_value.dart';
import 'package:kipto/core/domain/models/item_action.dart';
import 'package:kipto/core/repositories/life_admin_mapper.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/features/analysis/domain/analysis_contract.dart';
import 'package:kipto/features/analysis/domain/analysis_failure.dart';

/// Facts and actions share ownership and revision invariants. Platform effects
/// run after these transactions; viewing or analyzing never schedules an alarm.
class DriftLifeAdminRepository {
  DriftLifeAdminRepository(
    this.database,
    this.coordinator, {
    this.clock = const Clock(),
  });
  final AppDatabase database;
  final LocalSyncCoordinator coordinator;
  final Clock clock;
  SyncStatus get _pending => coordinator.activeOwnerId == null
      ? SyncStatus.localOnly
      : SyncStatus.pendingUpdate;
  DateTime _next(DateTime previous) {
    final now = clock.now().toUtc();
    return now.isAfter(previous)
        ? now
        : previous.add(const Duration(microseconds: 1));
  }

  Stream<List<Fact>> watchFacts(String itemId) =>
      (database.select(database.facts)
            ..where((r) => r.itemId.equals(itemId) & r.deletedAt.isNull()))
          .watch()
          .map(
            (rows) => rows
                .where((r) => r.ownerId == coordinator.activeOwnerId)
                .map(factFromRow)
                .toList(),
          );
  Stream<List<ItemAction>> watchActions(String itemId) =>
      (database.select(database.itemActions)
            ..where((r) => r.itemId.equals(itemId) & r.deletedAt.isNull()))
          .watch()
          .map(
            (rows) => rows
                .where((r) => r.ownerId == coordinator.activeOwnerId)
                .map(actionFromRow)
                .toList(),
          );
  Future<Fact?> findFact(String id) async {
    final row = await (database.select(
      database.facts,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
    return row == null || row.ownerId != coordinator.activeOwnerId
        ? null
        : factFromRow(row);
  }

  Future<ItemAction?> findAction(String id) async {
    final row = await (database.select(
      database.itemActions,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
    return row == null || row.ownerId != coordinator.activeOwnerId
        ? null
        : actionFromRow(row);
  }

  Future<void> _owner(String itemId, String? owner) async {
    final item = await database.itemsDao.findById(itemId);
    if (owner != coordinator.activeOwnerId ||
        item == null ||
        item.ownerId != owner) {
      throw StateError('The matter is unavailable in this account');
    }
  }

  /// The job and its domain output commit together. IDs are derived from the
  /// request, so replay cannot create a second set of facts or suggestions.
  Future<void> applyAnalysis(
    AnalysisJobRow job,
    AnalysisOutput output,
    Map<String, dynamic> envelope, {
    required bool Function() isCurrent,
  }) async {
    await database.transaction(() async {
      final currentJob = await (database.select(
        database.analysisJobs,
      )..where((j) => j.sourceId.equals(job.sourceId))).getSingleOrNull();
      final source = await (database.select(
        database.sources,
      )..where((s) => s.id.equals(job.sourceId))).getSingleOrNull();
      if (!isCurrent() ||
          currentJob?.requestId != job.requestId ||
          source == null ||
          source.ownerId != job.ownerId ||
          source.revision != job.revision ||
          source.deletedAt != null ||
          output.sourceRevision != job.revision) {
        throw const AnalysisFailure('stale');
      }
      await _owner(source.itemId, job.ownerId);
      if (currentJob!.state == 'done') return;
      final now = clock.now().toUtc();
      final oldActions =
          await (database.select(database.itemActions)..where(
                (a) => a.sourceId.equals(source.id) & a.deletedAt.isNull(),
              ))
              .get();
      final protectedFacts = <String>{};
      for (final row in oldActions) {
        if (row.state != 'proposed' || row.origin != 'analysis') {
          protectedFacts.addAll(
            (jsonDecode(row.evidenceFactIds) as List).cast<String>(),
          );
          continue;
        }
        await (database.update(
          database.itemActions,
        )..where((a) => a.id.equals(row.id))).write(
          ItemActionsCompanion(
            deletedAt: Value(now),
            updatedAt: Value(_next(row.updatedAt)),
            syncStatus: Value(_pending),
          ),
        );
        await _enqueue(SyncEntityType.action, row.id, SyncOperation.delete);
      }
      final oldFacts =
          await (database.select(database.facts)..where(
                (f) => f.sourceId.equals(source.id) & f.deletedAt.isNull(),
              ))
              .get();
      for (final row in oldFacts) {
        if (row.userValue != null ||
            row.provenance != 'extracted' ||
            protectedFacts.contains(row.id)) {
          continue;
        }
        await (database.update(
          database.facts,
        )..where((f) => f.id.equals(row.id))).write(
          FactsCompanion(
            deletedAt: Value(now),
            updatedAt: Value(_next(row.updatedAt)),
            syncStatus: Value(_pending),
          ),
        );
        await _enqueue(SyncEntityType.fact, row.id, SyncOperation.delete);
      }
      final ids = {
        for (final fact in output.facts)
          fact.key: const Uuid().v5(job.requestId, 'fact:${fact.key}'),
      };
      for (final fact in output.facts) {
        final entity = Fact(
          id: ids[fact.key]!,
          itemId: source.itemId,
          ownerId: job.ownerId,
          sourceId: source.id,
          sourceRevision: job.revision,
          key: fact.type,
          value: fact.value,
          provenance: FactProvenance.extracted,
          evidence: fact.evidence,
          createdAt: now,
          updatedAt: now,
        );
        await database
            .into(database.facts)
            .insert(factCompanion(entity, _pending));
        await _enqueue(SyncEntityType.fact, entity.id, SyncOperation.create);
      }
      for (final suggestion in output.suggestions) {
        final proposedEvidence = output.facts
            .where((f) => suggestion.relatedFactKeys.contains(f.key))
            .map((f) => jsonEncode([f.type, f.value.toJson()]))
            .toSet();
        final alreadyAccepted = oldActions.any((a) {
          if (a.state != 'accepted' ||
              a.analysisRevision != job.revision ||
              a.kind != suggestion.kind.name) {
            return false;
          }
          final references = (jsonDecode(a.evidenceFactIds) as List)
              .cast<String>();
          final evidence = oldFacts
              .where((f) => references.contains(f.id))
              .map((f) => jsonEncode([f.key, factFromRow(f).value.toJson()]))
              .toSet();
          return a.title == suggestion.title ||
              (evidence.isNotEmpty &&
                  evidence.length == proposedEvidence.length &&
                  evidence.containsAll(proposedEvidence));
        });
        if (alreadyAccepted) continue;
        final action = ItemAction(
          id: const Uuid().v5(job.requestId, 'action:${suggestion.key}'),
          itemId: source.itemId,
          ownerId: job.ownerId,
          sourceId: source.id,
          analysisRevision: job.revision,
          title: suggestion.title,
          payload: switch (suggestion.kind) {
            ActionKind.keep => const KeepPayload(),
            ActionKind.remind => RemindPayload(),
            ActionKind.event => EventPayload(allDay: false),
          },
          origin: ActionOrigin.analysis,
          evidenceFactIds: suggestion.relatedFactKeys
              .map((k) => ids[k]!)
              .toList(),
          createdAt: now,
          updatedAt: now,
        );
        await database
            .into(database.itemActions)
            .insert(actionCompanion(action, _pending));
        await _enqueue(SyncEntityType.action, action.id, SyncOperation.create);
      }
      // Extracted title/summary stay in the review envelope. The user's title
      // and summary are never silently replaced, including across devices.
      await (database.update(
        database.analysisJobs,
      )..where((j) => j.sourceId.equals(job.sourceId))).write(
        AnalysisJobsCompanion(
          state: const Value('done'),
          envelope: Value(jsonEncode(envelope)),
          payload: const Value(null),
          errorCode: const Value(null),
          nextAttemptAt: const Value(null),
        ),
      );
      if (!isCurrent()) throw const AnalysisFailure('stale');
    });
    coordinator.notifyAfterCommit();
  }

  Future<void> _enqueue(
    SyncEntityType type,
    String id,
    SyncOperation operation,
  ) async {
    if (coordinator.activeOwnerId != null) {
      await coordinator.enqueue(
        entityType: type,
        entityId: id,
        operation: operation,
      );
    }
  }

  Future<void> insertFact(Fact fact) async {
    await database.transaction(() async {
      await _owner(fact.itemId, fact.ownerId);
      await database.into(database.facts).insert(factCompanion(fact, _pending));
      await _enqueue(SyncEntityType.fact, fact.id, SyncOperation.create);
    });
    coordinator.notifyAfterCommit();
  }

  Future<void> propose(ItemAction action) async {
    if (action.state != ActionState.proposed) {
      throw StateError('Use acceptance to execute an action');
    }
    await database.transaction(() async {
      await _owner(action.itemId, action.ownerId);
      await database
          .into(database.itemActions)
          .insert(actionCompanion(action, _pending));
      await _enqueue(SyncEntityType.action, action.id, SyncOperation.create);
    });
    coordinator.notifyAfterCommit();
  }

  Future<void> correctFact(String id, FactValue value) async {
    await database.transaction(() async {
      final fact = await findFact(id);
      if (fact == null || fact.deletedAt != null) {
        throw StateError('Missing fact');
      }
      await _owner(fact.itemId, fact.ownerId);
      final updated = Fact.fromJson({
        ...fact.toJson(),
        'user_value': value.toJson(),
        'client_updated_at': _next(fact.updatedAt).toIso8601String(),
      });
      if (value.type != fact.value.type) {
        throw const FormatException('Correction changes value type');
      }
      await database
          .into(database.facts)
          .insertOnConflictUpdate(factCompanion(updated, _pending));
      await _enqueue(SyncEntityType.fact, id, SyncOperation.update);
    });
    coordinator.notifyAfterCommit();
  }

  Future<void> dismiss(String id) async {
    await database.transaction(() async {
      final action = await findAction(id);
      if (action == null || action.deletedAt != null) {
        throw StateError('Missing action');
      }
      await _owner(action.itemId, action.ownerId);
      if (action.state == ActionState.accepted) {
        throw StateError('Accepted actions require explicit cancellation');
      }
      final updated = ItemAction.fromJson({
        ...action.toJson(),
        'state': 'dismissed',
        'client_updated_at': _next(action.updatedAt).toIso8601String(),
      });
      await database
          .into(database.itemActions)
          .insertOnConflictUpdate(actionCompanion(updated, _pending));
      await _enqueue(SyncEntityType.action, id, SyncOperation.update);
    });
    coordinator.notifyAfterCommit();
  }

  /// Idempotent acceptance. Reminder id is the action UUID, making a repeated
  /// confirmation or a restored acceptance converge to one reminder.
  Future<String?> accept(String id, ActionPayload confirmed) async {
    String? reminderId;
    await database.transaction(() async {
      final action = await findAction(id);
      if (action == null || action.deletedAt != null) {
        throw StateError('Missing action');
      }
      await _owner(action.itemId, action.ownerId);
      if (action.state == ActionState.accepted) {
        reminderId = action.payload.kind == ActionKind.remind ? id : null;
        return;
      }
      final item = await database.itemsDao.findById(action.itemId);
      if (item?.status != ItemStatus.active) {
        throw StateError('Reopen the matter before accepting actions');
      }
      if (action.state != ActionState.proposed ||
          !confirmed.ready ||
          confirmed.kind != action.payload.kind) {
        throw StateError('Confirm all fields of a proposed action');
      }
      final now = _next(action.updatedAt);
      if (confirmed is RemindPayload &&
          !confirmed.instant!.isAfter(clock.now().toUtc())) {
        throw StateError('Choose a future reminder instant');
      }
      final updated = ItemAction.fromJson({
        ...action.toJson(),
        'payload': confirmed.toJson(),
        'state': 'accepted',
        'execution_state': confirmed.kind == ActionKind.keep
            ? 'applied'
            : 'pending',
        'accepted_at': now.toIso8601String(),
        'client_updated_at': now.toIso8601String(),
      });
      await database
          .into(database.itemActions)
          .insertOnConflictUpdate(actionCompanion(updated, _pending));
      await _enqueue(SyncEntityType.action, id, SyncOperation.update);
      if (confirmed is RemindPayload) {
        reminderId = id;
        await database
            .into(database.reminders)
            .insert(
              RemindersCompanion.insert(
                id: id,
                itemId: action.itemId,
                ownerId: Value(action.ownerId),
                actionId: Value(id),
                title: Value(action.title),
                timeZone: Value(confirmed.zone),
                remindAt: confirmed.instant!,
                createdAt: now,
                updatedAt: now,
                syncStatus: _pending,
              ),
            );
        await _enqueue(SyncEntityType.reminder, id, SyncOperation.create);
      }
      if (confirmed is KeepPayload) {
        final pending =
            await (database.select(database.reminders)..where(
                  (r) =>
                      r.itemId.equals(action.itemId) &
                      r.deletedAt.isNull() &
                      r.completedAt.isNull() &
                      r.remindAt.isBiggerThanValue(clock.now().toUtc()),
                ))
                .get();
        if (pending.isEmpty) {
          final proposals =
              await (database.select(database.itemActions)..where(
                    (a) =>
                        a.itemId.equals(action.itemId) &
                        a.state.equals('proposed') &
                        a.deletedAt.isNull(),
                  ))
                  .get();
          for (final proposal in proposals) {
            await (database.update(
              database.itemActions,
            )..where((a) => a.id.equals(proposal.id))).write(
              ItemActionsCompanion(
                state: const Value('dismissed'),
                updatedAt: Value(_next(proposal.updatedAt)),
                syncStatus: Value(_pending),
              ),
            );
            await _enqueue(
              SyncEntityType.action,
              proposal.id,
              SyncOperation.update,
            );
          }
          await database.itemsDao.updateFields(
            action.itemId,
            ItemsCompanion(
              status: const Value(ItemStatus.archived),
              updatedAt: Value(_next(item!.updatedAt)),
              syncStatus: Value(_pending),
            ),
          );
          await _enqueue(
            SyncEntityType.item,
            action.itemId,
            SyncOperation.update,
          );
        }
      }
    });
    coordinator.notifyAfterCommit();
    return reminderId;
  }

  Future<void> recordExecution(
    String id,
    ActionExecutionState state, {
    bool cancelled = false,
  }) async {
    await database.transaction(() async {
      final action = await findAction(id);
      if (action == null ||
          action.deletedAt != null ||
          action.state != ActionState.accepted) {
        throw StateError('Missing acceptance');
      }
      await _owner(action.itemId, action.ownerId);
      final updated = ItemAction.fromJson({
        ...action.toJson(),
        'state': cancelled ? 'proposed' : 'accepted',
        'execution_state': cancelled ? 'notRequested' : state.name,
        'accepted_at': cancelled ? null : action.acceptedAt!.toIso8601String(),
        'client_updated_at': _next(action.updatedAt).toIso8601String(),
      });
      await database
          .into(database.itemActions)
          .insertOnConflictUpdate(actionCompanion(updated, _pending));
      await _enqueue(SyncEntityType.action, id, SyncOperation.update);
    });
    coordinator.notifyAfterCommit();
  }

  Future<void> renameProposal(String id, String title) async {
    final normalized = boundedText(title, 100);
    await database.transaction(() async {
      final action = await findAction(id);
      if (action == null ||
          action.deletedAt != null ||
          action.state != ActionState.proposed) {
        throw StateError('Missing proposal');
      }
      await _owner(action.itemId, action.ownerId);
      await (database.update(
        database.itemActions,
      )..where((a) => a.id.equals(id))).write(
        ItemActionsCompanion(
          title: Value(normalized),
          updatedAt: Value(_next(action.updatedAt)),
          syncStatus: Value(_pending),
        ),
      );
      await _enqueue(SyncEntityType.action, id, SyncOperation.update);
    });
    coordinator.notifyAfterCommit();
  }
}
