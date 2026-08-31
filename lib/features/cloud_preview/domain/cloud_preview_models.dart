import 'dart:typed_data';

const int cloudPreviewVersion = 1;
const String cloudPreviewBucket = 'kipto-previews';

enum CloudImageSyncMode { optimizedPreviews, metadataOnly }

enum PreviewTransferOperation { upload, delete }

enum PreviewTransferState { queued, uploading, retryScheduled, paused }

final class CloudPreview {
  const CloudPreview({
    required this.bytes,
    required this.mimeType,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final String mimeType;
  final int width;
  final int height;
}

final class CloudPreviewCounts {
  const CloudPreviewCounts({
    this.eligible = 0,
    this.uploaded = 0,
    this.waiting = 0,
    this.failed = 0,
  });

  final int eligible;
  final int uploaded;
  final int waiting;
  final int failed;
}

String deterministicCloudPreviewPath(String userId, String savedItemId) =>
    '$userId/$savedItemId/preview-v$cloudPreviewVersion.jpg';
