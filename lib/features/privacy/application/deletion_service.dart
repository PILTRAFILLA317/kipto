import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/files/original_store.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';

class DeletionService {
  DeletionService({
    required this.database,
    required this.coordinator,
    required this.originals,
    required this.reconcile,
    required this.wakeFiles,
  });
  final AppDatabase database;
  final LocalSyncCoordinator coordinator;
  final Future<OriginalStore> Function() originals;
  final Future<void> Function() reconcile, wakeFiles;
  Future<void> deleteMatter(String id) => _delete(id, null);
  Future<void> deleteSource(String itemId, String sourceId) =>
      _delete(itemId, sourceId);
  Future<void> _delete(String itemId, String? sourceId) async {
    final owner = coordinator.activeOwnerId;
    const scrubs = {
      'items': "title='Deleted',summary='',",
      'sources': "original_name='Deleted',text_content=NULL,",
      'facts': "key='deleted',value_type='text',value='{\"text\":\"Deleted\"}',user_value=NULL,evidence='{\"page\":null,\"quote\":null,\"verification\":\"unverified\"}',",
      'item_actions': "title='Deleted',state='dismissed',execution_state='notRequested',accepted_at=NULL,evidence_fact_ids='[]',payload=CASE kind WHEN 'keep' THEN '{}' WHEN 'remind' THEN '{\"instant\":null,\"zone\":null}' ELSE '{\"allDay\":false,\"start\":null,\"end\":null,\"startDate\":null,\"endDateExclusive\":null,\"zone\":null,\"location\":null}' END,",
      'reminders':
          "title=NULL,time_zone='UTC',remind_at='1970-01-01T00:00:00.000Z',",
    };
    await database.transaction(() async {
      final item = await database.itemsDao.findById(
        itemId,
        includeDeleted: true,
      );
      if (item == null || item.ownerId != owner) {
        throw StateError('Matter unavailable');
      }
      final selected =
          await (database.select(database.sources)..where(
                (s) =>
                    s.itemId.equals(itemId) &
                    (sourceId == null
                        ? const Constant(true)
                        : s.id.equals(sourceId)),
              ))
              .get();
      if (sourceId != null && selected.isEmpty) {
        throw StateError('Source unavailable');
      }
      final entities = [
        if (sourceId == null) ('items', 'id', SyncEntityType.item),
        ('sources', sourceId == null ? 'item_id' : 'id', SyncEntityType.source),
        (
          'facts',
          sourceId == null ? 'item_id' : 'source_id',
          SyncEntityType.fact,
        ),
        (
          'reminders',
          sourceId == null
              ? 'item_id'
              : 'action_id IN (SELECT id FROM item_actions WHERE source_id',
          SyncEntityType.reminder,
        ),
        (
          'item_actions',
          sourceId == null ? 'item_id' : 'source_id',
          SyncEntityType.action,
        ),
      ];
      for (final (table, column, type) in entities) {
        final rows = await database
            .customSelect(
              'SELECT id,updated_at FROM $table WHERE $column=?${column.contains('SELECT') ? ')' : ''} AND owner_id IS ?',
              variables: [
                Variable(sourceId ?? itemId),
                Variable<String>(owner),
              ],
            )
            .get();
        for (final row in rows) {
          final now = DateTime.now().toUtc();
          final previous = DateTime.parse(row.read<String>('updated_at'));
          final timestamp =
              (now.isAfter(previous)
                      ? now
                      : previous.add(const Duration(microseconds: 1)))
                  .toIso8601String();
          await database.customStatement(
            'UPDATE $table SET ${scrubs[table]}deleted_at=?,updated_at=?,sync_status=? WHERE id=?',
            [
              timestamp,
              timestamp,
              owner == null ? 'localOnly' : 'pendingUpdate',
              row.read<String>('id'),
            ],
          );
          if (owner != null) {
            await coordinator.enqueue(
              entityType: type,
              entityId: row.read<String>('id'),
              operation: SyncOperation.delete,
            );
          }
        }
      }
      for (final source in selected) {
        // Clear provider input/results as soon as the deletion is committed.
        await (database.delete(
          database.analysisJobs,
        )..where((j) => j.sourceId.equals(source.id))).go();
        await database
            .into(database.fileJobs)
            .insertOnConflictUpdate(
              FileJobsCompanion.insert(
                sourceId: source.id,
                ownerId: owner ?? 'local',
                revision: source.revision,
                operation: 'delete',
                state: const Value('queued'),
                attempts: const Value(0),
                errorCode: const Value(null),
                nextAttemptAt: const Value(null),
              ),
            );
      }
      if (coordinator.activeOwnerId != owner) {
        throw StateError('Account changed');
      }
    });
    // The tombstone is durable even when the platform or network fails.
    database.markTablesUpdated({
      database.items,
      database.sources,
      database.facts,
      database.itemActions,
      database.reminders,
    });
    coordinator.notifyAfterCommit();
    await reconcile();
    await wakeFiles();
  }
}
