import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:kipto/core/config/app_config.dart';
import 'package:kipto/core/files/original_store.dart';

class FileTransferFailure implements Exception {
  const FileTransferFailure(this.code);
  final String code;
}

/// No redirects or signed URLs persisted. Streams are bounded in both directions.
Future<void> transferOriginal({
  required AppConfig config,
  required String token,
  required String sourceId,
  required int revision,
  required String operation,
  required File file,
  required void Function(int) progress,
}) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  try {
    await (() async {
      final uri = Uri.parse(
        '${config.supabaseUrl}/functions/v1/source-backup',
      ).replace(queryParameters: {'source': sourceId, 'revision': '$revision'});
      final request = await client.openUrl(
        operation == 'upload'
            ? 'PUT'
            : operation == 'delete'
            ? 'DELETE'
            : 'GET',
        uri,
      );
      request.followRedirects = false;
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('apikey', config.supabasePublishableKey);
      if (operation == 'upload') {
        final length = await file.length();
        if (length > maxOriginalBytes) {
          throw const FileTransferFailure('tooLarge');
        }
        request.contentLength = length;
        request.headers.contentType = ContentType.binary;
        var sent = 0;
        await request.addStream(
          file.openRead().map((chunk) {
            sent += chunk.length;
            progress(sent);
            return chunk;
          }),
        );
      }
      final response = await request.close();
      if (response.statusCode != 200) {
        final bytes = <int>[];
        await for (final chunk in response) {
          if (bytes.length + chunk.length > 4096) break;
          bytes.addAll(chunk);
        }
        String? code;
        try {
          code = (jsonDecode(utf8.decode(bytes)) as Map)['error'] as String?;
        } on Object {
          /* controlled failure */
        }
        const known = {
          'proRequired',
          'storageQuota',
          'sourceUnavailable',
          'sourceChanged',
          'contentMismatch',
          'unauthorized',
          'deletionPending',
        };
        throw FileTransferFailure(
          known.contains(code)
              ? code!
              : response.statusCode == 404
              ? 'unavailable'
              : 'network',
        );
      }
      if (operation == 'download') {
        final output = await file.open(mode: FileMode.write);
        var received = 0;
        try {
          await for (final chunk in response) {
            received += chunk.length;
            if (received > maxOriginalBytes) {
              throw const FileTransferFailure('tooLarge');
            }
            await output.writeFrom(chunk);
            progress(received);
          }
          await output.flush();
        } finally {
          await output.close();
        }
      } else {
        await response.drain<void>();
      }
    })().timeout(const Duration(seconds: 90));
  } on FileTransferFailure {
    rethrow;
  } on Object {
    throw const FileTransferFailure('network');
  } finally {
    client.close(force: true);
  }
}
