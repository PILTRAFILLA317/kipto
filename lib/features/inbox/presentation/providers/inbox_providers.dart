import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/providers/repository_providers.dart';

final inboxItemsProvider = StreamProvider<List<SavedItem>>(
  (ref) => ref.watch(savedItemsRepositoryProvider).watchInbox(),
);
