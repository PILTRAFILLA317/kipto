import 'package:kipto/features/photo_library/domain/photo_library_models.dart';

final class ScreenshotImportState {
  const ScreenshotImportState({
    this.initialImportCompleted = false,
    this.lastScanAt,
    this.lastKnownScreenshotCount = 0,
    this.lastSuccessfulScanAt,
    this.importScope,
    this.scanVersion = 1,
    this.lastReconciledAt,
  });

  final bool initialImportCompleted;
  final DateTime? lastScanAt;
  final int lastKnownScreenshotCount;
  final DateTime? lastSuccessfulScanAt;
  final ScreenshotImportScope? importScope;
  final int scanVersion;
  final DateTime? lastReconciledAt;

  ScreenshotImportState copyWith({
    bool? initialImportCompleted,
    DateTime? lastScanAt,
    int? lastKnownScreenshotCount,
    DateTime? lastSuccessfulScanAt,
    ScreenshotImportScope? importScope,
    int? scanVersion,
    DateTime? lastReconciledAt,
  }) => ScreenshotImportState(
    initialImportCompleted:
        initialImportCompleted ?? this.initialImportCompleted,
    lastScanAt: lastScanAt ?? this.lastScanAt,
    lastKnownScreenshotCount:
        lastKnownScreenshotCount ?? this.lastKnownScreenshotCount,
    lastSuccessfulScanAt: lastSuccessfulScanAt ?? this.lastSuccessfulScanAt,
    importScope: importScope ?? this.importScope,
    scanVersion: scanVersion ?? this.scanVersion,
    lastReconciledAt: lastReconciledAt ?? this.lastReconciledAt,
  );
}

abstract interface class ScreenshotImportStateRepository {
  Future<ScreenshotImportState> read();
  Future<void> write(ScreenshotImportState state);
}
