import 'package:kipto/core/domain/models/fact_value.dart';
import 'package:kipto/core/domain/models/temporal_value.dart';

enum ActionKind { remind, event, keep }

enum ActionOrigin { analysis, user }

enum ActionState { proposed, accepted, dismissed }

enum ActionExecutionState {
  notRequested,
  pending,
  applied,
  launchedUnconfirmed,
  failed,
}

sealed class ActionPayload {
  const ActionPayload();
  ActionKind get kind;
  bool get ready;
  Map<String, Object?> toJson();
  factory ActionPayload.parse(
    ActionKind kind,
    int version,
    Map<String, dynamic> json,
  ) {
    if (version != 1) throw const FormatException('Unsupported action payload');
    return switch (kind) {
      ActionKind.keep => KeepPayload.parse(json),
      ActionKind.remind => RemindPayload.parse(json),
      ActionKind.event => EventPayload.parse(json),
    };
  }
}

final class KeepPayload extends ActionPayload {
  const KeepPayload();
  factory KeepPayload.parse(Map<String, dynamic> json) {
    requireKeys(json, {});
    return const KeepPayload();
  }
  @override
  ActionKind get kind => ActionKind.keep;
  @override
  bool get ready => true;
  @override
  Map<String, Object?> toJson() => {};
}

final class RemindPayload extends ActionPayload {
  RemindPayload({this.instant, this.zone}) {
    if (instant != null && !instant!.isUtc) {
      throw const FormatException('UTC required');
    }
    if (zone != null) timeZoneLocation(zone!);
  }
  final DateTime? instant;
  final String? zone;
  factory RemindPayload.parse(Map<String, dynamic> json) {
    requireKeys(json, {'instant', 'zone'});
    return RemindPayload(
      instant: json['instant'] == null
          ? null
          : parseUtcInstant(json['instant']),
      zone: json['zone'] as String?,
    );
  }
  @override
  ActionKind get kind => ActionKind.remind;
  @override
  bool get ready => instant != null && zone != null;
  @override
  Map<String, Object?> toJson() => {
    'instant': instant?.toIso8601String(),
    'zone': zone,
  };
}

final class EventPayload extends ActionPayload {
  EventPayload({
    required this.allDay,
    this.start,
    this.end,
    this.startDate,
    this.endDateExclusive,
    this.zone,
    this.location,
  }) {
    if (zone != null) timeZoneLocation(zone!);
    if (location != null) boundedText(location, 500, allowEmpty: true);
    if (allDay && (start != null || end != null) ||
        !allDay && (startDate != null || endDateExclusive != null)) {
      throw const FormatException('Mixed calendar and instant event');
    }
    if (start != null && !start!.isUtc ||
        end != null && !end!.isUtc ||
        start != null && end != null && !end!.isAfter(start!)) {
      throw const FormatException('Invalid event interval');
    }
    if (startDate != null &&
        endDateExclusive != null &&
        endDateExclusive.toString().compareTo(startDate.toString()) <= 0) {
      throw const FormatException('Invalid all-day interval');
    }
  }
  final bool allDay;
  final DateTime? start, end;
  final CalendarDate? startDate, endDateExclusive;
  final String? zone, location;
  factory EventPayload.parse(Map<String, dynamic> json) {
    requireKeys(json, {
      'allDay',
      'start',
      'end',
      'startDate',
      'endDateExclusive',
      'zone',
      'location',
    });
    return EventPayload(
      allDay: json['allDay'] as bool,
      start: json['start'] == null ? null : parseUtcInstant(json['start']),
      end: json['end'] == null ? null : parseUtcInstant(json['end']),
      startDate: json['startDate'] == null
          ? null
          : CalendarDate.parse(json['startDate'] as String),
      endDateExclusive: json['endDateExclusive'] == null
          ? null
          : CalendarDate.parse(json['endDateExclusive'] as String),
      zone: json['zone'] as String?,
      location: json['location'] as String?,
    );
  }
  @override
  ActionKind get kind => ActionKind.event;
  @override
  bool get ready => allDay
      ? startDate != null && endDateExclusive != null
      : start != null && end != null && zone != null;
  @override
  Map<String, Object?> toJson() => {
    'allDay': allDay,
    'start': start?.toIso8601String(),
    'end': end?.toIso8601String(),
    'startDate': startDate?.toString(),
    'endDateExclusive': endDateExclusive?.toString(),
    'zone': zone,
    'location': location,
  };
}

