import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:kipto/core/files/original_store.dart';
import 'package:kipto/core/presentation/widgets/kipto_ui.dart';
import 'package:kipto/features/capture/presentation/capture_providers.dart';
import 'package:kipto/l10n/app_localizations.dart';

Future<void> showAddSheet(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
      ? AnimationStyle.noAnimation
      : const AnimationStyle(
          duration: Duration(milliseconds: 320),
          reverseDuration: Duration(milliseconds: 240),
        ),
  builder: (_) => const AddSheet(),
);

String captureErrorMessage(AppLocalizations l, Object error) =>
    switch (error is CaptureFailure ? error.code : '') {
      'tooLarge' => l.captureTooLarge,
      'unsupported' => l.captureUnsupported,
      'unreadable' => l.captureUnreadable,
      'accountChanged' => l.captureAccountChanged,
      'unavailable' => l.sourceUnavailable,
      _ => l.captureFailed,
    };

class AddSheet extends ConsumerStatefulWidget {
  const AddSheet({super.key});
  @override
  ConsumerState<AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends ConsumerState<AddSheet> {
  bool _busy = false;
  bool _writing = false;
  String? _error;
  final _title = TextEditingController();
  final _text = TextEditingController();
  @override
  void dispose() {
    _title.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _run(Future<String?> Function() operation) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final router = GoRouter.of(context);
    try {
      final id = await operation();
      if (!mounted) return;
      if (id != null) {
        Navigator.pop(context);
        router.push('/items/$id');
      }
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

  Future<void> _pick(bool image) => _run(() async {
    final id = const Uuid().v4();
    final before = await ref.read(captureScopeProvider)();
    final prefs = await SharedPreferences.getInstance();
    if (image) {
      await prefs.setString('capture.pendingPicker', id);
      await prefs.setString('capture.pendingPickerScope', before);
    }
    final file = image
        ? await ImagePicker().pickImage(
            source: ImageSource.gallery,
            requestFullMetadata: false,
          )
        : await openFile(
            acceptedTypeGroups: [
              const XTypeGroup(
                label: 'PDF',
                extensions: ['pdf'],
                mimeTypes: ['application/pdf'],
                uniformTypeIdentifiers: ['com.adobe.pdf'],
              ),
            ],
          );
    if (before != await ref.read(captureScopeProvider)()) {
      throw const CaptureFailure('accountChanged');
    }
    if (file == null) {
      if (image) await prefs.remove('capture.pendingPicker');
      return null;
    }
    final service = await ref.read(captureServiceProvider.future);
    final item = await service.importFile(
      captureId: id,
      file: File(file.path),
      name: file.name,
    );
    if (image) await prefs.remove('capture.pendingPicker');
    return item;
  });
  Future<void> _saveText() => _run(() async {
    if (_title.text.trim().isEmpty || _text.text.trim().isEmpty) {
      setState(() => _error = AppLocalizations.of(context).fieldRequired);
      return null;
    }
    return (await ref.read(captureServiceProvider.future)).importText(
      captureId: const Uuid().v4(),
      text: _text.text,
      title: _title.text,
    );
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopScope(
      canPop: !_busy,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            0,
            24,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _writing ? l.writeOrPaste : l.add,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: l.close,
                    onPressed: _busy ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_writing) ...[
                TextField(
                  controller: _title,
                  maxLength: 160,
                  enabled: !_busy,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(labelText: l.title),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _text,
                  minLines: 4,
                  maxLines: 8,
                  maxLength: maxTextCharacters,
                  enabled: !_busy,
                  decoration: InputDecoration(
                    labelText: l.note,
                    hintText: l.sourceTextHint,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy ? null : _saveText,
                    child: Text(_busy ? l.saving : l.save),
                  ),
                ),
              ] else ...[
                KiptoActionRow(
                  icon: Icons.image_outlined,
                  title: l.image,
                  onTap: _busy ? null : () => _pick(true),
                ),
                const SizedBox(height: 12),
                KiptoActionRow(
                  icon: Icons.description_outlined,
                  title: l.document,
                  onTap: _busy ? null : () => _pick(false),
                ),
                const SizedBox(height: 12),
                KiptoActionRow(
                  icon: Icons.edit_outlined,
                  title: l.writeOrPaste,
                  onTap: _busy ? null : () => setState(() => _writing = true),
                ),
                const SizedBox(height: 20),
                Text(
                  l.shareHint,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (_busy) ...[
                const SizedBox(height: 16),
                KiptoProgress(label: l.saving, linear: true),
                const SizedBox(height: 8),
                Text(l.saving),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
