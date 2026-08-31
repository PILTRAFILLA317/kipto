import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/repositories/drift_saved_items_repository.dart';
import 'package:kipto/features/notifications/application/notification_route_resolver.dart';
import 'package:kipto/features/notifications/domain/notification_models.dart';

import 'test_helpers.dart';

void main() {
  test(
    'notification tap resolves Detail or safely falls back to Inbox',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final now = DateTime.utc(2026, 8, 30);
      await DriftSavedItemsRepository(database)
          .create(testSavedItem(id: 'A', now: now));
      final resolver = NotificationRouteResolver(database);

      expect(
        await resolver.routeForPayload(
          const ReminderNotificationPayload(
            savedItemId: 'A',
            reminderId: 'R',
          ).encode(),
        ),
        '/item/A',
      );
      expect(
        await resolver.routeForPayload(
          const ReminderNotificationPayload(
            savedItemId: 'missing',
            reminderId: 'R',
          ).encode(),
        ),
        '/inbox',
      );
      expect(await resolver.routeForPayload('invalid'), '/inbox');
    },
  );
}
