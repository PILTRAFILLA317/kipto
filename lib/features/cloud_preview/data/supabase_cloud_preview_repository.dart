import 'dart:typed_data';

import 'package:kipto/features/cloud_preview/domain/cloud_preview_models.dart';
import 'package:kipto/features/cloud_preview/domain/cloud_preview_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class SupabaseCloudPreviewRepository implements CloudPreviewRepository {
  SupabaseCloudPreviewRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> upload({
    required String path,
    required CloudPreview preview,
  }) async {
    await _client.storage
        .from(cloudPreviewBucket)
        .uploadBinary(
          path,
          preview.bytes,
          fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: true,
            contentType: preview.mimeType,
          ),
        );
  }

  @override
  Future<Uint8List> download(String path) =>
      _client.storage.from(cloudPreviewBucket).download(path);

  @override
  Future<void> delete(Iterable<String> paths) async {
    final values = paths.toList(growable: false);
    for (var offset = 0; offset < values.length; offset += 100) {
      await _client.storage
          .from(cloudPreviewBucket)
          .remove(
            values.sublist(offset, (offset + 100).clamp(0, values.length)),
          );
    }
  }

  @override
  Future<bool> exists(String path) async {
    final slash = path.lastIndexOf('/');
    final directory = slash < 0 ? '' : path.substring(0, slash);
    final filename = slash < 0 ? path : path.substring(slash + 1);
    final files = await _client.storage
        .from(cloudPreviewBucket)
        .list(
          path: directory,
          searchOptions: SearchOptions(limit: 2, search: filename),
        );
    return files.any((file) => file.name == filename);
  }
}
