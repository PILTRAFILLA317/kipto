import 'package:kipto/core/domain/enums/item_enums.dart';

DateTime _date(Object? value) => DateTime.parse(value! as String).toUtc();
DateTime? _nullableDate(Object? value) =>
    value == null ? null : DateTime.parse(value as String).toUtc();

final class RemoteItem {
  const RemoteItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.summary,
    required this.status,
    required this.createdAt,
    required this.clientUpdatedAt,
    required this.serverUpdatedAt,
    this.resolvedAt,
    this.deletedAt,
    this.sourceDeviceId,
  });

  factory RemoteItem.fromJson(Map<String, dynamic> json) => RemoteItem(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    title: json['title'] as String,
    summary: json['summary'] as String? ?? '',
    status: ItemStatusStorage.fromStorage(json['status'] as String),
    createdAt: _date(json['created_at']),
    clientUpdatedAt: _date(json['client_updated_at']),
    serverUpdatedAt: _date(json['server_updated_at']),
    resolvedAt: _nullableDate(json['resolved_at']),
    deletedAt: _nullableDate(json['deleted_at']),
    sourceDeviceId: json['source_device_id'] as String?,
  );

  final String id;
  final String userId;
  final String title;
  final String summary;
  final ItemStatus status;
  final DateTime createdAt;
  final DateTime clientUpdatedAt;
  final DateTime serverUpdatedAt;
  final DateTime? resolvedAt;
  final DateTime? deletedAt;
  final String? sourceDeviceId;

  Map<String, Object?> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'summary': summary,
    'status': status.storageValue,
    'created_at': createdAt.toUtc().toIso8601String(),
    'client_updated_at': clientUpdatedAt.toUtc().toIso8601String(),
    'resolved_at': resolvedAt?.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
    'source_device_id': sourceDeviceId,
  };
}

final class RemoteReminder {
  const RemoteReminder({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.remindAt,
    required this.createdAt,
    required this.clientUpdatedAt,
    required this.serverUpdatedAt,
    this.completedAt,
    this.actionId,
    this.title,
    this.timeZone,
    this.deletedAt,
    this.sourceDeviceId,
  });

  factory RemoteReminder.fromJson(Map<String, dynamic> json) => RemoteReminder(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    itemId: json['item_id'] as String,
    actionId: json['action_id'] as String?,
    title: json['title'] as String?,
    timeZone: json['time_zone'] as String?,
    remindAt: _date(json['remind_at']),
    createdAt: _date(json['created_at']),
    clientUpdatedAt: _date(json['client_updated_at']),
    serverUpdatedAt: _date(json['server_updated_at']),
    completedAt: _nullableDate(json['completed_at']),
    deletedAt: _nullableDate(json['deleted_at']),
    sourceDeviceId: json['source_device_id'] as String?,
  );

  final String id;
  final String userId;
  final String itemId;
  final String? actionId, title, timeZone;
  final DateTime remindAt;
  final DateTime createdAt;
  final DateTime clientUpdatedAt;
  final DateTime serverUpdatedAt;
  final DateTime? completedAt;
  final DateTime? deletedAt;
  final String? sourceDeviceId;

  Map<String, Object?> toJson() => {
    'id': id,
    'user_id': userId,
    'item_id': itemId,
    'action_id': actionId,
    'title': title,
    'time_zone': timeZone,
    'remind_at': remindAt.toUtc().toIso8601String(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'client_updated_at': clientUpdatedAt.toUtc().toIso8601String(),
    'completed_at': completedAt?.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
    'source_device_id': sourceDeviceId,
  };
}

final class RemoteDevice {
  const RemoteDevice({
    required this.id,
    required this.userId,
    required this.platform,
    required this.lastSeenAt,
    this.appVersion,
  });
  final String id;
  final String userId;
  final String platform;
  final String? appVersion;
  final DateTime lastSeenAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'user_id': userId,
    'platform': platform,
    'app_version': appVersion,
    'last_seen_at': lastSeenAt.toUtc().toIso8601String(),
  };
}
