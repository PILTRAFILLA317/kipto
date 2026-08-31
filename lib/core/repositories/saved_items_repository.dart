import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/domain/models/inbox_overview.dart';
import 'package:kipto/core/domain/models/library_query.dart';

abstract interface class SavedItemsRepository {
  Stream<InboxOverview> watchInboxOverview(DateTime now);
  Stream<List<SavedItem>> watchAll();
  Stream<List<SavedItem>> watchLibrary(LibraryQuery query);
  Stream<LibraryCounts> watchLibraryCounts();
  Stream<List<SavedItem>> watchByCategory(SavedItemCategory category);
  Stream<SavedItem?> watchById(String id);
  Future<List<SavedItem>> search(String query);
  Future<void> create(SavedItem item);
  Future<void> update(SavedItem item);
  Future<void> updateTitle(String id, String title);
  Future<void> updateCategory(String id, SavedItemCategory category);
  Future<void> updateNote(String id, String? note);
  Future<void> changeStatus(String id, SavedItemStatus status);
  Future<void> archive(String id);
  Future<void> markDone(String id);
  Future<void> toggleFavorite(String id);
  Future<void> save(String id);
  Future<void> markActionCompleted(String id, SavedItemActionType action);
  Future<void> snooze(String id, DateTime until);
  Future<void> restore(String id);
  Future<void> softDelete(String id);
}
