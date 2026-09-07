import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/domain/models/item.dart';
import 'package:kipto/core/providers/repository_providers.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';
import 'package:kipto/l10n/app_localizations.dart';

/// A swipe asks for the same explicit transition as the detail controls.
/// Removal belongs to the repository stream, so dismissal itself returns false.
class MatterSwipe extends ConsumerWidget {
  const MatterSwipe({super.key, required this.item, required this.child});
  final Item item;
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Dismissible(
      key: ValueKey('swipe-${item.id}'),
      background: Container(
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsets.all(20),
        child: Text(l.resolveMatter),
      ),
      secondaryBackground: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.all(20),
        child: Text(l.archiveMatter),
      ),
      confirmDismiss: (direction) async {
        final archive = direction == DismissDirection.endToStart;
        final accepted = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(archive ? l.archiveMatter : l.resolveMatter),
            content: Text(
              archive ? l.archiveReminderBody : l.resolveReminderBody,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  MaterialLocalizations.of(context).cancelButtonLabel,
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.confirmAction),
              ),
            ],
          ),
        );
        if (accepted != true || !context.mounted) return false;
        final messenger = ScaffoldMessenger.of(context);
        final repository = ref.read(itemsRepositoryProvider);
        try {
          await repository.setStatus(
            item.id,
            archive ? ItemStatus.archived : ItemStatus.resolved,
            cancelReminders: archive,
          );
          if (context.mounted) ref.invalidate(scheduledReminderCountProvider);
          if (messenger.mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(l.savedChange),
                action: archive
                    ? null
                    : SnackBarAction(
                        label: l.undo,
                        onPressed: () async {
                          try {
                            await repository.setStatus(
                              item.id,
                              ItemStatus.active,
                            );
                          } on Object {
                            if (messenger.mounted) {
                              messenger.showSnackBar(
                                SnackBar(content: Text(l.lifecycleFailed)),
                              );
                            }
                          }
                        },
                      ),
              ),
            );
          }
        } on Object {
          if (messenger.mounted) {
            messenger.showSnackBar(SnackBar(content: Text(l.lifecycleFailed)));
          }
        }
        return false;
      },
      child: child,
    );
  }
}
