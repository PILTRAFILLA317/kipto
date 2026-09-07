import 'dart:convert';
import 'dart:io';

import 'package:kipto/core/files/original_store.dart';
import 'package:kipto/features/capture/application/capture_service.dart';

class SharedAttachment {
  const SharedAttachment({
    required this.id,
    required this.relativePath,
    required this.name,
    required this.mime,
    required this.size,
  });
  final String id, relativePath, name, mime;
  final int size;
}

class SharedManifest {
  const SharedManifest({
    required this.id,
    required this.scope,
    required this.attachments,
    this.text,
    this.title,
    this.platform,
  });
  final String id, scope;
  final List<SharedAttachment> attachments;
  final String? text, title, platform;
  factory SharedManifest.parse(String encoded) {
    if (encoded.length > 512 * 1024) throw const CaptureFailure('tooLarge');
    final json = jsonDecode(encoded) as Map<String, dynamic>;
    if (json['manifestVersion'] != 1 || json['state'] != 'ready') {
      throw const CaptureFailure('invalid');
    }
    final id = json['captureId'] as String;
    final scope = json['accountScopeId'] as String;
    final text = json['contextText'] as String?;
    final title = json['title'] as String?;
    final platform = json['platform'] as String?;
    final raw = json['attachments'] as List;
    if (!captureIdPattern.hasMatch(id) ||
        scope.isEmpty ||
        scope.length > 128 ||
        raw.length > 5 ||
        (title?.length ?? 0) > 100 ||
        (platform != null && platform != 'ios' && platform != 'android') ||
        (text?.length ?? 0) > maxTextCharacters ||
        (raw.isEmpty && (text?.trim().isEmpty ?? true))) {
      throw const CaptureFailure('invalid');
    }
    final attachments = <SharedAttachment>[];
    final seen = <String>{};
    for (final value in raw) {
      final entry = value as Map<String, dynamic>;
      final sourceId = entry['sourceId'] as String;
      final path = entry['relativePath'] as String;
      final size = entry['byteSize'] as int;
      final mime = entry['mimeType'] as String;
      final name = entry['originalName'] as String;
      final parts = path.split('/');
      if (!captureIdPattern.hasMatch(sourceId) ||
          !seen.add(sourceId) ||
          name.isEmpty ||
          name.length > 512 ||
          !{
            'image/jpeg',
            'image/png',
            'image/webp',
            'image/heic',
            'image/heif',
            'application/pdf',
          }.contains(mime) ||
          size < 1 ||
          size > maxOriginalBytes ||
          path.startsWith('/') ||
          path.contains('\\') ||
          parts.any((part) => part.isEmpty || part == '.' || part == '..') ||
          !(parts.length == 2 && parts.first == id ||
              parts.length == 3 &&
                  parts.first == 'incoming' &&
                  parts[1] == id)) {
        throw const CaptureFailure('invalid');
      }
      attachments.add(
        SharedAttachment(
          id: sourceId,
          relativePath: path,
          name: name,
          mime: mime,
          size: size,
        ),
      );
    }
    return SharedManifest(
      id: id,
      scope: scope,
      attachments: attachments,
      text: text,
      title: title,
      platform: platform,
    );
  }
}