final class ItemAction {
  ItemAction({
    required this.id,
    required this.itemId,
    this.ownerId,
    required String title,
    required this.payload,
    required this.origin,
    this.sourceId,
    this.analysisRevision,
    List<String> evidenceFactIds = const [],
    this.state = ActionState.proposed,
    this.executionState = ActionExecutionState.notRequested,
    required this.createdAt,
    required this.updatedAt,
    this.acceptedAt,
    this.serverUpdatedAt,
    this.deletedAt,
  }) : title = boundedText(title, 100),
       evidenceFactIds = List.unmodifiable(evidenceFactIds) {
    if (evidenceFactIds.length > 12 ||
        evidenceFactIds.toSet().length != evidenceFactIds.length ||
        state == ActionState.accepted &&
            (!payload.ready || acceptedAt == null) ||
        state != ActionState.accepted &&
            executionState != ActionExecutionState.notRequested ||
        (sourceId == null) != (analysisRevision == null) ||
        (analysisRevision != null && analysisRevision! < 1)) {
      throw const FormatException('Invalid action state');
    }
  }
  final String id, itemId, title;
  final String? ownerId, sourceId;
  final int? analysisRevision;
  final ActionPayload payload;
  final ActionOrigin origin;
  final List<String> evidenceFactIds;
  final ActionState state;
  final ActionExecutionState executionState;
  final DateTime createdAt, updatedAt;
  final DateTime? acceptedAt, serverUpdatedAt, deletedAt;
  Map<String, Object?> toJson() => {
    'id': id,
    'item_id': itemId,
    'user_id': ownerId,
    'kind': payload.kind.name,
    'title': title,
    'payload_version': 1,
    'payload': payload.toJson(),
    'origin': origin.name,
    'source_id': sourceId,
    'analysis_revision': analysisRevision,
    'evidence_fact_ids': evidenceFactIds,
    'state': state.name,
    'execution_state': executionState.name,
    'created_at': createdAt.toUtc().toIso8601String(),
    'client_updated_at': updatedAt.toUtc().toIso8601String(),
    'accepted_at': acceptedAt?.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
  };
  factory ItemAction.fromJson(Map<String, dynamic> j) => ItemAction(
    id: j['id'] as String,
    itemId: j['item_id'] as String,
    ownerId: j['user_id'] as String?,
    title: j['title'] as String,
    payload: ActionPayload.parse(
      ActionKind.values.byName(j['kind'] as String),
      j['payload_version'] as int,
      Map<String, dynamic>.from(j['payload'] as Map),
    ),
    origin: ActionOrigin.values.byName(j['origin'] as String),
    sourceId: j['source_id'] as String?,
    analysisRevision: j['analysis_revision'] as int?,
    evidenceFactIds: (j['evidence_fact_ids'] as List).cast<String>(),
    state: ActionState.values.byName(j['state'] as String),
    executionState: ActionExecutionState.values.byName(
      j['execution_state'] as String,
    ),
    createdAt: DateTime.parse(j['created_at'] as String).toUtc(),
    updatedAt: DateTime.parse(j['client_updated_at'] as String).toUtc(),
    acceptedAt: j['accepted_at'] == null
        ? null
        : DateTime.parse(j['accepted_at'] as String).toUtc(),
    serverUpdatedAt: j['server_updated_at'] == null
        ? null
        : DateTime.parse(j['server_updated_at'] as String).toUtc(),
    deletedAt: j['deleted_at'] == null
        ? null
        : DateTime.parse(j['deleted_at'] as String).toUtc(),
  );
}
