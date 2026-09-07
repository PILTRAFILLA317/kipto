import 'package:kipto/features/privacy/presentation/export_sheet.dart';
import 'package:kipto/features/privacy/presentation/privacy_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/app/theme/motion_preferences.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/domain/models/item.dart';
import 'package:kipto/core/providers/repository_providers.dart';
import 'package:kipto/core/presentation/widgets/kipto_ui.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';
import 'package:kipto/l10n/app_localizations.dart';

class MatterControls extends ConsumerStatefulWidget {
  const MatterControls({super.key, required this.item});
  final Item item;
  @override
  ConsumerState<MatterControls> createState() => _MatterControlsState();
}

class _MatterControlsState extends ConsumerState<MatterControls> {
  bool _busy = false;
  Future<void> _status(ItemStatus status, {bool undo = false}) async {
    if (_busy) return;
    setState(() => _busy = true);
    final l = AppLocalizations.of(context);
    if (status != ItemStatus.active && !undo) {
      final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            status == ItemStatus.resolved ? l.resolveMatter : l.archiveMatter,
          ),
          content: Text(
            status == ItemStatus.resolved
                ? l.resolveReminderBody
                : l.archiveReminderBody,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.confirmAction),
            ),
          ],
        ),
      );
      if (accepted != true || !mounted) {
        if (mounted) setState(() => _busy = false);
        return;
      }
    }
    setState(() => _busy = true);
    final previous = widget.item.status;
    try {
      await ref
          .read(itemsRepositoryProvider)
          .setStatus(
            widget.item.id,
            status,
            cancelReminders: status == ItemStatus.archived,
          );
      if (!mounted) return;
      ref.invalidate(scheduledReminderCountProvider);
      if (ref.read(motionPreferencesProvider).haptics) {
        try {
          await HapticFeedback.lightImpact();
        } on Object {
          /* Optional feedback. */
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              if (status == ItemStatus.resolved) ...[
                KiptoSuccessMark(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(child: Text(l.savedChange)),
            ],
          ),
          action: status == ItemStatus.resolved
              ? SnackBarAction(
                  label: l.undo,
                  onPressed: () => _status(previous, undo: true),
                )
              : null,
        ),
      );
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.lifecycleFailed)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.ios_share),
          label: Text(l.exportData),
          onPressed: _busy
              ? null
              : () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => ExportSheet(itemIds: [widget.item.id]),
                ),
        ),
        TextButton.icon(
          icon: const Icon(Icons.delete_outline),
          label: Text(l.delete),
          onPressed: _busy
              ? null
              : () async {
                  setState(() => _busy = true);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialog) => AlertDialog(
                      title: Text(l.deleteMatter),
                      content: Text(l.deleteMatterBody),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialog, false),
                          child: Text(l.cancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialog, true),
                          child: Text(l.delete),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true || !mounted) {
                    if (mounted) setState(() => _busy = false);
                    return;
                  }
                  setState(() => _busy = true);
                  try {
                    await ref
                        .read(deletionServiceProvider)
                        .deleteMatter(widget.item.id);
                    if (context.mounted) Navigator.pop(context);
                  } on Object {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(l.deletePending)));
                    }
                  } finally {
                    if (mounted) setState(() => _busy = false);
                  }
                },
        ),
        TextButton.icon(
          icon: const Icon(Icons.edit_outlined),
          label: Text(l.editMatter),
          onPressed: _busy
              ? null
              : () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => MatterTextSheet(item: widget.item),
                ),
        ),
        if (widget.item.status == ItemStatus.active) ...[
          TextButton.icon(
            onPressed: _busy ? null : () => _status(ItemStatus.resolved),
            icon: const Icon(Icons.check_circle_outline),
            label: Text(l.resolveMatter),
          ),
          TextButton.icon(
            onPressed: _busy ? null : () => _status(ItemStatus.archived),
            icon: const Icon(Icons.archive_outlined),
            label: Text(l.archiveMatter),
          ),
        ] else
          TextButton.icon(
            onPressed: _busy ? null : () => _status(ItemStatus.active),
            icon: const Icon(Icons.unarchive_outlined),
            label: Text(l.reopenMatter),
          ),
      ],
    );
  }
}

class MatterTextSheet extends ConsumerStatefulWidget {
  const MatterTextSheet({super.key, required this.item});
  final Item item;
  @override
  ConsumerState<MatterTextSheet> createState() => _MatterTextSheetState();
}

class _MatterTextSheetState extends ConsumerState<MatterTextSheet> {
  late final _title = TextEditingController(text: widget.item.title),
      _summary = TextEditingController(text: widget.item.summary);
  bool _busy = false, _error = false;
  @override
  void dispose() {
    _title.dispose();
    _summary.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = false;
    });
    try {
      await ref
          .read(itemsRepositoryProvider)
          .updateText(
            widget.item.id,
            title: _title.text,
            summary: _summary.text,
          );
      if (mounted) Navigator.pop(context);
    } on Object {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.editMatter, style: Theme.of(context).textTheme.titleLarge),
            TextField(
              controller: _title,
              maxLength: 100,
              enabled: !_busy,
              decoration: InputDecoration(labelText: l.matterTitle),
            ),
            TextField(
              controller: _summary,
              maxLength: 300,
              maxLines: 4,
              enabled: !_busy,
              decoration: InputDecoration(labelText: l.matterSummary),
            ),
            if (_error) Text(l.operationFailed),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(l.confirmAction),
            ),
          ],
        ),
      ),
    );
  }
}
