import 'dart:convert';

import 'package:kipto/features/analysis/presentation/analysis_providers.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kipto/features/capture/application/shared_manifest.dart';
import 'package:kipto/features/capture/presentation/capture_providers.dart';
import 'package:kipto/features/capture/presentation/add_sheet.dart';
import 'package:kipto/core/presentation/widgets/kipto_ui.dart';
import 'package:kipto/l10n/app_localizations.dart';

final captureRecoveryFailuresProvider = StateProvider<int>((ref) => 0);

const captureChannel = MethodChannel('app.kipto/capture');

Future<void> importSharedAnalysis(
  Ref ref,
  Directory directory,
  List<String> ids,
) async {
  final payload = File('${directory.path}/analysis-request.json');
  if (!await payload.exists()) return;
  final root = await directory.resolveSymbolicLinks();
  if (!(await payload.resolveSymbolicLinks()).startsWith(
        '$root${Platform.pathSeparator}',
      ) ||
      await payload.length() > 8 * 1024 * 1024) {
    throw StateError('Invalid analysis package');
  }
  final text = await payload.readAsString();
  if (!ids.contains((jsonDecode(text) as Map)['sourceId'])) {
    throw StateError('Analysis source mismatch');
  }
  final file = File('${directory.path}/analysis-envelope.json');
  Map<String, dynamic>? envelope;
  if (await file.exists()) {
    if (!(await file.resolveSymbolicLinks()).startsWith(
          '$root${Platform.pathSeparator}',
        ) ||
        await file.length() > 262144) {
      throw StateError('Invalid analysis package');
    }
    envelope = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  }
  await ref.read(analysisQueueProvider).importSharedResult(text, envelope);
}

final importSharedAnalysisProvider = Provider(
  (ref) =>
      (Directory directory, List<String> ids) =>
          importSharedAnalysis(ref, directory, ids),
);

class PendingSharedCapture {
  const PendingSharedCapture(this.file, this.manifest, this.root);
  final File file;
  final Directory root;
  final SharedManifest? manifest;
}

final pendingSharedCapturesProvider = FutureProvider<List<PendingSharedCapture>>((
  ref,
) async {
  String? path;
  try {
    path = await captureChannel.invokeMethod<String>('incomingDirectory');
  } on MissingPluginException {
    return [];
  }
  if (path == null) return [];
  final root = Directory(path);
  if (!await root.exists()) return [];
  final scope = await ref.watch(captureScopeProvider)();
  return [
    for (final package in await readSharedPackages(root))
      if (package.manifest == null || package.manifest!.scope == scope)
        PendingSharedCapture(
          File(
            '${package.directory.path}/${package.confirmed ? 'manifest' : 'draft'}.json',
          ),
          package.manifest,
          root,
        ),
  ];
});

class SharedIntakeBanner extends ConsumerStatefulWidget {
  const SharedIntakeBanner({super.key});
  @override
  ConsumerState<SharedIntakeBanner> createState() => _SharedIntakeBannerState();
}

class _SharedIntakeBannerState extends ConsumerState<SharedIntakeBanner> {
  bool _busy = false;
  String? _error;
  Future<void> _accept(PendingSharedCapture pending) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final service = await ref.read(captureServiceProvider.future);
      final scope = await ref.read(captureScopeProvider)();
      final ids = await SharedManifestImporter(
        pending.root,
        service,
      ).import(pending.manifest!, scope: scope);
      await ref.read(importSharedAnalysisProvider)(pending.file.parent, ids);
      // Keep originals already copied into the app; remove only consumed staging.
      await pending.file.parent.delete(recursive: true);
      ref.invalidate(pendingSharedCapturesProvider);
      if (mounted && Platform.isAndroid) {
        final l = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                KiptoSuccessMark(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(l.localSaved)),
              ],
            ),
            action: SnackBarAction(
              label: l.returnToSource,
              onPressed: () async {
                try {
                  await captureChannel.invokeMethod<void>('returnToSource');
                } on PlatformException {
                  /* The original app is no longer available. */
                }
              },
            ),
          ),
        );
      }
      if (mounted && ids.length == 1) context.push('/items/${ids.single}');
    } on Object catch (error) {
      if (mounted) {
        setState(
          () =>
              _error = captureErrorMessage(AppLocalizations.of(context), error),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _discard(PendingSharedCapture pending) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.discardCapture),
        content: Text(l.discardCaptureBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await pending.file.parent.delete(recursive: true);
      ref.invalidate(pendingSharedCapturesProvider);
    } on Object {
      if (mounted) setState(() => _error = l.operationFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final recoveryFailed = ref.watch(captureRecoveryFailuresProvider) > 0;
    return ref
        .watch(pendingSharedCapturesProvider)
        .when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => Padding(
            padding: const EdgeInsets.all(20),
            child: Text(l.recoveryFailed),
          ),
          data: (pending) {
            if (pending.isEmpty) {
              return recoveryFailed
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(l.recoveryFailed),
                    )
                  : const SizedBox.shrink();
            }
            final first = pending.first;
            final manifest = first.manifest;
            final count = manifest == null || manifest.attachments.isEmpty
                ? 1
                : manifest.attachments.length;
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * .4,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        manifest == null
                            ? l.recoveryFailed
                            : l.sharedReady(count),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (manifest != null) Text(l.sharedAsMatters(count)),
                      const SizedBox(height: 12),
                      if (_error != null)
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      if (manifest != null)
                        FilledButton(
                          onPressed: _busy ? null : () => _accept(first),
                          child: Text(_busy ? l.saving : l.save),
                        ),
                      TextButton(
                        onPressed: _busy ? null : () => _discard(first),
                        child: Text(l.discardCapture),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
  }
}
