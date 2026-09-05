import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/domain/models/item.dart';

abstract interface class ItemsRepository {
  Stream<List<Item>> watchActive();
  Future<Item?> findById(String id, {bool includeDeleted = false});
  Future<Item> create({required String title, String summary = ''});
  Future<void> setStatus(String id, ItemStatus status);
  Future<void> delete(String id);
}
