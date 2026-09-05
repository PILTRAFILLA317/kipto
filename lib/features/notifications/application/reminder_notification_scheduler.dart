// ignore_for_file: prefer_initializing_formals

import 'package:clock/clock.dart';
import 'package:kipto/features/notifications/application/device_time_zone_service.dart';
import 'package:kipto/features/notifications/application/notification_gateway.dart';
import 'package:kipto/features/notifications/data/notification_mapping_store.dart';
import 'package:kipto/features/notifications/domain/notification_models.dart';
import 'package:timezone/timezone.dart' as tz;

final class ReminderNotificationScheduler {
  ReminderNotificationScheduler({
    required ReminderNotificationGateway gateway,
    required NotificationMappingStore mappings,
    required DeviceTimeZoneService timeZones,
    Clock? clock,
    this.scheduleLimit = 50,
  }) : _gateway = gateway,
       _mappings = mappings,
       _timeZones = timeZones,
       _clock = clock ?? const Clock();

  final ReminderNotificationGateway _gateway;
  final NotificationMappingStore _mappings;
  final DeviceTimeZoneService _timeZones;
  final Clock _clock;
  final int scheduleLimit;
  Future<void>? _reconciling;
  bool _runAgain = false;
  bool _initialized = false;

  Future<String?> initialize(NotificationPayloadCallback onPayload) async {
    if (_initialized) return null;
    final initialPayload = await _gateway.initialize(onPayload);
    _initialized = true;
    await reconcile();
    return initialPayload;
  }

  Future<NotificationPermissionStatus> permissionStatus() =>
      _gateway.permissionStatus();
  Future<NotificationPermissionStatus> requestPermission() async {
    final value = await _gateway.requestPermission();
    await reconcile();
    return value;
  }

  Future<void> openSettings() => _gateway.openSettings();
  Future<void> showTest() => _gateway.showTest();
  Future<int> scheduledCount() => _mappings.count();

  Future<void> clearLocalProjection() async {
    for (final mapping in await _mappings.list()) {
      await _gateway.cancel(mapping.notificationId);
      await _mappings.remove(mapping.reminderId);
    }
  }

  Future<void> reconcile() {
    final active = _reconciling;
    if (active != null) {
      _runAgain = true;
      return active;
    }
    final operation = _runSerial();
    _reconciling = operation;
    return operation.whenComplete(() => _reconciling = null);
  }

  Future<void> _runSerial() async {
    do {
      _runAgain = false;
      await _reconcileOnce();
    } while (_runAgain);
  }

  Future<void> _reconcileOnce() async {
    final currentMappings = await _mappings.list();
    if (await permissionStatus() != NotificationPermissionStatus.granted) {
      for (final mapping in currentMappings) {
        await _gateway.cancel(mapping.notificationId);
        await _mappings.remove(mapping.reminderId);
      }
      return;
    }
    final identifier = await _timeZones.currentIdentifier();
    final location = _timeZones.locationFor(identifier);
    final now = _clock.now().toUtc();
    final candidates = await _mappings.nextCandidates(
      after: now,
      limit: scheduleLimit,
    );
    final candidateByReminder = {
      for (final item in candidates) item.reminderId: item,
    };
    final retained = <String>{};
    for (final mapping in currentMappings) {
      final candidate = candidateByReminder[mapping.reminderId];
      final matches =
          candidate != null &&
          mapping.scheduledFor.isAtSameMomentAs(candidate.remindAt) &&
          mapping.timeZone == identifier;
      if (matches) {
        retained.add(mapping.reminderId);
      } else {
        await _gateway.cancel(mapping.notificationId);
        await _mappings.remove(mapping.reminderId);
      }
    }
    for (final candidate in candidates) {
      if (retained.contains(candidate.reminderId)) continue;
      final at = tz.TZDateTime.from(candidate.remindAt, location);
      if (!at.isAfter(tz.TZDateTime.from(now, location))) continue;
      final id = await _mappings.allocateNotificationId();
      await _gateway.schedule(
        id: id,
        at: at,
        title: 'Kipto reminder',
        body: _body(candidate.itemTitle),
        payload: ReminderNotificationPayload(
          itemId: candidate.itemId,
          reminderId: candidate.reminderId,
        ).encode(),
      );
      await _mappings.put(
        NotificationMapping(
          reminderId: candidate.reminderId,
          notificationId: id,
          scheduledFor: candidate.remindAt,
          timeZone: identifier,
        ),
      );
    }
  }

  String _body(String title) {
    final normalized = title.trim();
    if (normalized.isEmpty) return 'An item needs your attention.';
    return normalized.length <= 120
        ? normalized
        : '${normalized.substring(0, 117)}…';
  }
}
