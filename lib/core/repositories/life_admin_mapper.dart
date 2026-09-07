import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/models/fact.dart';
import 'package:kipto/core/domain/models/item_action.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';

Fact factFromRow(FactRow row) => Fact.fromJson({
  'id': row.id,
  'item_id': row.itemId,
  'user_id': row.ownerId,
  'source_id': row.sourceId,
  'source_revision': row.sourceRevision,
  'key': row.key,
  'value_type': row.valueType,
  'value': jsonDecode(row.value),
  'user_value': row.userValue == null ? null : jsonDecode(row.userValue!),
  'provenance': row.provenance,
  'evidence': jsonDecode(row.evidence),
  'created_at': row.createdAt.toUtc().toIso8601String(),
  'client_updated_at': row.updatedAt.toUtc().toIso8601String(),
  'server_updated_at': row.remoteServerUpdatedAt?.toUtc().toIso8601String(),
  'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
});

FactsCompanion factCompanion(Fact entity, SyncStatus status) {
  final j = entity.toJson();
  return FactsCompanion.insert(
    id: entity.id,
    itemId: entity.itemId,
    ownerId: Value(entity.ownerId),
    sourceId: Value(entity.sourceId),
    sourceRevision: Value(entity.sourceRevision),
    key: j['key'] as String,
    valueType: j['value_type'] as String,
    value: jsonEncode(j['value']),
    userValue: Value(
      j['user_value'] == null ? null : jsonEncode(j['user_value']),
    ),
    provenance: j['provenance'] as String,
    evidence: jsonEncode(j['evidence']),
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
    remoteServerUpdatedAt: Value(entity.serverUpdatedAt),
    deletedAt: Value(entity.deletedAt),
    syncStatus: status,
  );
}

ItemAction actionFromRow(ItemActionRow row) => ItemAction.fromJson({
  'id': row.id,
  'item_id': row.itemId,
  'user_id': row.ownerId,
  'source_id': row.sourceId,
  'analysis_revision': row.analysisRevision,
  'kind': row.kind,
  'title': row.title,
  'payload_version': row.payloadVersion,
  'payload': jsonDecode(row.payload),
  'origin': row.origin,
  'evidence_fact_ids': jsonDecode(row.evidenceFactIds),
  'state': row.state,
  'execution_state': row.executionState,
  'accepted_at': row.acceptedAt?.toUtc().toIso8601String(),
  'created_at': row.createdAt.toUtc().toIso8601String(),
  'client_updated_at': row.updatedAt.toUtc().toIso8601String(),
  'server_updated_at': row.remoteServerUpdatedAt?.toUtc().toIso8601String(),
  'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
});

ItemActionsCompanion actionCompanion(ItemAction entity, SyncStatus status) {
  final j = entity.toJson();
  return ItemActionsCompanion.insert(
    id: entity.id,
    itemId: entity.itemId,
    ownerId: Value(entity.ownerId),
    sourceId: Value(entity.sourceId),
    analysisRevision: Value(entity.analysisRevision),
    kind: j['kind'] as String,
    title: j['title'] as String,
    payloadVersion: Value(j['payload_version'] as int),
    payload: jsonEncode(j['payload']),
    origin: j['origin'] as String,
    evidenceFactIds: Value(jsonEncode(j['evidence_fact_ids'])),
    state: Value(j['state'] as String),
    executionState: Value(j['execution_state'] as String),
    acceptedAt: Value(entity.acceptedAt),
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
    remoteServerUpdatedAt: Value(entity.serverUpdatedAt),
    deletedAt: Value(entity.deletedAt),
    syncStatus: status,
  );
}
