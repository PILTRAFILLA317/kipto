import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/domain/models/reminder.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/providers/repository_providers.dart';

final savedItemProvider = StreamProvider.family<SavedItem?, String>(
  (ref, id) => ref.watch(savedItemsRepositoryProvider).watchById(id),
);

final itemRemindersProvider = StreamProvider.family<List<Reminder>, String>(
  (ref, id) => ref.watch(remindersRepositoryProvider).watchForSavedItem(id),
);
