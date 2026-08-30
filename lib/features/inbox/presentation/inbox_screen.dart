import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/app/theme/app_tokens.dart';
import 'package:kipto/core/domain/models/inbox_overview.dart';
import 'package:kipto/core/domain/models/library_query.dart';
import 'package:kipto/core/presentation/widgets/async_error_view.dart';
import 'package:kipto/core/presentation/widgets/content_width.dart';
import 'package:kipto/core/presentation/widgets/saved_item_card.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/core/providers/time_provider.dart';
import 'package:kipto/core/sync/sync_status.dart';
import 'package:kipto/features/inbox/presentation/providers/inbox_providers.dart';
import 'package:kipto/features/library/presentation/providers/library_providers.dart';
import 'package:kipto/features/photo_library/domain/photo_library_models.dart';
import 'package:kipto/features/photo_library/presentation/providers/photo_library_providers.dart';
import 'package:kipto/features/photo_library/presentation/widgets/screenshot_import_panel.dart';
import 'package:kipto/features/analysis/domain/analysis_queue_models.dart';
import 'package:kipto/features/analysis/presentation/providers/analysis_providers.dart';
import 'package:kipto/features/analysis/presentation/widgets/analysis_queue_controls.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(inboxOverviewProvider);
    final counts = ref.watch(libraryCountsProvider).valueOrNull;
    final photoState = ref.watch(screenshotImportControllerProvider);
    final aiPreferences = ref.watch(aiAnalysisPreferencesProvider);
    final analysisCounts = ref.watch(analysisItemCountsProvider).valueOrNull;
    final analysisQueue = ref.watch(analysisQueueStatusProvider).valueOrNull;
    final controller = ref.read(screenshotImportControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: overview.valueOrNull == null
            ? const Text('Kipto')
            : _InboxTitle(overview: overview.valueOrNull!),
      ),
      body: _body(
        context,
        ref,
        overview,
        counts,
        photoState,
        controller,
        aiEnabled: aiPreferences.enabled,
        analysisCounts: analysisCounts,
        analysisQueue: analysisQueue,
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<InboxOverview> overview,
    LibraryCounts? counts,
    ScreenshotImportUiState photoState,
    ScreenshotImportController controller, {
    required bool aiEnabled,
    AnalysisItemCounts? analysisCounts,
    AnalysisQueueSnapshot? analysisQueue,
  }) {
    if (photoState.phase == ScreenshotImportPhase.initializing) {
      return const _InboxLoading();
    }
    if (photoState.permission == PhotoAccessStatus.notDetermined) {
      return _PhotoPermissionView(onAction: controller.requestPermission);
    }
    if (photoState.permission == PhotoAccessStatus.denied ||
        photoState.permission == PhotoAccessStatus.restricted) {
      return _PermissionDeniedView(onAction: controller.openSettings);
    }
    if (!photoState.initialImportCompleted ||
        photoState.phase == ScreenshotImportPhase.ready ||
        photoState.phase == ScreenshotImportPhase.importing ||
        photoState.phase == ScreenshotImportPhase.completed) {
      return const ScreenshotImportPanel();
    }
    if (photoState.phase == ScreenshotImportPhase.error) {
      return AsyncErrorView(
        error: photoState.errorMessage ?? 'Photo library error',
        onRetry: controller.onResumed,
      );
    }
    return Column(
      children: [
        if (photoState.permission == PhotoAccessStatus.limited)
          MaterialBanner(
            content: const Text('Kipto can see selected photos only.'),
            leading: const Icon(Icons.photo_library_outlined),
            actions: [
              TextButton(
                onPressed: controller.manageLimitedAccess,
                child: const Text('Manage access'),
              ),
            ],
          ),
        if (photoState.phase == ScreenshotImportPhase.scanning)
          const LinearProgressIndicator(minHeight: 2),
        if (aiEnabled &&
            analysisCounts != null &&
            analysisQueue != null &&
            (analysisCounts.analyzableUnprocessed > 0 ||
                analysisQueue.remaining > 0))
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              0,
            ),
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: AnalysisQueueControls(
                compact: true,
                counts: analysisCounts,
                queue: analysisQueue,
                onAnalyze: () =>
                    ref.read(analysisQueueRunnerProvider).enqueueUnprocessed(),
                onPause: ref.read(analysisQueueRunnerProvider).pause,
                onResume: ref.read(analysisQueueRunnerProvider).resume,
              ),
            ),
          ),
        Expanded(
          child: overview.when(
            loading: () => const _InboxLoading(),
            error: (error, _) => AsyncErrorView(
              error: error,
              onRetry: () => ref.invalidate(inboxOverviewProvider),
            ),
            data: (data) => RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  controller.scanForNewScreenshots(forceReconcile: true),
                  ref.read(syncServiceProvider).syncNow(SyncReason.manual),
                ]);
              },
              child: data.sections.isEmpty
                  ? _EmptyInbox(hasItems: (counts?.total ?? 0) > 0)
                  : _InboxSections(overview: data),
            ),
          ),
        ),
      ],
    );
  }
}

