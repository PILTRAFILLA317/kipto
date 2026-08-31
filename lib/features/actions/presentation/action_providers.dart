import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/providers/repository_providers.dart';
import 'package:kipto/features/actions/application/device_action_services.dart';
import 'package:kipto/features/actions/application/reminder_action_service.dart';
import 'package:kipto/features/actions/application/saved_item_action_executor.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';

final externalLauncherProvider = Provider<ExternalLauncher>(
  (_) => const UrlLauncherExternalLauncher(),
);

final externalUrlServiceProvider = Provider<ExternalUrlService>(
  (ref) => ExternalUrlService(launcher: ref.watch(externalLauncherProvider)),
);

final calendarActionServiceProvider = Provider<CalendarActionService>(
  (_) => const PlatformCalendarActionService(),
);

final mapsActionServiceProvider = Provider<MapsActionService>(
  (ref) => MapsActionService(launcher: ref.watch(externalLauncherProvider)),
);

final webSearchActionServiceProvider = Provider<WebSearchActionService>(
  (ref) => WebSearchActionService(urls: ref.watch(externalUrlServiceProvider)),
);

final clipboardWriterProvider = Provider<ClipboardWriter>(
  (_) => const FlutterClipboardWriter(),
);

final clipboardActionServiceProvider = Provider<ClipboardActionService>(
  (ref) =>
      ClipboardActionService(clipboard: ref.watch(clipboardWriterProvider)),
);

final trackingActionServiceProvider = Provider<TrackingActionService>(
  (ref) => TrackingActionService(urls: ref.watch(externalUrlServiceProvider)),
);

final reminderActionServiceProvider = Provider<ReminderActionService>(
  (ref) => ReminderActionService(
    reminders: ref.watch(remindersRepositoryProvider),
    savedItems: ref.watch(savedItemsRepositoryProvider),
    notifications: ref.watch(reminderNotificationSchedulerProvider),
  ),
);

final savedItemActionExecutorProvider = Provider<SavedItemActionExecutor>(
  (ref) => SavedItemActionExecutor(
    calendar: ref.watch(calendarActionServiceProvider),
    reminders: ref.watch(reminderActionServiceProvider),
    maps: ref.watch(mapsActionServiceProvider),
    urls: ref.watch(externalUrlServiceProvider),
    search: ref.watch(webSearchActionServiceProvider),
    clipboard: ref.watch(clipboardActionServiceProvider),
    tracking: ref.watch(trackingActionServiceProvider),
    savedItems: ref.watch(savedItemsRepositoryProvider),
  ),
);
