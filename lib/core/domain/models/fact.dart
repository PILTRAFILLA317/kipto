import 'package:kipto/core/domain/models/fact_value.dart';

enum FactProvenance { extracted, derived, user }

enum EvidenceVerification {
  textMatched,
  visualReference,
  userConfirmed,
  unverified,
}

final class FactEvidence {
  FactEvidence({this.page, this.quote, required this.verification}) {
    if (page != null && page! < 1) {
      throw const FormatException('Invalid evidence page');
    }
    if (quote != null) boundedText(quote, 2000);
    if (verification == EvidenceVerification.textMatched && quote == null) {
      throw const FormatException('Matched evidence requires a quote');
    }
  }
  final int? page;
  final String? quote;
  final EvidenceVerification verification;
  Map<String, Object?> toJson() => {
    'page': page,
    'quote': quote,
    'verification': verification.name,
  };
  factory FactEvidence.parse(Map<String, dynamic> j) {
    requireKeys(j, {'page', 'quote', 'verification'});
    return FactEvidence(
      page: j['page'] as int?,
      quote: j['quote'] as String?,
      verification: EvidenceVerification.values.byName(
        j['verification'] as String,
      ),
    );
  }
}

final class Fact {
  Fact({
    required this.id,
    required this.itemId,
    this.ownerId,
    this.sourceId,
    required String key,
    required this.value,
    this.userValue,
    required this.provenance,
    this.sourceRevision,
    required this.evidence,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
    this.deletedAt,
  }) : key = boundedText(key, 100) {
    if ((sourceId == null) != (sourceRevision == null) ||
        (sourceRevision != null && sourceRevision! < 1) ||
        (provenance == FactProvenance.extracted && sourceId == null) ||
        (userValue != null && userValue!.type != value.type)) {
      throw const FormatException('Invalid fact lineage');
    }
  }
  final String id, itemId, key;
  final String? ownerId, sourceId;
  final FactValue value;

  /// Keep the extracted value and evidence when the user corrects a fact.
  final FactValue? userValue;
  FactValue get effectiveValue => userValue ?? value;
  final FactProvenance provenance;
  final int? sourceRevision;
  final FactEvidence evidence;
  final DateTime createdAt, updatedAt;
  final DateTime? serverUpdatedAt, deletedAt;
  Map<String, Object?> toJson() => {
    'id': id,
    'item_id': itemId,
    'user_id': ownerId,
    'source_id': sourceId,
    'key': key,
    'value_type': value.type,
    'value': value.toJson(),
    'user_value': userValue?.toJson(),
    'provenance': provenance.name,
    'source_revision': sourceRevision,
    'evidence': evidence.toJson(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'client_updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
  };
  factory Fact.fromJson(Map<String, dynamic> j) => Fact(
    id: j['id'] as String,
    itemId: j['item_id'] as String,
    ownerId: j['user_id'] as String?,
    sourceId: j['source_id'] as String?,
    key: j['key'] as String,
    value: FactValue.parse(
      j['value_type'] as String,
      Map<String, dynamic>.from(j['value'] as Map),
    ),
    userValue: j['user_value'] == null
        ? null
        : FactValue.parse(
            j['value_type'] as String,
            Map<String, dynamic>.from(j['user_value'] as Map),
          ),
    provenance: FactProvenance.values.byName(j['provenance'] as String),
    sourceRevision: j['source_revision'] as int?,
    evidence: FactEvidence.parse(
      Map<String, dynamic>.from(j['evidence'] as Map),
    ),
    createdAt: DateTime.parse(j['created_at'] as String).toUtc(),
    updatedAt: DateTime.parse(j['client_updated_at'] as String).toUtc(),
    serverUpdatedAt: j['server_updated_at'] == null
        ? null
        : DateTime.parse(j['server_updated_at'] as String).toUtc(),
    deletedAt: j['deleted_at'] == null
        ? null
        : DateTime.parse(j['deleted_at'] as String).toUtc(),
  );
}
