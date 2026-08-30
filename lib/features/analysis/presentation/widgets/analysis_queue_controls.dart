import 'package:flutter/material.dart';
import 'package:kipto/app/theme/app_tokens.dart';
import 'package:kipto/features/analysis/domain/analysis_queue_models.dart';

final class AnalysisQueueControls extends StatelessWidget {
  const AnalysisQueueControls({
    super.key,
    required this.counts,
    required this.queue,
    required this.onAnalyze,
    required this.onPause,
    required this.onResume,
    this.compact = false,
  });

  final AnalysisItemCounts counts;
  final AnalysisQueueSnapshot queue;
  final VoidCallback onAnalyze;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (queue.remaining > 0) return _progress(context);
    if (counts.analyzableUnprocessed == 0) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_outlined),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '${counts.analyzableUnprocessed} screenshots ready to analyze',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          FilledButton.tonal(
            onPressed: onAnalyze,
            child: const Text('Analyze'),
          ),
        ],
      ),
    );
  }

  Widget _progress(BuildContext context) {
    final completed = queue.runCompleted.clamp(0, queue.runTotal);
    final hasRunTotal = queue.runTotal > 0;
    final value = hasRunTotal
        ? (completed / queue.runTotal).clamp(0.0, 1.0)
        : null;
    return Padding(
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  queue.paused ? 'Analysis paused' : 'Analyzing screenshots',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: queue.paused ? onResume : onPause,
                child: Text(queue.paused ? 'Resume' : 'Pause'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          LinearProgressIndicator(value: value),
          const SizedBox(height: AppSpacing.xs),
          Text(
            hasRunTotal
                ? '$completed / ${queue.runTotal} · ${queue.remaining} remaining'
                : '${queue.remaining} remaining',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
