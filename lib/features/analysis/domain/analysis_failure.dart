enum AnalysisErrorCode {
  invalidRequest,
  invalidImage,
  noLocalAsset,
  imagePreparationFailed,
  payloadTooLarge,
  unauthorized,
  quotaExceeded,
  rateLimited,
  network,
  upstreamTimeout,
  invalidResponse,
  refused,
  serverError,
  notConfigured,
  unknown,
}

final class AnalysisFailure implements Exception {
  const AnalysisFailure({
    required this.code,
    required this.retryable,
    this.retryAfter,
  });

  final AnalysisErrorCode code;
  final bool retryable;
  final Duration? retryAfter;

  @override
  String toString() => 'AnalysisFailure(${code.name}, retryable: $retryable)';
}

extension AnalysisErrorCodeStorage on AnalysisErrorCode {
  String get wireValue => switch (this) {
    AnalysisErrorCode.invalidRequest => 'invalid_request',
    AnalysisErrorCode.invalidImage => 'invalid_image',
    AnalysisErrorCode.noLocalAsset => 'no_local_asset',
    AnalysisErrorCode.imagePreparationFailed => 'image_preparation_failed',
    AnalysisErrorCode.payloadTooLarge => 'payload_too_large',
    AnalysisErrorCode.unauthorized => 'unauthorized',
    AnalysisErrorCode.quotaExceeded => 'quota_exceeded',
    AnalysisErrorCode.rateLimited => 'rate_limited',
    AnalysisErrorCode.network => 'network',
    AnalysisErrorCode.upstreamTimeout => 'upstream_timeout',
    AnalysisErrorCode.invalidResponse => 'invalid_response',
    AnalysisErrorCode.refused => 'refused',
    AnalysisErrorCode.serverError => 'server_error',
    AnalysisErrorCode.notConfigured => 'not_configured',
    AnalysisErrorCode.unknown => 'unknown',
  };

  static AnalysisErrorCode fromWire(Object? value) {
    if (value is! String) return AnalysisErrorCode.unknown;
    return AnalysisErrorCode.values.firstWhere(
      (code) => code.wireValue == value,
      orElse: () => AnalysisErrorCode.unknown,
    );
  }
}