class SharedManifestImporter {
  SharedManifestImporter(this.root, this.capture);
  final Directory root;
  final CaptureService capture;
  Future<List<String>> import(
    SharedManifest manifest, {
    required String scope,
  }) async {
    if (scope != manifest.scope || await capture.scope() != scope) {
      throw const CaptureFailure('accountChanged');
    }
    final rootPath = await root.resolveSymbolicLinks();
    // Validate the whole batch before committing its first member.
    final inputs = <File>[];
    for (final attachment in manifest.attachments) {
      final file = File('${root.path}/${attachment.relativePath}');
      if (!await file.exists()) throw const CaptureFailure('unavailable');
      final canonical = await file.resolveSymbolicLinks();
      if (!canonical.startsWith('$rootPath${Platform.pathSeparator}') ||
          await file.length() != attachment.size) {
        throw const CaptureFailure('invalid');
      }
      final handle = await file.open();
      final header = await handle.read(32);
      await handle.close();
      final detected = OriginalStore.detectMime(header);
      if (detected != attachment.mime &&
          !(detected == 'image/heic' && attachment.mime == 'image/heif')) {
        throw const CaptureFailure('invalid');
      }
      inputs.add(file);
    }
    final result = <String>[];
    for (var i = 0; i < manifest.attachments.length; i++) {
      final a = manifest.attachments[i];
      result.add(
        await capture.importFile(
          captureId: a.id,
          file: inputs[i],
          name: a.name,
          origin: 'shareSheet',
          expectedScope: scope,
          contextText: manifest.text,
          title: manifest.attachments.length == 1 ? manifest.title : null,
        ),
      );
    }
    if (manifest.attachments.isEmpty) {
      final text = manifest.text!;
      result.add(
        await capture.importText(
          captureId: manifest.id,
          text: text,
          title:
              manifest.title ??
              text
                  .trim()
                  .split('\n')
                  .first
                  .substring(
                    0,
                    text.trim().split('\n').first.length.clamp(0, 120),
                  ),
          origin: 'shareSheet',
          expectedScope: scope,
        ),
      );
    }
    // Staging is acknowledged only after every source is durably committed.
    return result;
  }
}

/// Failed entries remain recoverable and cannot hide another ready delivery.
class SharedPackage {
  const SharedPackage(this.directory, this.manifest, {this.confirmed = true});
  final bool confirmed;
  final Directory directory;
  final SharedManifest? manifest;
}

Future<List<SharedPackage>> readSharedPackages(Directory root) async {
  if (!await root.exists()) return [];
  final packages = <SharedPackage>[];
  await for (final entry in root.list(followLinks: false)) {
    if (entry is! Directory) continue;
    final id = entry.uri.pathSegments.where((part) => part.isNotEmpty).last;
    if (!captureIdPattern.hasMatch(id)) continue;
    var file = File('${entry.path}/manifest.json');
    var confirmed = true;
    try {
      if (!await file.exists()) {
        final draft = File('${entry.path}/draft.json');
        if (await draft.exists()) {
          file = draft;
          confirmed = false;
        } else {
          // A native copy may still be in progress; only report explicit failures.
          if (await File('${entry.path}/failed').exists()) {
            packages.add(SharedPackage(entry, null));
          }
          continue;
        }
      }
      if (await file.length() > 512 * 1024) {
        throw const CaptureFailure('tooLarge');
      }
      final manifest = SharedManifest.parse(await file.readAsString());
      if (manifest.id != id) throw const CaptureFailure('invalid');
      packages.add(SharedPackage(entry, manifest, confirmed: confirmed));
    } on Object {
      packages.add(SharedPackage(entry, null));
    }
  }
  packages.sort(
    (a, b) =>
        (a.manifest == null ? 1 : 0).compareTo(b.manifest == null ? 1 : 0),
  );
  return packages;
}

/// Saved iOS packages commit before sync and notification reconciliation.
/// Drafts require the same explicit confirmation as Android deliveries.
Future<int> importConfirmedSharedPackages(
  Directory root,
  CaptureService capture,
  String scope, {
  Future<void> Function(Directory, List<String>)? afterImport,
}) async {
  var failures = 0;
  for (final package in await readSharedPackages(root)) {
    final manifest = package.manifest;
    if (!package.confirmed ||
        manifest?.platform != 'ios' ||
        manifest?.scope != scope) {
      continue;
    }
    try {
      final ids = await SharedManifestImporter(
        root,
        capture,
      ).import(manifest!, scope: scope);
      await afterImport?.call(package.directory, ids);
      await package.directory.delete(recursive: true);
    } on Object {
      failures++;
    }
  }
  return failures;
}
