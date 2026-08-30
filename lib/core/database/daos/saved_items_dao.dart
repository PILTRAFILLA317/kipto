import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/database/tables/saved_items.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/library_query.dart';

part 'saved_items_dao.g.dart';

final class SavedItemCountRow {
  const SavedItemCountRow({
    required this.category,
    required this.count,
    required this.unprocessed,
  });

  final SavedItemCategory category;
  final int count;
  final int unprocessed;
}

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

  Stream<List<SavedItemRow>> watchInboxCandidates(
    DateTime now, {
    int limit = 250,
  }) {
    final utcNow = now.toUtc();
    final expiryEnd = utcNow.add(const Duration(days: 7));
    final comingUpEnd = utcNow.add(const Duration(days: 14));
    return (select(savedItems)
          ..where(
            (item) =>
                _isActive() &
                item.status.isNotInValues(const [
                  SavedItemStatus.done,
                  SavedItemStatus.archived,
                ]),
          )
          ..orderBy([
            (item) => OrderingTerm.asc(
              CaseWhenExpression<int>(
                cases: [
                  CaseWhen(
                    item.status.equalsValue(SavedItemStatus.needsAction) |
                        item.expiresAt.isSmallerThanValue(utcNow),
                    then: const Constant(0),
                  ),
                  CaseWhen(
                    item.expiresAt.isBetweenValues(utcNow, expiryEnd),
                    then: const Constant(1),
                  ),
                  CaseWhen(
                    item.eventAt.isBetweenValues(utcNow, comingUpEnd) |
                        item.status.equalsValue(SavedItemStatus.snoozed),
                    then: const Constant(2),
                  ),
                  CaseWhen(
                    item.analysisStatus.equalsValue(AnalysisStatus.unprocessed),
                    then: const Constant(3),
                  ),
                ],
                orElse: const Constant(4),
              ),
            ),
            (item) => OrderingTerm(
              expression: item.expiresAt,
              mode: OrderingMode.asc,
              nulls: NullsOrder.last,
            ),
            (item) => OrderingTerm.desc(item.capturedAt),
          ])
          ..limit(limit))
        .watch();
  }

  Future<int> countInboxAttention(DateTime now) async {
    final expiryEnd = now.toUtc().add(const Duration(days: 7));
    final count = savedItems.id.count();
    final query = selectOnly(savedItems)
      ..addColumns([count])
      ..where(
        _isActive() &
            savedItems.status.isNotInValues(const [
              SavedItemStatus.done,
              SavedItemStatus.archived,
            ]) &
            (savedItems.status.equalsValue(SavedItemStatus.needsAction) |
                savedItems.expiresAt.isSmallerOrEqualValue(expiryEnd)),
      );
    return (await query.getSingle()).read(count) ?? 0;
  }

  Stream<List<SavedItemRow>> watchByCategory(SavedItemCategory category) =>
      (select(savedItems)
            ..where((item) => _isActive() & item.category.equalsValue(category))
            ..orderBy([(item) => OrderingTerm.desc(item.capturedAt)]))
          .watch();

  Stream<List<SavedItemRow>> watchLibrary(LibraryQuery query) {
    final statement = select(savedItems)
      ..where((item) {
        var predicate = _isActive();
        final filter = query.filter;
        if (filter.category != null) {
          predicate = predicate & item.category.equalsValue(filter.category!);
        }
        if (filter.status != null) {
          predicate = predicate & item.status.equalsValue(filter.status!);
        }
        if (filter.analysisStatus != null) {
          predicate =
              predicate &
              item.analysisStatus.equalsValue(filter.analysisStatus!);
        }
        if (filter.favoriteOnly) {
          predicate = predicate & item.favorite.equals(true);
        }
        return predicate;
      });
    statement.orderBy([
      switch (query.sort) {
        LibrarySort.newest => (item) => OrderingTerm.desc(item.capturedAt),
        LibrarySort.oldest => (item) => OrderingTerm.asc(item.capturedAt),
        LibrarySort.expiringSoon => (item) => OrderingTerm(
          expression: item.expiresAt,
          mode: OrderingMode.asc,
          nulls: NullsOrder.last,
        ),
        LibrarySort.recentlyUpdated => (item) => OrderingTerm.desc(
          item.updatedAt,
        ),
      },
    ]);
    return statement.watch();
  }

  Stream<List<SavedItemCountRow>> watchCounts() =>
      customSelect(
        '''
    SELECT category, COUNT(*) AS item_count,
      SUM(CASE WHEN analysis_status = 'unprocessed' THEN 1 ELSE 0 END)
        AS unprocessed_count
    FROM saved_items
    WHERE deleted_at IS NULL
    GROUP BY category
    ''',
        readsFrom: {savedItems},
      ).watch().map(
        (rows) => rows
            .map(
              (row) => SavedItemCountRow(
                category: SavedItemCategoryStorage.fromStorage(
                  row.read<String>('category'),
                ),
                count: row.read<int>('item_count'),
                unprocessed: row.read<int>('unprocessed_count'),
              ),
            )
            .toList(growable: false),
      );

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

  Future<List<SavedItemRow>> getByCategories(
    Iterable<SavedItemCategory> categories,
  ) {
    final values = categories.toList(growable: false);
    if (values.isEmpty) return Future.value(const []);
    return (select(savedItems)
          ..where((item) => _isActive() & item.category.isInValues(values))
          ..orderBy([(item) => OrderingTerm.desc(item.capturedAt)]))
        .get();
  }

  Future<List<SavedItemRow>> searchActive(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return const [];
    final escaped = normalized
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    final pattern = '%$escaped%';
    final matches = await customSelect(
      '''
      SELECT id FROM saved_items
      WHERE deleted_at IS NULL AND (
        LOWER(title) LIKE ? ESCAPE '\\' OR
        LOWER(summary) LIKE ? ESCAPE '\\' OR
        LOWER(COALESCE(subtype, '')) LIKE ? ESCAPE '\\' OR
        LOWER(COALESCE(intent, '')) LIKE ? ESCAPE '\\' OR
        LOWER(category) LIKE ? ESCAPE '\\' OR
        LOWER(COALESCE(location, '')) LIKE ? ESCAPE '\\' OR
        LOWER(entities) LIKE ? ESCAPE '\\'
      )
      ORDER BY captured_at DESC
      ''',
      variables: List.generate(7, (_) => Variable.withString(pattern)),
      readsFrom: {savedItems},
    ).get();
    final ids = matches.map((row) => row.read<String>('id')).toList();
    if (ids.isEmpty) return const [];
    return (select(savedItems)
          ..where((item) => item.id.isIn(ids))
          ..orderBy([(item) => OrderingTerm.desc(item.capturedAt)]))
        .get();
  }

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

  Future<Map<String, String>> getSavedItemIdsByLocalAssetIds(
    Iterable<String> ids,
  ) async {
    final values = ids.toList(growable: false);
    if (values.isEmpty) return const {};
    final query = selectOnly(savedItems)
      ..addColumns([savedItems.id, savedItems.localAssetId])
      ..where(savedItems.localAssetId.isIn(values));
    final rows = await query.get();
    return {
      for (final row in rows)
        if (row.read(savedItems.localAssetId) case final String assetId)
          assetId: row.read(savedItems.id)!,
    };
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
