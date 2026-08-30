import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/providers/repository_providers.dart';

final searchResultsProvider = FutureProvider.autoDispose
    .family<List<SavedItem>, String>((ref, query) async {
      if (query.trim().isEmpty) return const [];
      var cancelled = false;
      ref.onDispose(() => cancelled = true);
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (cancelled) return const [];
      return ref.watch(savedItemsRepositoryProvider).search(query);
    });
