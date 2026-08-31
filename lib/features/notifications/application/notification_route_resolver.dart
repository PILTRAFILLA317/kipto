import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/features/notifications/domain/notification_models.dart';

final class NotificationRouteResolver {
  const NotificationRouteResolver(this._database);

  final AppDatabase _database;

  Future<String> routeForPayload(String value) async {
    final payload = ReminderNotificationPayload.tryParse(value);
    if (payload == null) return '/inbox';
    final item = await _database.savedItemsDao.findById(payload.savedItemId);
    return item == null ? '/inbox' : '/item/${payload.savedItemId}';
  }
}
