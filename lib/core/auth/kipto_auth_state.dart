enum KiptoAuthStatus {
  unconfigured,
  initializing,
  anonymous,
  permanent,
  signedOut,
  error,
}

final class KiptoAuthState {
  const KiptoAuthState(this.status, {this.userId, this.message});

  final KiptoAuthStatus status;
  final String? userId;
  final String? message;

  bool get isAuthenticated =>
      status == KiptoAuthStatus.anonymous ||
      status == KiptoAuthStatus.permanent;
}

final class KiptoUser {
  const KiptoUser({required this.id, required this.isAnonymous});
  final String id;
  final bool isAnonymous;
}

final class KiptoSession {
  const KiptoSession({required this.user, required this.isExpired});
  final KiptoUser user;
  final bool isExpired;
}
