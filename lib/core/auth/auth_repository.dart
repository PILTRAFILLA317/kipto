import 'package:kipto/core/auth/kipto_auth_state.dart';

abstract interface class AuthRepository {
  KiptoUser? get currentUser;
  KiptoSession? get currentSession;
  Stream<KiptoAuthState> watchAuthState();
  Future<KiptoSession?> ensureSession();
  bool get isAnonymous;
  String? get userId;
}

final class UnconfiguredAuthRepository implements AuthRepository {
  const UnconfiguredAuthRepository();

  @override
  KiptoUser? get currentUser => null;
  @override
  KiptoSession? get currentSession => null;
  @override
  bool get isAnonymous => false;
  @override
  String? get userId => null;
  @override
  Stream<KiptoAuthState> watchAuthState() =>
      Stream.value(const KiptoAuthState(KiptoAuthStatus.unconfigured));
  @override
  Future<KiptoSession?> ensureSession() async => null;
}
