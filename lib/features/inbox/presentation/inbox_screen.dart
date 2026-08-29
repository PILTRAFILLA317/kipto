import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/presentation/widgets/async_error_view.dart';
import 'package:kipto/core/presentation/widgets/saved_item_card.dart';
import 'package:kipto/features/inbox/domain/inbox_sections.dart';
import 'package:kipto/features/inbox/presentation/providers/inbox_providers.dart';
import 'package:kipto/features/photo_library/domain/photo_library_models.dart';
import 'package:kipto/features/photo_library/presentation/providers/photo_library_providers.dart';
import 'package:kipto/features/photo_library/presentation/widgets/screenshot_import_panel.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(inboxItemsProvider);
    final photoState = ref.watch(screenshotImportControllerProvider);
    final photoController = ref.read(
      screenshotImportControllerProvider.notifier,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kipto'),
            Text(
              'Your screenshot inbox',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: _buildBody(context, ref, items, photoState, photoController),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<SavedItem>> items,
    ScreenshotImportUiState photoState,
    ScreenshotImportController photoController,
  ) {
    if (photoState.phase == ScreenshotImportPhase.initializing) {
      return const Center(child: CircularProgressIndicator());
    }
    if (photoState.permission == PhotoAccessStatus.notDetermined) {
      return _PhotoPermissionView(
        icon: Icons.auto_awesome_outlined,
        title: 'Turn screenshots into useful actions',
        message:
            'Kipto needs access to your screenshots to organize them. '
            'Your images stay in your photo library.',
        actionLabel: 'Allow access',
        onAction: photoController.requestPermission,
      );
    }
    if (photoState.permission == PhotoAccessStatus.denied ||
        photoState.permission == PhotoAccessStatus.restricted) {
      return _PhotoPermissionView(
        icon: Icons.photo_library_outlined,
        title: 'Kipto needs access to screenshots',
        message:
            'Your screenshots stay in your photo library. Open system settings '
            'to let Kipto find and organize them.',
        actionLabel: 'Open Settings',
        onAction: photoController.openSettings,
      );
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
        onRetry: photoController.onResumed,
      );
    }
    return Column(
      children: [
        if (photoState.permission == PhotoAccessStatus.limited)
          _LimitedAccessBanner(onManage: photoController.manageLimitedAccess),
        if (photoState.phase == ScreenshotImportPhase.scanning)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: items.when(
            loading: () => const _InboxLoading(),
            error: (error, _) => AsyncErrorView(
              error: error,
              onRetry: () => ref.invalidate(inboxItemsProvider),
            ),
            data: (data) {
              if (data.isEmpty) return const _EmptyInbox();
              final sections = buildInboxSections(data, DateTime.now());
              return RefreshIndicator(
                onRefresh: () =>
                    photoController.scanForNewScreenshots(forceReconcile: true),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  itemCount: sections.length,
                  itemBuilder: (context, index) =>
                      _InboxSectionView(section: sections[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PhotoPermissionView extends StatelessWidget {
  const _PhotoPermissionView({
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
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    ),
  );
}

class _LimitedAccessBanner extends StatelessWidget {
  const _LimitedAccessBanner({required this.onManage});

  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) => MaterialBanner(
    content: const Text('Kipto only has access to selected photos.'),
    leading: const Icon(Icons.photo_library_outlined),
    actions: [
      TextButton(onPressed: onManage, child: const Text('Manage access')),
    ],
  );
}

class _InboxSectionView extends StatelessWidget {
  const _InboxSectionView({required this.section});

  final InboxSection section;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 26),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            section.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ...section.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SavedItemCard(item: item),
          ),
        ),
      ],
    ),
  );
}

class _InboxLoading extends StatelessWidget {
  const _InboxLoading();

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: 5,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (_, _) => Container(
      height: 118,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 44),
          const SizedBox(height: 14),
          Text(
            'Your inbox is clear',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text(
            'New screenshot items that need attention will appear here.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
