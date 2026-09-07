import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/domain/models/item.dart';

abstract interface class ItemsRepository {
  Stream<List<Item>> watchActive();
  Stream<List<Item>> watchAll();
  Future<Item?> findById(String id, {bool includeDeleted = false});
  Future<Item> create({required String title, String summary = ''});
  Future<void> setStatus(
    String id,
    ItemStatus status, {
    bool cancelReminders = false,
  });
  Future<void> updateText(
    String id, {
    required String title,
    required String summary,
  });
  Future<void> delete(String id);
}
