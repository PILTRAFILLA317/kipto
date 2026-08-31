// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
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
    final status = await _gateway.requestPermission();
    await reconcile();
    return status;
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
    final status = await permissionStatus();
    final currentMappings = await _mappings.list();
    if (status != NotificationPermissionStatus.granted) {
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
    final byReminder = {
      for (final candidate in candidates) candidate.reminderId: candidate,
    };
    final retained = <String, NotificationMapping>{};
    for (final mapping in currentMappings) {
      final candidate = byReminder[mapping.reminderId];
      final matches =
          candidate != null &&
          mapping.scheduledFor.isAtSameMomentAs(candidate.remindAt) &&
          mapping.timeZone == identifier;
      if (matches) {
        retained[mapping.reminderId] = mapping;
      } else {
        await _gateway.cancel(mapping.notificationId);
        await _mappings.remove(mapping.reminderId);
      }
    }
    for (final candidate in candidates) {
      if (retained.containsKey(candidate.reminderId)) continue;
      final id = await _mappings.allocateNotificationId();
      final scheduled = tz.TZDateTime.from(candidate.remindAt, location);
      if (!scheduled.isAfter(tz.TZDateTime.from(now, location))) continue;
      final payload = ReminderNotificationPayload(
        savedItemId: candidate.savedItemId,
        reminderId: candidate.reminderId,
      );
      try {
        await _gateway.schedule(
          id: id,
          at: scheduled,
          title: 'Kipto reminder',
          body: _body(candidate.savedItemTitle),
          payload: payload.encode(),
        );
        await _mappings.put(
          NotificationMapping(
            reminderId: candidate.reminderId,
            notificationId: id,
            scheduledFor: candidate.remindAt,
            timeZone: identifier,
          ),
        );
      } on Object catch (error) {
        _log('notifications.schedule.failed', {
          'reminderId': candidate.reminderId,
          'errorCode': error.runtimeType.toString(),
        });
      }
    }
    _log('notifications.reconciled', {
      'scheduled': candidates.length,
      'timezone': identifier,
    });
  }

  String _body(String title) {
    final normalized = title.trim();
    if (normalized.isEmpty) return 'A saved item needs your attention.';
    return normalized.length <= 120
        ? normalized
        : '${normalized.substring(0, 117)}…';
  }

  void _log(String event, Map<String, Object?> fields) {
    if (kDebugMode) debugPrint('$event $fields');
  }
}
