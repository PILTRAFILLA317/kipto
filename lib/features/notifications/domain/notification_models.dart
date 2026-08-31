import 'dart:convert';

enum NotificationPermissionStatus {
  notDetermined,
  granted,
  denied,
  unavailable,
}

final class ReminderNotificationPayload {
  const ReminderNotificationPayload({
    required this.savedItemId,
    required this.reminderId,
  });

  final String savedItemId;
  final String reminderId;

  String encode() =>
      jsonEncode({'savedItemId': savedItemId, 'reminderId': reminderId});

  static ReminderNotificationPayload? tryParse(String? value) {
    if (value == null || value.length > 1000) return null;
    try {
      final json = jsonDecode(value);
      if (json is! Map) return null;
      final savedItemId = json['savedItemId'];
      final reminderId = json['reminderId'];
      if (savedItemId is! String ||
          reminderId is! String ||
          savedItemId.isEmpty ||
          reminderId.isEmpty) {
        return null;
      }
      return ReminderNotificationPayload(
        savedItemId: savedItemId,
        reminderId: reminderId,
      );
    } on Object {
      return null;
    }
  }
}

final class NotificationMapping {
  const NotificationMapping({
    required this.reminderId,
    required this.notificationId,
    required this.scheduledFor,
    required this.timeZone,
  });

  final String reminderId;
  final int notificationId;
  final DateTime scheduledFor;
  final String timeZone;
}

final class ReminderScheduleCandidate {
  const ReminderScheduleCandidate({
    required this.reminderId,
    required this.savedItemId,
    required this.remindAt,
    required this.savedItemTitle,
  });

  final String reminderId;
  final String savedItemId;
  final DateTime remindAt;
  final String savedItemTitle;
}
