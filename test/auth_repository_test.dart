import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/auth/kipto_auth_state.dart';
import 'package:kipto/core/auth/supabase_auth_repository.dart';

void main() {
  const anonymous = KiptoUser(id: 'anonymous-user', isAnonymous: true);

  test(
    'recovery does not replace an existing identity without a session',
    () async {
      final gateway = _Gateway(user: anonymous);
      final repository = SupabaseAuthRepository.withGateway(gateway);
      scheduleMicrotask(
        () => gateway.events.add(
          const AuthGatewayState(AuthGatewayEvent.initial, null),
        ),
      );

      await expectLater(repository.ensureSession(), throwsStateError);
      expect(gateway.anonymousSignIns, 0);
    },
  );

  test('protecting an anonymous library retains its Supabase UUID', () async {
    final gateway = _Gateway(
      session: const KiptoSession(user: anonymous, isExpired: false),
    );
    final repository = SupabaseAuthRepository.withGateway(gateway);

    await repository.protectWithGoogle();

    expect(repository.userId, anonymous.id);
    expect(gateway.redirectUrl, endsWith('?flow=protect'));
  });

  test('restore uses the explicit restore callback flow', () async {
    final gateway = _Gateway();
    final repository = SupabaseAuthRepository.withGateway(gateway);

    await repository.signInExistingWithApple();

    expect(gateway.redirectUrl, endsWith('?flow=restore'));
  });
}

final class _Gateway implements AuthGateway {
  _Gateway({KiptoSession? session, KiptoUser? user})
    : _session = session,
      _user = user ?? session?.user;

  KiptoSession? _session;
  KiptoUser? _user;
  final events = StreamController<AuthGatewayState>.broadcast();
  var anonymousSignIns = 0;
  String? redirectUrl;

  @override
  KiptoSession? get currentSession => _session;
  @override
  KiptoUser? get currentUser => _user;
  @override
  Stream<AuthGatewayState> get onAuthStateChange => events.stream;
  @override
  Future<KiptoSession?> refreshSession() async => _session;
  @override
  Future<KiptoSession?> signInAnonymously() async {
    anonymousSignIns++;
    _user = const KiptoUser(id: 'new-anonymous-user', isAnonymous: true);
    return _session = KiptoSession(user: _user!, isExpired: false);
  }

  @override
  Future<bool> linkIdentity(
    KiptoIdentityProvider provider,
    String redirect,
  ) async {
    redirectUrl = redirect;
    return true;
  }

  @override
  Future<bool> signInWithOAuth(
    KiptoIdentityProvider provider,
    String redirect,
  ) async {
    redirectUrl = redirect;
    return true;
  }

  @override
  Future<void> signOut() async {
    _session = null;
    _user = null;
  }
}
