import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/features/notifications/domain/notification_models.dart';

final class NotificationRouteResolver {
  const NotificationRouteResolver(this._database, {required this.currentOwner});
  final AppDatabase _database;
  final String? Function() currentOwner;

  Future<String> routeForPayload(String value) async {
    final payload = ReminderNotificationPayload.tryParse(value);
    if (payload == null) return '/inbox';
    final item = await _database.itemsDao.findById(payload.itemId);
    final reminder = await _database.remindersDao.findById(payload.reminderId);
    if (item == null ||
        item.ownerId != currentOwner() ||
        reminder == null ||
        reminder.itemId != item.id ||
        reminder.ownerId != item.ownerId) {
      return '/inbox';
    }
    return '/items/${Uri.encodeComponent(item.id)}';
  }
}
