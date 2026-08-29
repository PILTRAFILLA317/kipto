enum SyncReason { startup, resume, localChange, manual, realtime, retry }

enum SyncPhase { idle, syncing, offlineOrFailed }

final class SyncStatusSnapshot {
  const SyncStatusSnapshot({
    required this.phase,
    this.lastSuccessAt,
    this.lastAttemptAt,
    this.pendingCount = 0,
    this.errorMessage,
  });
  final SyncPhase phase;
  final DateTime? lastSuccessAt;
  final DateTime? lastAttemptAt;
  final int pendingCount;
  final String? errorMessage;
}
