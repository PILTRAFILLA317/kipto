import 'package:flutter/material.dart';
import 'package:kipto/app/theme/app_tokens.dart';
import 'package:kipto/core/presentation/widgets/kipto_ui.dart';
import 'package:kipto/features/actions/application/action_service.dart';
import 'package:kipto/l10n/app_localizations.dart';

String actionOutcomeText(AppLocalizations l, ActionOutcome outcome) =>
    switch (outcome) {
      ActionOutcome.scheduled => l.reminderScheduled,
      ActionOutcome.savedNotScheduled => l.reminderNotScheduled,
      ActionOutcome.kept => l.keptResult,
      ActionOutcome.calendarSaved => l.calendarSaved,
      ActionOutcome.calendarOpened => l.calendarOpened,
      ActionOutcome.cancelled => l.calendarCancelled,
      ActionOutcome.permissionDenied => l.calendarPermissionDenied,
      ActionOutcome.unavailable => l.calendarUnavailable,
      _ => l.lifecycleFailed,
    };

/// Only outcomes confirmed by the corresponding adapter receive a success mark.
class ActionFeedback extends StatelessWidget {
  const ActionFeedback({super.key, required this.outcome});
  final ActionOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final confirmed = const {
      ActionOutcome.scheduled,
      ActionOutcome.kept,
      ActionOutcome.calendarSaved,
    }.contains(outcome);
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (confirmed)
            KiptoSuccessMark(key: ValueKey(outcome))
          else
            ExcludeSemantics(
              child: TweenAnimationBuilder<double>(
                key: ValueKey(outcome),
                tween: Tween(begin: reduced ? 1 : 0, end: 1),
                duration: reduced ? Duration.zero : AppDurations.normal,
                curve: Curves.easeOutCubic,
                builder: (context, progress, child) => Opacity(
                  opacity: progress,
                  child: Transform.scale(
                    scale: reduced ? 1 : .85 + .15 * progress,
                    child: child,
                  ),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              actionOutcomeText(AppLocalizations.of(context), outcome),
            ),
          ),
        ],
      ),
    );
  }
}
