import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kipto/features/notifications/domain/notification_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

typedef NotificationPayloadCallback = void Function(String payload);

abstract interface class ReminderNotificationGateway {
  Future<String?> initialize(NotificationPayloadCallback onPayload);
  Future<NotificationPermissionStatus> permissionStatus();
  Future<NotificationPermissionStatus> requestPermission();
  Future<void> openSettings();
  Future<void> schedule({
    required int id,
    required tz.TZDateTime at,
    required String title,
    required String body,
    required String payload,
  });
  Future<void> cancel(int id);
  Future<Set<int>> pendingIds();
  Future<void> showTest();
}

final class FlutterReminderNotificationGateway
    implements ReminderNotificationGateway {
  FlutterReminderNotificationGateway({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _permissionRequestedKey = 'notifications.permissionRequested';
  static const _channelId = 'kipto_reminders';
  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<Set<int>> pendingIds() async =>
      (await _plugin.pendingNotificationRequests()).map((r) => r.id).toSet();

  @override
  Future<String?> initialize(NotificationPayloadCallback onPayload) async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_kipto'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) onPayload(payload);
      },
    );
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        'Kipto reminders',
        description: 'Reminders you create in Kipto',
        importance: Importance.defaultImportance,
      ),
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    return launch?.didNotificationLaunchApp == true
        ? launch?.notificationResponse?.payload
        : null;
  }

  @override
  Future<NotificationPermissionStatus> permissionStatus() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return NotificationPermissionStatus.unavailable;
    }
    final requested =
        (await SharedPreferences.getInstance()).getBool(
          _permissionRequestedKey,
        ) ??
        false;
    if (Platform.isAndroid) {
      final enabled = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.areNotificationsEnabled();
      if (enabled == true) return NotificationPermissionStatus.granted;
      return requested
          ? NotificationPermissionStatus.denied
          : NotificationPermissionStatus.notDetermined;
    }
    final options = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.checkPermissions();
    if (options?.isEnabled == true) {
      return NotificationPermissionStatus.granted;
    }
    return requested
        ? NotificationPermissionStatus.denied
        : NotificationPermissionStatus.notDetermined;
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_permissionRequestedKey, true);
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, sound: true);
    }
    return permissionStatus();
  }

  @override
  Future<void> openSettings() async {
    await _plugin.openAppNotificationSettings();
  }

  @override
  Future<void> schedule({
    required int id,
    required tz.TZDateTime at,
    required String title,
    required String body,
    required String payload,
  }) => _plugin.zonedSchedule(
    id: id,
    title: title,
    body: body,
    scheduledDate: at,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Kipto reminders',
        channelDescription: 'Reminders you create in Kipto',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    payload: payload,
  );

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<void> showTest() => _plugin.show(
    id: 9999,
    title: 'Kipto reminder',
    body: 'Notifications are working.',
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Kipto reminders',
        channelDescription: 'Reminders you create in Kipto',
      ),
      iOS: DarwinNotificationDetails(),
    ),
  );
}
