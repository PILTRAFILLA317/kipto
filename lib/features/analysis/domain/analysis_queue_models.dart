import 'package:kipto/features/analysis/domain/analysis_failure.dart';

enum AnalysisQueueState { queued, processing, retryScheduled, paused }

final class AnalysisQueueEntry {
  const AnalysisQueueEntry({
    required this.savedItemId,
    required this.state,
    required this.priority,
    required this.attemptCount,
    required this.enqueuedAt,
    this.nextAttemptAt,
    this.startedAt,
    this.lastErrorCode,
  });

  final String savedItemId;
  final AnalysisQueueState state;
  final int priority;
  final int attemptCount;
  final DateTime? nextAttemptAt;
  final DateTime enqueuedAt;
  final DateTime? startedAt;
  final AnalysisErrorCode? lastErrorCode;
}

final class AnalysisQueueSnapshot {
  const AnalysisQueueSnapshot({
    this.queued = 0,
    this.processing = 0,
    this.retryScheduled = 0,
    this.paused = false,
    this.runCompleted = 0,
    this.runTotal = 0,
    this.lastLatency,
    this.lastErrorCode,
  });

  final int queued;
  final int processing;
  final int retryScheduled;
  final bool paused;
  final int runCompleted;
  final int runTotal;
  final Duration? lastLatency;
  final AnalysisErrorCode? lastErrorCode;

  int get remaining => queued + processing + retryScheduled;
  bool get isRunning => !paused && remaining > 0;
}

final class AnalysisItemCounts {
  const AnalysisItemCounts({
    required this.unprocessed,
    required this.analyzableUnprocessed,
    required this.processing,
    required this.processed,
    required this.needsReview,
    required this.failed,
  });

  final int unprocessed;
  final int analyzableUnprocessed;
  final int processing;
  final int processed;
  final int needsReview;
  final int failed;
}
