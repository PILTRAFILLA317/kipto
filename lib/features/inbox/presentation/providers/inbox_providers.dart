import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/domain/models/item.dart';
import 'package:kipto/core/providers/repository_providers.dart';

final activeItemsProvider = StreamProvider<List<Item>>(
  (ref) => ref.watch(itemsRepositoryProvider).watchActive(),
);
