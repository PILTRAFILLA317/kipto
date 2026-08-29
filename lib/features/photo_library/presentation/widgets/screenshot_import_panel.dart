import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/features/photo_library/domain/photo_library_models.dart';
import 'package:kipto/features/photo_library/presentation/providers/photo_library_providers.dart';

class ScreenshotImportPanel extends ConsumerWidget {
  const ScreenshotImportPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(screenshotImportControllerProvider);
    final controller = ref.read(screenshotImportControllerProvider.notifier);

    if (state.phase == ScreenshotImportPhase.importing) {
      final progress = state.progress;
      return _PanelCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Importing screenshots',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: progress.fraction),
            const SizedBox(height: 10),
            Text('${progress.processed} / ${progress.total}'),
            const SizedBox(height: 6),
            Text(
              '${progress.imported} new · ${progress.skipped} already in Kipto'
              '${progress.failed == 0 ? '' : ' · ${progress.failed} failed'}',
            ),
          ],
        ),
      );
    }

    if (state.phase == ScreenshotImportPhase.completed) {
      return _PanelCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 34,
            ),
            const SizedBox(height: 12),
            Text(
              '${state.progress.imported} screenshots imported',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text('${state.progress.skipped} already in Kipto'),
            if (state.progress.failed > 0)
              Text('${state.progress.failed} could not be imported'),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: controller.finishImport,
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    }

    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'We found ${state.availableCount} screenshots',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Choose how much screenshot history to import.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          RadioGroup<ScreenshotImportScope>(
            groupValue: state.scope,
            onChanged: (scope) {
              if (scope != null) controller.selectScope(scope);
            },
            child: const Column(
              children: [
                RadioListTile<ScreenshotImportScope>(
                  value: ScreenshotImportScope.recent100,
                  title: Text('Recent 100'),
                  subtitle: Text('The most recent accessible screenshots'),
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<ScreenshotImportScope>(
                  value: ScreenshotImportScope.last30Days,
                  title: Text('Last 30 days'),
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<ScreenshotImportScope>(
                  value: ScreenshotImportScope.all,
                  title: Text('All screenshots'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: state.availableCount == 0
                ? null
                : controller.importSelected,
            icon: const Icon(Icons.download_outlined),
            label: const Text('Import screenshots'),
          ),
        ],
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Card(
          child: Padding(padding: const EdgeInsets.all(22), child: child),
        ),
      ),
    ),
  );
}
