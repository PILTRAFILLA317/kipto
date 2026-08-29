import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';

abstract interface class SavedItemsRepository {
  Stream<List<SavedItem>> watchInbox();
  Stream<List<SavedItem>> watchAll();
  Stream<List<SavedItem>> watchByCategory(SavedItemCategory category);
  Stream<SavedItem?> watchById(String id);
  Future<List<SavedItem>> search(String query);
  Future<void> create(SavedItem item);
  Future<void> update(SavedItem item);
  Future<void> changeStatus(String id, SavedItemStatus status);
  Future<void> archive(String id);
  Future<void> markDone(String id);
  Future<void> toggleFavorite(String id);
  Future<void> snooze(String id, DateTime until);
  Future<void> restore(String id);
  Future<void> softDelete(String id);
}
