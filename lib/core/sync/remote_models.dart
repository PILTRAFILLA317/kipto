import 'package:kipto/core/domain/enums/saved_item_enums.dart';

DateTime _date(Object? value) => DateTime.parse(value! as String).toUtc();
DateTime? _nullableDate(Object? value) =>
    value == null ? null : DateTime.parse(value as String).toUtc();

final class RemoteSavedItem {
  const RemoteSavedItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.summary,
    required this.category,
    required this.status,
    required this.favorite,
    required this.capturedAt,
    required this.entities,
    required this.availableActions,
    required this.analysisStatus,
    required this.createdAt,
    required this.clientUpdatedAt,
    required this.serverUpdatedAt,
    this.subtype,
    this.intent,
    this.eventAt,
    this.expiresAt,
    this.snoozedUntil,
    this.location,
    this.cloudPreviewPath,
    this.imageHash,
    this.analysisVersion,
    this.confidence,
    this.sourceDeviceId,
    this.deletedAt,
  });

  factory RemoteSavedItem.fromJson(Map<String, dynamic> json) =>
      RemoteSavedItem(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String? ?? '',
        category: SavedItemCategoryStorage.fromStorage(
          json['category'] as String,
        ),
        subtype: json['subtype'] as String?,
        intent: json['intent'] as String?,
        status: SavedItemStatusStorage.fromStorage(json['status'] as String),
        favorite: json['favorite'] as bool? ?? false,
        capturedAt: _date(json['captured_at']),
        eventAt: _nullableDate(json['event_at']),
        expiresAt: _nullableDate(json['expires_at']),
        snoozedUntil: _nullableDate(json['snoozed_until']),
        location: json['location_json'] as String?,
        entities: Map<String, Object?>.from(
          json['entities_json'] as Map? ?? const {},
        ),
        availableActions: (json['available_actions_json'] as List? ?? const [])
            .whereType<String>()
            .map(SavedItemActionTypeStorage.fromStorage)
            .toList(growable: false),
        cloudPreviewPath: json['cloud_preview_path'] as String?,
        imageHash: json['image_hash'] as String?,
        analysisStatus: AnalysisStatusStorage.fromStorage(
          json['analysis_status'] as String,
        ),
        analysisVersion: json['analysis_version'] as int?,
        confidence: (json['confidence'] as num?)?.toDouble(),
        clientUpdatedAt: _date(json['client_updated_at']),
        serverUpdatedAt: _date(json['server_updated_at']),
        sourceDeviceId: json['source_device_id'] as String?,
        createdAt: _date(json['created_at']),
        deletedAt: _nullableDate(json['deleted_at']),
      );

  final String id;
  final String userId;
  final String title;
  final String summary;
  final SavedItemCategory category;
  final String? subtype;
  final String? intent;
  final SavedItemStatus status;
  final bool favorite;
  final DateTime capturedAt;
  final DateTime? eventAt;
  final DateTime? expiresAt;
  final DateTime? snoozedUntil;
  final String? location;
  final Map<String, Object?> entities;
  final List<SavedItemActionType> availableActions;
  final String? cloudPreviewPath;
  final String? imageHash;
  final AnalysisStatus analysisStatus;
  final int? analysisVersion;
  final double? confidence;
  final DateTime clientUpdatedAt;
  final DateTime serverUpdatedAt;
  final String? sourceDeviceId;
  final DateTime createdAt;
  final DateTime? deletedAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'summary': summary,
    'category': category.storageValue,
    'subtype': subtype,
    'intent': intent,
    'status': status.storageValue,
    'favorite': favorite,
    'captured_at': capturedAt.toIso8601String(),
    'event_at': eventAt?.toIso8601String(),
    'expires_at': expiresAt?.toIso8601String(),
    'snoozed_until': snoozedUntil?.toIso8601String(),
    'location_json': location,
    'entities_json': entities,
    'available_actions_json': availableActions
        .map((value) => value.storageValue)
        .toList(),
    'cloud_preview_path': cloudPreviewPath,
    'image_hash': imageHash,
    'analysis_status': analysisStatus.storageValue,
    'analysis_version': analysisVersion,
    'confidence': confidence,
    'client_updated_at': clientUpdatedAt.toIso8601String(),
    'source_device_id': sourceDeviceId,
    'created_at': createdAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };
}

final class RemoteReminder {
  const RemoteReminder({
    required this.id,
    required this.userId,
    required this.savedItemId,
    required this.remindAt,
    required this.kind,
    required this.clientUpdatedAt,
    required this.serverUpdatedAt,
    required this.createdAt,
    this.completedAt,
    this.sourceDeviceId,
    this.deletedAt,
  });

  factory RemoteReminder.fromJson(Map<String, dynamic> json) => RemoteReminder(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    savedItemId: json['saved_item_id'] as String,
    remindAt: _date(json['remind_at']),
    kind: ReminderKindStorage.fromStorage(json['kind'] as String),
    completedAt: _nullableDate(json['completed_at']),
    clientUpdatedAt: _date(json['client_updated_at']),
    serverUpdatedAt: _date(json['server_updated_at']),
    sourceDeviceId: json['source_device_id'] as String?,
    createdAt: _date(json['created_at']),
    deletedAt: _nullableDate(json['deleted_at']),
  );

  final String id;
  final String userId;
  final String savedItemId;
  final DateTime remindAt;
  final ReminderKind kind;
  final DateTime? completedAt;
  final DateTime clientUpdatedAt;
  final DateTime serverUpdatedAt;
  final String? sourceDeviceId;
  final DateTime createdAt;
  final DateTime? deletedAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'user_id': userId,
    'saved_item_id': savedItemId,
    'remind_at': remindAt.toIso8601String(),
    'kind': kind.storageValue,
    'completed_at': completedAt?.toIso8601String(),
    'client_updated_at': clientUpdatedAt.toIso8601String(),
    'source_device_id': sourceDeviceId,
    'created_at': createdAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
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
    'last_seen_at': lastSeenAt.toIso8601String(),
  };
}
