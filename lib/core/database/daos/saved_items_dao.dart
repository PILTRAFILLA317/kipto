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

  Future<void> insertItem(SavedItemsCompanion item) =>
      into(savedItems).insert(item);

  Future<void> upsertItem(SavedItemsCompanion item) =>
      into(savedItems).insertOnConflictUpdate(item);

  Future<int> updateFields(String id, SavedItemsCompanion fields) =>
      (update(savedItems)..where((item) => item.id.equals(id))).write(fields);
}
