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
    this.enabled,
    this.includeTitle,
    this.discreetBody,
  }) : _gateway = gateway,
       _mappings = mappings,
       _timeZones = timeZones,
       _clock = clock ?? const Clock();

  final ReminderNotificationGateway _gateway;
  final NotificationMappingStore _mappings;
  final DeviceTimeZoneService _timeZones;
  final Clock _clock;
  final int scheduleLimit;
  final bool Function()? enabled, includeTitle;
  final String Function()? discreetBody;
  bool? _previousIncludeTitle;
  Future<void>? _reconciling;
  bool _runAgain = false;
  bool _initialized = false;
  Future<void>? _clearing;

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
  Future<Set<String>> scheduledIds() async {
    final pending = await _gateway.pendingIds();
    return (await _mappings.list())
        .where((m) => pending.contains(m.notificationId))
        .map((m) => m.reminderId)
        .toSet();
  }

  Future<int> scheduledCount() async => (await scheduledIds()).length;

  Future<void> clearLocalProjection() =>
      _clearing ??= _clearAfterReconcile().whenComplete(() => _clearing = null);

  Future<void> _clearAfterReconcile() async {
    // Never let an older reconciliation recreate an alert after logout cleanup.
    _runAgain = false;
    try {
      await _reconciling;
    } on Object {
      /* Still cancel tracked intents. */
    }
    for (final mapping in await _mappings.list()) {
      await _gateway.cancel(mapping.notificationId);
      await _mappings.remove(mapping.reminderId);
    }
  }

  Future<void> reconcile() {
    if (_clearing != null) return _clearing!;
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
    final owner = _mappings.currentOwner?.call();
    bool current() {
      if (_mappings.currentOwner?.call() != owner) {
        _runAgain = true;
        return false;
      }
      return true;
    }

    final currentMappings = await _mappings.list();
    final showTitle = includeTitle?.call() ?? false;
    final contentChanged = _previousIncludeTitle != showTitle;
    _previousIncludeTitle = showTitle;
    if (enabled?.call() == false ||
        await permissionStatus() != NotificationPermissionStatus.granted) {
      for (final mapping in currentMappings) {
        await _gateway.cancel(mapping.notificationId);
        await _mappings.remove(mapping.reminderId);
      }
      return;
    }
    final identifier = await _timeZones.currentIdentifier();
    final pendingIds = await _gateway.pendingIds();
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
          !contentChanged &&
          candidate != null &&
          pendingIds.contains(mapping.notificationId) &&
          mapping.scheduledFor.isAtSameMomentAs(candidate.remindAt) &&
          mapping.timeZone == identifier;
      if (matches) {
        retained.add(mapping.reminderId);
      } else {
        await _gateway.cancel(mapping.notificationId);
        if (candidate == null) await _mappings.remove(mapping.reminderId);
      }
    }
    for (final candidate in candidates) {
      if (!current()) return;
      if (retained.contains(candidate.reminderId)) continue;
      final at = tz.TZDateTime.from(candidate.remindAt, location);
      if (!at.isAfter(tz.TZDateTime.from(now, location))) continue;
      final previous = currentMappings
          .where((m) => m.reminderId == candidate.reminderId)
          .firstOrNull;
      final id =
          previous?.notificationId ?? await _mappings.allocateNotificationId();
      // Record intent before the system call. A process death can leave a
      // mapping without an OS request; the next pass detects and retries it.
      // It cannot leave an untracked scheduled notification.
      await _mappings.put(
        NotificationMapping(
          reminderId: candidate.reminderId,
          notificationId: id,
          scheduledFor: candidate.remindAt,
          timeZone: identifier,
        ),
      );
      if (!current()) return;
      await _gateway.schedule(
        id: id,
        at: at,
        title: 'Kipto',
        body: showTitle
            ? _body(candidate.itemTitle)
            : (discreetBody?.call() ?? 'An item needs your attention.'),
        payload: ReminderNotificationPayload(
          itemId: candidate.itemId,
          reminderId: candidate.reminderId,
        ).encode(),
      );
    }
    current();
  }

  String _body(String title) {
    final normalized = title.trim();
    if (normalized.isEmpty) return 'An item needs your attention.';
    return normalized.length <= 120
        ? normalized
        : '${normalized.substring(0, 117)}…';
  }
}
