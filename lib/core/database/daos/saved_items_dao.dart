import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/database/tables/saved_items.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';

part 'saved_items_dao.g.dart';

@DriftAccessor(tables: [SavedItems])
class SavedItemsDao extends DatabaseAccessor<AppDatabase>
    with _$SavedItemsDaoMixin {
  SavedItemsDao(super.attachedDatabase);

  Expression<bool> _isActive() => savedItems.deletedAt.isNull();

  Stream<List<SavedItemRow>> watchActive() =>
      (select(savedItems)
            ..where((_) => _isActive())
            ..orderBy([(item) => OrderingTerm.desc(item.capturedAt)]))
          .watch();

  Stream<List<SavedItemRow>> watchInbox() =>
      (select(savedItems)..where(
            (item) =>
                _isActive() &
                item.status.isNotInValues(const [
                  SavedItemStatus.done,
                  SavedItemStatus.archived,
                ]),
          ))
          .watch();

  Stream<List<SavedItemRow>> watchByCategory(SavedItemCategory category) =>
      (select(savedItems)
            ..where((item) => _isActive() & item.category.equalsValue(category))
            ..orderBy([(item) => OrderingTerm.desc(item.capturedAt)]))
          .watch();

  Stream<SavedItemRow?> watchById(String id) =>
      (select(savedItems)
            ..where((item) => item.id.equals(id) & _isActive())
            ..limit(1))
          .watchSingleOrNull();

  Future<SavedItemRow?> findById(String id, {bool includeDeleted = false}) {
    return (select(savedItems)
          ..where(
            (item) =>
                item.id.equals(id) &
                (includeDeleted ? const Constant(true) : _isActive()),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<SavedItemRow>> getActive() =>
      (select(savedItems)..where((_) => _isActive())).get();

  Future<List<SavedItemRow>> getWithLocalAssets() => (select(
    savedItems,
  )..where((item) => item.localAssetId.isNotNull())).get();

  Future<List<String>> getExistingLocalAssetIds(Iterable<String> ids) async {
    final values = ids.toList(growable: false);
    if (values.isEmpty) return const [];
    final query = selectOnly(savedItems)
      ..addColumns([savedItems.localAssetId])
      ..where(savedItems.localAssetId.isIn(values));
    final rows = await query.get();
    return rows
        .map((row) => row.read(savedItems.localAssetId))
        .whereType<String>()
        .toList(growable: false);
  }

  Future<void> insertItem(SavedItemsCompanion item) =>
      into(savedItems).insert(item);

  Future<void> upsertItem(SavedItemsCompanion item) =>
      into(savedItems).insertOnConflictUpdate(item);

  Future<int> insertItemsIgnoringDuplicates(
    List<SavedItemsCompanion> items,
  ) async {
    if (items.isEmpty) return 0;
    var inserted = 0;
    await batch((batch) {
      for (final item in items) {
        batch.insert(savedItems, item, mode: InsertMode.insertOrIgnore);
      }
    });
    final ids = items
        .map((item) => item.localAssetId.value)
        .whereType<String>();
    inserted = (await getExistingLocalAssetIds(ids)).length;
    return inserted;
  }

  Future<int> updateOriginalAvailability(
    Iterable<String> localAssetIds,
    bool available,
  ) {
    final ids = localAssetIds.toList(growable: false);
    if (ids.isEmpty) return Future.value(0);
    return (update(savedItems)..where((item) => item.localAssetId.isIn(ids)))
        .write(SavedItemsCompanion(originalAvailable: Value(available)));
  }

  Future<int> updateFields(String id, SavedItemsCompanion fields) =>
      (update(savedItems)..where((item) => item.id.equals(id))).write(fields);
}
