import 'dart:convert';

enum NotificationPermissionStatus {
  notDetermined,
  granted,
  denied,
  unavailable,
}

final class ReminderNotificationPayload {
  const ReminderNotificationPayload({
    required this.itemId,
    required this.reminderId,
  });

  final String itemId;
  final String reminderId;

  String encode() => jsonEncode({'itemId': itemId, 'reminderId': reminderId});

  static ReminderNotificationPayload? tryParse(String? value) {
    if (value == null || value.length > 1000) return null;
    try {
      final json = jsonDecode(value);
      if (json is! Map) return null;
      final itemId = json['itemId'];
      final reminderId = json['reminderId'];
      if (itemId is! String ||
          reminderId is! String ||
          itemId.isEmpty ||
          reminderId.isEmpty) {
        return null;
      }
      return ReminderNotificationPayload(
        itemId: itemId,
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
    required this.itemId,
    required this.remindAt,
    required this.itemTitle,
  });
  final String reminderId;
  final String itemId;
  final DateTime remindAt;
  final String itemTitle;
}
