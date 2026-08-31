import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/auth/kipto_auth_state.dart';
import 'package:kipto/core/auth/supabase_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  test('recovery offers restore before creating an anonymous user', () async {
    final gateway = _FakeGateway();
    final repository = SupabaseAuthRepository.withGateway(gateway);
    scheduleMicrotask(
      () => gateway.events.add(
        const AuthGatewayState(AuthGatewayEvent.initial, null),
      ),
    );

    expect(await repository.recoverSession(), isNull);
    expect(gateway.signInCalls, 0);
  });

  test('protecting an anonymous library preserves its user UUID', () async {
    final gateway = _FakeGateway(
      session: const KiptoSession(user: user, isExpired: false),
    );
    final repository = SupabaseAuthRepository.withGateway(gateway);
    final before = repository.userId;

    await repository.protectWithGoogle();

    expect(repository.userId, before);
    expect(gateway.lastRedirectUrl, endsWith('?flow=protect'));
  });

  test('linking detects a changed UUID as an invalid protect flow', () async {
    final gateway = _FakeGateway(
      session: const KiptoSession(user: user, isExpired: false),
    )..changeUserOnLink = true;
    final repository = SupabaseAuthRepository.withGateway(gateway);

    await expectLater(repository.protectWithApple(), throwsStateError);
  });

  test('existing identity failure preserves the anonymous session', () async {
    final gateway = _FakeGateway(
      session: const KiptoSession(user: user, isExpired: false),
    )..identityAlreadyExists = true;
    final repository = SupabaseAuthRepository.withGateway(gateway);

    await expectLater(
      repository.protectWithGoogle(),
      throwsA(
        isA<KiptoAuthFlowException>().having(
          (error) => error.code,
          'code',
          'identity_already_exists',
        ),
      ),
    );
    expect(repository.userId, 'user-a');
    expect(repository.isAnonymous, isTrue);
  });

  test('existing-account sign-in uses the restore callback flow', () async {
    final gateway = _FakeGateway();
    final repository = SupabaseAuthRepository.withGateway(gateway);

    await repository.signInExistingWithApple();

    expect(gateway.lastRedirectUrl, endsWith('?flow=restore'));
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
  bool changeUserOnLink = false;
  bool identityAlreadyExists = false;
  String? lastRedirectUrl;

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

  @override
  Future<bool> linkIdentity(
    KiptoIdentityProvider provider,
    String redirectUrl,
  ) async {
    lastRedirectUrl = redirectUrl;
    if (identityAlreadyExists) {
      throw const AuthException(
        'Identity already exists',
        code: 'identity_already_exists',
      );
    }
    if (changeUserOnLink) {
      _user = const KiptoUser(id: 'different-user', isAnonymous: false);
      _session = KiptoSession(user: _user!, isExpired: false);
    }
    return true;
  }

  @override
  Future<bool> signInWithOAuth(
    KiptoIdentityProvider provider,
    String redirectUrl,
  ) async {
    lastRedirectUrl = redirectUrl;
    return true;
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _session = null;
  }
}
