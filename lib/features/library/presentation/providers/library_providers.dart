import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/providers/repository_providers.dart';

final allSavedItemsProvider = StreamProvider<List<SavedItem>>(
  (ref) => ref.watch(savedItemsRepositoryProvider).watchAll(),
);

final categoryItemsProvider =
    StreamProvider.family<List<SavedItem>, SavedItemCategory>(
      (ref, category) =>
          ref.watch(savedItemsRepositoryProvider).watchByCategory(category),
    );
