import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/features/notifications/application/device_time_zone_service.dart';
import 'package:kipto/features/notifications/application/notification_gateway.dart';
import 'package:kipto/features/notifications/application/notification_route_resolver.dart';
import 'package:kipto/features/notifications/application/reminder_notification_scheduler.dart';
import 'package:kipto/features/notifications/data/notification_mapping_store.dart';
import 'package:kipto/features/notifications/domain/notification_models.dart';

final notificationGatewayProvider = Provider<ReminderNotificationGateway>(
  (_) => FlutterReminderNotificationGateway(),
);

final deviceTimeZoneServiceProvider = Provider<DeviceTimeZoneService>(
  (_) => FlutterDeviceTimeZoneService(),
);

final notificationMappingStoreProvider = Provider<NotificationMappingStore>(
  (ref) => NotificationMappingStore(ref.watch(appDatabaseProvider)),
);

final notificationRouteResolverProvider = Provider<NotificationRouteResolver>(
  (ref) => NotificationRouteResolver(ref.watch(appDatabaseProvider)),
);

final reminderNotificationSchedulerProvider =
    Provider<ReminderNotificationScheduler>(
      (ref) => ReminderNotificationScheduler(
        gateway: ref.watch(notificationGatewayProvider),
        mappings: ref.watch(notificationMappingStoreProvider),
        timeZones: ref.watch(deviceTimeZoneServiceProvider),
      ),
    );

final notificationPermissionStatusProvider =
    FutureProvider<NotificationPermissionStatus>(
      (ref) =>
          ref.watch(reminderNotificationSchedulerProvider).permissionStatus(),
    );

final scheduledReminderCountProvider = FutureProvider<int>(
  (ref) => ref.watch(reminderNotificationSchedulerProvider).scheduledCount(),
);
