enum ActionExecutionStatus {
  success,
  launched,
  cancelled,
  unavailable,
  invalidData,
  permissionDenied,
  failed,
}

final class ActionExecutionResult {
  const ActionExecutionResult._(this.status, {this.message, this.errorCode});

  const ActionExecutionResult.success([String? message])
    : this._(ActionExecutionStatus.success, message: message);

  const ActionExecutionResult.launched([String? message])
    : this._(ActionExecutionStatus.launched, message: message);

  const ActionExecutionResult.cancelled([String? message])
    : this._(ActionExecutionStatus.cancelled, message: message);

  const ActionExecutionResult.unavailable([String? message])
    : this._(ActionExecutionStatus.unavailable, message: message);

  const ActionExecutionResult.invalidData([String? message])
    : this._(ActionExecutionStatus.invalidData, message: message);

  const ActionExecutionResult.permissionDenied([String? message])
    : this._(ActionExecutionStatus.permissionDenied, message: message);

  const ActionExecutionResult.failed({String? message, String? errorCode})
    : this._(
        ActionExecutionStatus.failed,
        message: message,
        errorCode: errorCode,
      );

  final ActionExecutionStatus status;
  final String? message;
  final String? errorCode;

  bool get isSuccess => status == ActionExecutionStatus.success;
}
