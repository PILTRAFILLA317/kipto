import 'dart:typed_data';

enum PhotoAccessStatus {
  notDetermined,
  authorized,
  limited,
  denied,
  restricted;

  bool get hasAccess =>
      this == PhotoAccessStatus.authorized || this == PhotoAccessStatus.limited;
}

enum ScreenshotImportScope { recent100, last30Days, all }

enum ScreenshotImportPhase {
  initializing,
  idle,
  scanning,
  ready,
  importing,
  completed,
  error,
}

final class LocalScreenshotAsset {
  const LocalScreenshotAsset({
    required this.id,
    required this.capturedAt,
    required this.width,
    required this.height,
    this.title,
  });

  final String id;
  final DateTime capturedAt;
  final int width;
  final int height;
  final String? title;
}

final class LocalAssetThumbnailData {
  const LocalAssetThumbnailData({
    required this.bytes,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final int width;
  final int height;
}

final class ScreenshotImportPlan {
  const ScreenshotImportPlan({required this.scope, required this.total});

  final ScreenshotImportScope scope;
  final int total;
}

final class ScreenshotImportProgress {
  const ScreenshotImportProgress({
    required this.total,
    this.processed = 0,
    this.imported = 0,
    this.skipped = 0,
    this.failed = 0,
  });

  final int total;
  final int processed;
  final int imported;
  final int skipped;
  final int failed;

  double? get fraction => total == 0 ? null : processed / total;

  ScreenshotImportProgress copyWith({
    int? total,
    int? processed,
    int? imported,
    int? skipped,
    int? failed,
  }) => ScreenshotImportProgress(
    total: total ?? this.total,
    processed: processed ?? this.processed,
    imported: imported ?? this.imported,
    skipped: skipped ?? this.skipped,
    failed: failed ?? this.failed,
  );
}

final class ScreenshotImportUiState {
  const ScreenshotImportUiState({
    this.phase = ScreenshotImportPhase.initializing,
    this.permission = PhotoAccessStatus.notDetermined,
    this.scope = ScreenshotImportScope.recent100,
    this.availableCount = 0,
    this.importedCount = 0,
    this.initialImportCompleted = false,
    this.progress = const ScreenshotImportProgress(total: 0),
    this.errorMessage,
  });

  final ScreenshotImportPhase phase;
  final PhotoAccessStatus permission;
  final ScreenshotImportScope scope;
  final int availableCount;
  final int importedCount;
  final bool initialImportCompleted;
  final ScreenshotImportProgress progress;
  final String? errorMessage;

  ScreenshotImportUiState copyWith({
    ScreenshotImportPhase? phase,
    PhotoAccessStatus? permission,
    ScreenshotImportScope? scope,
    int? availableCount,
    int? importedCount,
    bool? initialImportCompleted,
    ScreenshotImportProgress? progress,
    String? errorMessage,
    bool clearError = false,
  }) => ScreenshotImportUiState(
    phase: phase ?? this.phase,
    permission: permission ?? this.permission,
    scope: scope ?? this.scope,
    availableCount: availableCount ?? this.availableCount,
    importedCount: importedCount ?? this.importedCount,
    initialImportCompleted:
        initialImportCompleted ?? this.initialImportCompleted,
    progress: progress ?? this.progress,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
