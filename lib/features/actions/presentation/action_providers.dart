import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/providers/repository_providers.dart';
import 'package:kipto/features/actions/application/action_service.dart';
import 'package:kipto/features/calendar/application/calendar_action_service.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';

final calendarActionServiceProvider = Provider<CalendarActionService>(
  (_) => const PlatformCalendarActionService(),
);
final actionServiceProvider = Provider(
  (ref) => ActionService(
    repository: ref.watch(lifeAdminRepositoryProvider),
    scheduler: ref.watch(reminderNotificationSchedulerProvider),
    mappings: ref.watch(notificationMappingStoreProvider),
    calendar: ref.watch(calendarActionServiceProvider),
  ),
);
