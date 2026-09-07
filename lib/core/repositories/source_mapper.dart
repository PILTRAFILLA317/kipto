import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/models/source.dart';

Source sourceFromRow(SourceRow row) => Source(
  id: row.id,
  itemId: row.itemId,
  ownerId: row.ownerId,
  kind: SourceKind.values.byName(row.kind),
  origin: SourceOrigin.values.byName(row.origin),
  originalName: row.originalName,
  mimeType: row.mimeType,
  byteSize: row.byteSize,
  contentHash: row.contentHash,
  revision: row.revision,
  textContent: row.textContent,
  pageCount: row.pageCount,
  createdAt: row.createdAt,
  updatedAt: row.updatedAt,
  serverUpdatedAt: row.remoteServerUpdatedAt,
  deletedAt: row.deletedAt,
);
