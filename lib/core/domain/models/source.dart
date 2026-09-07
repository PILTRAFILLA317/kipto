enum SourceKind { image, pdf, text, url }

enum SourceOrigin { systemPicker, shareSheet, manual }

final class Source {
  const Source({
    required this.id,
    required this.itemId,
    this.ownerId,
    required this.kind,
    required this.origin,
    required this.originalName,
    required this.mimeType,
    required this.byteSize,
    required this.contentHash,
    this.revision = 1,
    this.textContent,
    this.pageCount,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
    this.deletedAt,
  });
  final String id;
  final String itemId;
  final String? ownerId;
  final SourceKind kind;
  final SourceOrigin origin;
  final String originalName;
  final String mimeType;
  final int byteSize;
  final String contentHash;
  final int revision;
  final String? textContent;
  final int? pageCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? serverUpdatedAt;
  final DateTime? deletedAt;
  factory Source.fromJson(Map<String, dynamic> json) => Source(
    id: json['id'] as String,
    itemId: json['item_id'] as String,
    ownerId: json['user_id'] as String?,
    kind: SourceKind.values.byName(json['kind'] as String),
    origin: SourceOrigin.values.byName(json['origin'] as String),
    originalName: json['original_name'] as String,
    mimeType: json['mime_type'] as String,
    byteSize: json['byte_size'] as int,
    contentHash: json['content_hash'] as String,
    revision: json['revision'] as int,
    textContent: json['text_content'] as String?,
    pageCount: json['page_count'] as int?,
    createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
    updatedAt: DateTime.parse(json['client_updated_at'] as String).toUtc(),
    serverUpdatedAt: DateTime.tryParse(
      json['server_updated_at'] as String? ?? '',
    ),
    deletedAt: DateTime.tryParse(json['deleted_at'] as String? ?? ''),
  );
  Map<String, Object?> toJson() => {
    'id': id,
    'item_id': itemId,
    'user_id': ownerId,
    'kind': kind.name,
    'origin': origin.name,
    'original_name': originalName,
    'mime_type': mimeType,
    'byte_size': byteSize,
    'content_hash': contentHash,
    'revision': revision,
    'text_content': textContent,
    'page_count': pageCount,
    'created_at': createdAt.toUtc().toIso8601String(),
    'client_updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
  };
}
