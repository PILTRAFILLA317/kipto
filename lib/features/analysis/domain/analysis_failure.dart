class AnalysisFailure implements Exception {
  const AnalysisFailure(this.code, {this.retryAfter});
  final String code;
  final Duration? retryAfter;
}
