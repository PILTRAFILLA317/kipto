import 'package:kipto/core/auth/kipto_auth_state.dart';

abstract interface class AuthRepository {
  KiptoUser? get currentUser;
  KiptoSession? get currentSession;
  Stream<KiptoAuthState> watchAuthState();
  Future<KiptoSession?> recoverSession();
  Future<KiptoSession?> ensureSession();
  Future<void> protectWithApple();
  Future<void> protectWithGoogle();
  Future<void> signInExistingWithApple();
  Future<void> signInExistingWithGoogle();
  Future<void> signOut();
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
  @override
  Future<KiptoSession?> recoverSession() async => null;
  @override
  Future<void> protectWithApple() async => throw const KiptoAuthFlowException(
    'unconfigured',
    'Cloud is not configured.',
  );
  @override
  Future<void> protectWithGoogle() async => throw const KiptoAuthFlowException(
    'unconfigured',
    'Cloud is not configured.',
  );
  @override
  Future<void> signInExistingWithApple() async =>
      throw const KiptoAuthFlowException(
        'unconfigured',
        'Cloud is not configured.',
      );
  @override
  Future<void> signInExistingWithGoogle() async =>
      throw const KiptoAuthFlowException(
        'unconfigured',
        'Cloud is not configured.',
      );
  @override
  Future<void> signOut() async {}
}
