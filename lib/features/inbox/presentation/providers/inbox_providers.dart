import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/domain/models/item.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/providers/repository_providers.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/core/repositories/item_queries.dart';

final activeItemsProvider = StreamProvider<List<Item>>(
  (ref) => ref.watch(itemsRepositoryProvider).watchActive(),
);

final allItemsProvider = StreamProvider<List<Item>>(
  (ref) => ref.watch(itemsRepositoryProvider).watchAll(),
);
final archivedItemsProvider = StreamProvider<List<Item>>(
  (ref) => ref
      .watch(itemsRepositoryProvider)
      .watchAll()
      .map(
        (items) =>
            items.where((item) => item.status != ItemStatus.active).toList(),
      ),
);
final itemQueriesProvider = Provider(
  (ref) => ItemQueries(ref.watch(appDatabaseProvider)),
);
final itemSignalsProvider = StreamProvider<Map<String, ItemSignal>>((ref) {
  ref.watch(authStateProvider.select((s) => s.valueOrNull?.userId));
  return ref
      .watch(itemQueriesProvider)
      .watchSignals(ref.read(authRepositoryProvider).userId);
});
final searchIdsProvider = StreamProvider.family<Set<String>, String>((
  ref,
  query,
) {
  ref.watch(authStateProvider.select((s) => s.valueOrNull?.userId));
  return ref
      .watch(itemQueriesProvider)
      .search(query, ref.read(authRepositoryProvider).userId);
});
