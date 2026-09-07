import 'dart:async';

import 'package:kipto/features/notifications/application/device_time_zone_service.dart';
import 'package:kipto/features/notifications/application/notification_gateway.dart';
import 'package:kipto/features/notifications/domain/notification_models.dart';
import 'package:timezone/timezone.dart' as tz;

class TestNotificationGateway implements ReminderNotificationGateway {
  final Map<int, String> scheduled = {};
  List<String> get payloads => scheduled.values.toList();
  var permission = NotificationPermissionStatus.granted;
  int scheduleCalls = 0, cancelCalls = 0;
  bool failSchedule = false;
  Completer<void>? scheduleEntered, scheduleRelease;
  @override
  Future<Set<int>> pendingIds() async => scheduled.keys.toSet();
  @override
  Future<void> cancel(int id) async {
    cancelCalls++;
    scheduled.remove(id);
  }

  @override
  Future<String?> initialize(NotificationPayloadCallback onPayload) async =>
      null;
  @override
  Future<void> openSettings() async {}
  @override
  Future<NotificationPermissionStatus> permissionStatus() async => permission;
  @override
  Future<NotificationPermissionStatus> requestPermission() async => permission;
  @override
  Future<void> schedule({
    required int id,
    required tz.TZDateTime at,
    required String title,
    required String body,
    required String payload,
  }) async {
    scheduleCalls++;
    scheduleEntered?.complete();
    await scheduleRelease?.future;
    if (failSchedule) throw StateError("Synthetic scheduling failure");
    scheduled[id] = payload;
  }

  @override
  Future<void> showTest() async {}
}

class TestTimeZones implements DeviceTimeZoneService {
  const TestTimeZones();
  @override
  Future<String> currentIdentifier() async => 'UTC';
  @override
  tz.Location locationFor(String identifier) => tz.UTC;
}
