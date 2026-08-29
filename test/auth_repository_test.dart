import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/auth/kipto_auth_state.dart';
import 'package:kipto/core/auth/supabase_auth_repository.dart';

void main() {
  const user = KiptoUser(id: 'user-a', isAnonymous: true);

  test(
    'existing session is reused and anonymous sign-in is not repeated',
    () async {
      final gateway = _FakeGateway(
        session: const KiptoSession(user: user, isExpired: false),
      );
      final repository = SupabaseAuthRepository.withGateway(gateway);

      expect((await repository.ensureSession())?.user.id, 'user-a');
      expect((await repository.ensureSession())?.user.id, 'user-a');
      expect(gateway.signInCalls, 0);
    },
  );

  test(
    'missing recovered session creates one anonymous identity once',
    () async {
      final gateway = _FakeGateway();
      final repository = SupabaseAuthRepository.withGateway(gateway);
      scheduleMicrotask(
        () => gateway.events.add(
          const AuthGatewayState(AuthGatewayEvent.initial, null),
        ),
      );

      expect((await repository.ensureSession())?.user.id, 'created-user');
      expect((await repository.ensureSession())?.user.id, 'created-user');
      expect(gateway.signInCalls, 1);
    },
  );

  test(
    'expired recovered session refreshes instead of creating a user',
    () async {
      final gateway = _FakeGateway(
        session: const KiptoSession(user: user, isExpired: true),
      );
      final repository = SupabaseAuthRepository.withGateway(gateway);

      expect((await repository.ensureSession())?.isExpired, isFalse);
      expect(gateway.refreshCalls, 1);
      expect(gateway.signInCalls, 0);
    },
  );

  test('recovered identity without session is never auto-replaced', () async {
    final gateway = _FakeGateway(user: user);
    final repository = SupabaseAuthRepository.withGateway(gateway);
    scheduleMicrotask(
      () => gateway.events.add(
        const AuthGatewayState(AuthGatewayEvent.initial, null),
      ),
    );

    await expectLater(repository.ensureSession(), throwsStateError);
    expect(gateway.signInCalls, 0);
  });
}

final class _FakeGateway implements AuthGateway {
  _FakeGateway({KiptoSession? session, KiptoUser? user})
    : _session = session,
      _user = user ?? session?.user;

  KiptoSession? _session;
  KiptoUser? _user;
  final events = StreamController<AuthGatewayState>.broadcast();
  int signInCalls = 0;
  int refreshCalls = 0;

  @override
  KiptoSession? get currentSession => _session;
  @override
  KiptoUser? get currentUser => _user;
  @override
  Stream<AuthGatewayState> get onAuthStateChange => events.stream;

  @override
  Future<KiptoSession?> refreshSession() async {
    refreshCalls++;
    _session = KiptoSession(user: _user!, isExpired: false);
    return _session;
  }

  @override
  Future<KiptoSession?> signInAnonymously() async {
    signInCalls++;
    _user = const KiptoUser(id: 'created-user', isAnonymous: true);
    _session = KiptoSession(user: _user!, isExpired: false);
    return _session;
  }
}
