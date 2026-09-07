import 'package:kipto/core/presentation/widgets/kipto_ui.dart';

import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/features/capture/presentation/capture_providers.dart';
import 'package:kipto/l10n/app_localizations.dart';

import '../application/export_service.dart';

class ExportSheet extends ConsumerStatefulWidget {
  const ExportSheet({super.key, required this.itemIds});
  final List<String> itemIds;
  @override
  ConsumerState<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends ConsumerState<ExportSheet> {
  bool _busy = false, _cancelled = false;
  String? _error;
  ExportResult? _result;
  String? _resultOwner;
  bool _sharing = false;
  @override
  void dispose() {
    _cancelled = true;
    if (!_sharing) unawaited(_removeResult());
    super.dispose();
  }

  Future<void> _removeResult() async {
    final result = _result;
    _result = null;
    if (result != null) {
      try {
        await result.file.parent.delete(recursive: true);
      } on FileSystemException {
        /* Purged on next launch. */
      }
    }
  }

  Future<void> _create() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final owner = ref.read(authRepositoryProvider).userId;
    try {
      final store = await ref.read(originalStoreProvider.future);
      final result =
          await ExportService(
            ref.read(appDatabaseProvider),
            store,
            () => ref.read(authRepositoryProvider).userId,
          ).export(
            itemIds: widget.itemIds,
            destination: Directory(
              '${(await getTemporaryDirectory()).path}/kipto-exports',
            ),
            cancelled: () => _cancelled,
          );
      if (mounted && ref.read(authRepositoryProvider).userId == owner) {
        setState(() {
          _result = result;
          _resultOwner = owner;
        });
      } else if (await result.file.parent.exists()) {
        await result.file.parent.delete(recursive: true);
      }
    } on ExportCancelled {
      /* No partial artifact survives cancellation. */
    } on Object {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).operationFailed);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    ref.listen(authStateProvider, (_, next) {
      if (_result != null && next.valueOrNull?.userId != _resultOwner) {
        unawaited(_removeResult());
        setState(() => _error = l.operationFailed);
      }
    });
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.exportData,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(l.exportBody),
            if (_busy)
              Padding(
                padding: const EdgeInsets.all(20),
                child: KiptoProgress(label: l.loading),
              ),
            if (_error != null) Text(_error!),
            if (_result != null) ...[
              Text(
                _result!.missing.isEmpty
                    ? l.exportComplete
                    : l.exportMissing(_result!.missing.length),
              ),
              FilledButton(
                onPressed: _sharing
                    ? null
                    : () async {
                        if (ref.read(authRepositoryProvider).userId !=
                            _resultOwner) {
                          await _removeResult();
                          if (mounted) {
                            setState(() => _error = l.operationFailed);
                          }
                          return;
                        }
                        setState(() => _sharing = true);
                        try {
                          final box = context.findRenderObject() as RenderBox?;
                          await SharePlus.instance.share(
                            ShareParams(
                              files: [
                                XFile(
                                  _result!.file.path,
                                  mimeType: 'application/zip',
                                ),
                              ],
                              sharePositionOrigin: box == null
                                  ? null
                                  : box.localToGlobal(Offset.zero) & box.size,
                            ),
                          );
                        } on Object {
                          if (mounted) {
                            setState(() => _error = l.operationFailed);
                          }
                        } finally {
                          await _removeResult();
                          _sharing = false;
                          if (mounted) setState(() {});
                        }
                      },
                child: Text(l.saveExport),
              ),
            ] else
              FilledButton(
                onPressed: _busy ? null : _create,
                child: Text(l.exportData),
              ),
            TextButton(
              onPressed: () {
                _cancelled = true;
                Navigator.pop(context);
              },
              child: Text(_busy ? l.cancel : l.close),
            ),
          ],
        ),
      ),
    );
  }
}
