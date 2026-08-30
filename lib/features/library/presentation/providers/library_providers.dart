import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/domain/models/library_query.dart';
import 'package:kipto/core/providers/repository_providers.dart';

final libraryQueryProvider = StateProvider<LibraryQuery>(
  (_) => const LibraryQuery(),
);

final libraryItemsProvider = StreamProvider<List<SavedItem>>((ref) {
  final query = ref.watch(libraryQueryProvider);
  return ref.watch(savedItemsRepositoryProvider).watchLibrary(query);
});

final libraryCountsProvider = StreamProvider<LibraryCounts>(
  (ref) => ref.watch(savedItemsRepositoryProvider).watchLibraryCounts(),
);
