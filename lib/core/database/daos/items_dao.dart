import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/database/tables/items.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';

part 'items_dao.g.dart';

@DriftAccessor(tables: [Items])
class ItemsDao extends DatabaseAccessor<AppDatabase> with _$ItemsDaoMixin {
  ItemsDao(super.db);

  Stream<List<ItemRow>> watchActive() =>
      (select(items)
            ..where(
              (row) =>
                  row.deletedAt.isNull() &
                  row.status.equalsValue(ItemStatus.active),
            )
            ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]))
          .watch();

  Future<ItemRow?> findById(String id, {bool includeDeleted = false}) {
    final query = select(items)..where((row) => row.id.equals(id));
    if (!includeDeleted) query.where((row) => row.deletedAt.isNull());
    return query.getSingleOrNull();
  }

  Future<List<ItemRow>> findByIds(Iterable<String> ids) {
    if (ids.isEmpty) return Future.value(const []);
    return (select(items)..where((row) => row.id.isIn(ids))).get();
  }

  Future<void> insertItem(ItemsCompanion item) =>
      into(items).insertOnConflictUpdate(item);

  Future<void> updateFields(String id, ItemsCompanion item) =>
      (update(items)..where((row) => row.id.equals(id))).write(item);
}
