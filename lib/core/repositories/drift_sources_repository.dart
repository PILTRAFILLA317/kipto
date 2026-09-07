import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/domain/models/source.dart';
import 'package:kipto/core/files/original_store.dart';
import 'package:kipto/core/repositories/source_mapper.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';

class DriftSourcesRepository {
  DriftSourcesRepository(this.database, this.coordinator);
  final AppDatabase database;
  final LocalSyncCoordinator coordinator;
  Stream<List<Source>> watchForItem(String id) =>
      (database.select(database.sources)..where(
            (r) =>
                r.itemId.equals(id) & r.deletedAt.isNull() & _owner(r.ownerId),
          ))
          .watch()
          .map((rows) => rows.map(sourceFromRow).toList());
  Future<Source?> find(String id) async {
    final row = await (database.select(
      database.sources,
    )..where((r) => r.id.equals(id) & _owner(r.ownerId))).getSingleOrNull();
    return row == null ? null : sourceFromRow(row);
  }

  Expression<bool> _owner(GeneratedColumn<String> column) {
    final owner = coordinator.activeOwnerId;
    return owner == null ? column.isNull() : column.equals(owner);
  }

  Future<SourceFileRow?> localFile(String id) async {
    final source = await find(id);
    if (source == null || source.deletedAt != null) return null;
    final file = await (database.select(
      database.sourceFiles,
    )..where((r) => r.sourceId.equals(id))).getSingleOrNull();
    return source.ownerId == coordinator.activeOwnerId ? file : null;
  }

  Future<String> import(
    StoredOriginal original, {
    required String expectedScope,
    required String currentScope,
    String? title,
    int? pageCount,
  }) async {
    if (original.scope != expectedScope || currentScope != expectedScope) {
      throw const CaptureFailure('accountChanged');
    }
    final owner = coordinator.activeOwnerId;
    if (owner != null && owner != expectedScope ||
        owner == null && !expectedScope.startsWith('local:')) {
      throw const CaptureFailure('accountChanged');
    }
    final status = owner == null
        ? SyncStatus.localOnly
        : SyncStatus.pendingCreate;
    final now = original.createdAt;
    await database.transaction(() async {
      final existing = await find(original.captureId);
      if (existing != null) {
        if (existing.ownerId != owner) {
          throw const CaptureFailure('accountChanged');
        }
        if (existing.deletedAt != null) {
          throw const CaptureFailure('unavailable');
        }
        return;
      }
      await database
          .into(database.items)
          .insert(
            ItemsCompanion.insert(
              id: original.captureId,
              ownerId: Value(owner),
              title: title?.trim().isNotEmpty == true
                  ? title!.trim()
                  : original.name,
              summary: const Value(''),
              status: ItemStatus.active,
              createdAt: now,
              updatedAt: now,
              syncStatus: status,
            ),
          );
      await database
          .into(database.sources)
          .insert(
            SourcesCompanion.insert(
              id: original.captureId,
              itemId: original.captureId,
              ownerId: Value(owner),
              kind: original.mime == 'text/plain'
                  ? (Uri.tryParse(original.text ?? '')?.hasScheme == true &&
                            ['https', 'http'].contains(
                              Uri.tryParse(original.text ?? '')?.scheme,
                            )
                        ? 'url'
                        : 'text')
                  : original.mime == 'application/pdf'
                  ? 'pdf'
                  : 'image',
              origin: original.origin,
              originalName: original.name,
              mimeType: original.mime,
              byteSize: original.size,
              contentHash: original.hash,
              textContent: Value(original.text),
              pageCount: Value(pageCount),
              createdAt: now,
              updatedAt: now,
              syncStatus: status,
            ),
          );
      await database
          .into(database.sourceFiles)
          .insert(
            SourceFilesCompanion.insert(
              sourceId: original.captureId,
              originalRelativePath: Value(original.relativePath),
            ),
          );
      if (owner != null) {
        await coordinator.enqueue(
          entityType: SyncEntityType.item,
          entityId: original.captureId,
          operation: SyncOperation.create,
        );
        await coordinator.enqueue(
          entityType: SyncEntityType.source,
          entityId: original.captureId,
          operation: SyncOperation.create,
        );
      }
      if (coordinator.activeOwnerId != owner) {
        throw const CaptureFailure('accountChanged');
      }
    });
    coordinator.notifyAfterCommit();
    return original.captureId;
  }
}