class _InboxTitle extends StatelessWidget {
  const _InboxTitle({required this.overview});

  final InboxOverview overview;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Kipto'),
      Text(
        overview.attentionCount == 0
            ? "You're all caught up"
            : '${overview.attentionCount} need your attention',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}

class _InboxSections extends ConsumerWidget {
  const _InboxSections({required this.overview});

  final InboxOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(currentTimeProvider);
    return ContentWidth(
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppLayout.screenPadding(),
        itemCount: overview.sections.length,
        itemBuilder: (context, index) {
          final section = overview.sections[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.xxs,
                    bottom: AppSpacing.sm,
                  ),
                  child: Text(
                    section.kind.label,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ...section.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: SavedItemCard(
                      item: item,
                      now: now,
                      onPrimaryAction: item.availableActions.isEmpty
                          ? null
                          : () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'This action will be available soon',
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

extension on InboxSectionKind {
  String get label => switch (this) {
    InboxSectionKind.needsAction => 'Needs action',
    InboxSectionKind.expiringSoon => 'Expiring soon',
    InboxSectionKind.comingUp => 'Coming up',
    InboxSectionKind.readyToAnalyze => 'Ready to analyze',
    InboxSectionKind.recent => 'Recent',
  };
}

class _PhotoPermissionView extends StatelessWidget {
  const _PhotoPermissionView({required this.onAction});

  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => _CenteredState(
    icon: Icons.inbox_outlined,
    title: 'Your screenshots are unfinished actions',
    message:
        'Concert → Calendar\nRestaurant → Maps\nCoupon → Reminder\n\n'
        'Kipto needs access to screenshots to organize them.',
    actionLabel: 'Allow access to screenshots',
    onAction: onAction,
  );
}

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView({required this.onAction});

  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => _CenteredState(
    icon: Icons.photo_library_outlined,
    title: 'Photo access is off',
    message:
        'Allow screenshot access in system settings. Your existing Kipto '
        'library remains available offline.',
    actionLabel: 'Open Settings',
    onAction: onAction,
  );
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    ),
  );
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox({required this.hasItems});

  final bool hasItems;

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(AppSpacing.xl),
    children: [
      const SizedBox(height: 120),
      Icon(hasItems ? Icons.done_all : Icons.inbox_outlined, size: 44),
      const SizedBox(height: AppSpacing.sm),
      Text(
        hasItems ? "You're all caught up" : 'No screenshots yet',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: AppSpacing.xs),
      Text(
        hasItems
            ? 'Done and archived items remain available in Library.'
            : 'Take a screenshot or import your existing ones.',
        textAlign: TextAlign.center,
      ),
    ],
  );
}

class _InboxLoading extends StatelessWidget {
  const _InboxLoading();

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(AppSpacing.md),
    itemCount: 4,
    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
    itemBuilder: (_, _) => Container(
      height: 124,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
    ),
  );
}
