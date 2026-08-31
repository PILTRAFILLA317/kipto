import 'dart:async';

import 'package:kipto/core/auth/auth_repository.dart';
import 'package:kipto/core/auth/kipto_auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(GoTrueClient auth) : _auth = GoTrueAuthGateway(auth);
  SupabaseAuthRepository.withGateway(AuthGateway gateway) : _auth = gateway;

  final AuthGateway _auth;
  bool _waitedForInitialRecovery = false;
  Future<KiptoSession?>? _ensureInFlight;
  static const redirectUrl = 'com.example.kipto://auth/callback';
  static const _protectRedirectUrl = '$redirectUrl?flow=protect';
  static const _restoreRedirectUrl = '$redirectUrl?flow=restore';

  @override
  KiptoUser? get currentUser => _auth.currentUser;
  @override
  KiptoSession? get currentSession => _auth.currentSession;
  @override
  bool get isAnonymous => currentUser?.isAnonymous ?? false;
  @override
  String? get userId => currentUser?.id;

  @override
  Stream<KiptoAuthState> watchAuthState() async* {
    yield _stateFor(_auth.currentSession, fallbackSignedOut: false);
    yield* _auth.onAuthStateChange.map(
      (change) => _stateFor(
        change.session,
        fallbackSignedOut:
            change.event == AuthGatewayEvent.signedOut ||
            change.event == AuthGatewayEvent.initial,
      ),
    );
  }

  @override
  Future<KiptoSession?> recoverSession() => _ensureInFlight ??=
      _recoverSession().whenComplete(() => _ensureInFlight = null);

  @override
  Future<KiptoSession?> ensureSession() => _ensureInFlight ??= _ensureSession()
      .whenComplete(() => _ensureInFlight = null);

  Future<KiptoSession?> _ensureSession() async {
    final recovered = await _recoverSession();
    if (recovered != null) return recovered;
    final created = await _auth.signInAnonymously();
    if (created == null) {
      throw StateError('Anonymous sign-in returned no session');
    }
    return created;
  }

  Future<KiptoSession?> _recoverSession() async {
    if (!_waitedForInitialRecovery) {
      _waitedForInitialRecovery = true;
      if (_auth.currentSession == null) {
        try {
          await _auth.onAuthStateChange
              .firstWhere(
                (state) => const {
                  AuthGatewayEvent.initial,
                  AuthGatewayEvent.signedIn,
                  AuthGatewayEvent.tokenRefreshed,
                  AuthGatewayEvent.signedOut,
                }.contains(state.event),
              )
              .timeout(const Duration(seconds: 5));
        } on TimeoutException {
          // No recoverable identity appeared during the SDK recovery window.
        }
      }
    }

    var session = _auth.currentSession;
    if (session != null && session.isExpired) {
      session = await _auth.refreshSession();
    }
    if (session != null) return session;

    if (_auth.currentUser != null) {
      throw StateError('Recovered identity has no usable session');
    }
    return null;
  }

  @override
  Future<void> protectWithApple() => _protect(KiptoIdentityProvider.apple);

  @override
  Future<void> protectWithGoogle() => _protect(KiptoIdentityProvider.google);

  Future<void> _protect(KiptoIdentityProvider provider) async {
    final before = currentUser;
    if (before == null) {
      throw const KiptoAuthFlowException(
        'signed_out',
        'Sign in before connecting another identity.',
      );
    }
    _log('auth.identity.link.started', provider);
    try {
      final launched = await _auth.linkIdentity(provider, _protectRedirectUrl);
      if (!launched) {
        throw const KiptoAuthFlowException(
          'launch_failed',
          'Could not open the sign-in page.',
        );
      }
      final after = currentUser;
      if (after != null && after.id != before.id) {
        throw StateError('Identity linking changed the Supabase user UUID');
      }
      _log('auth.identity.link.completed', provider);
    } on KiptoAuthFlowException {
      rethrow;
    } on AuthException catch (error) {
      final alreadyLinked =
          error.code == 'identity_already_exists' ||
          error.message.toLowerCase().contains('already');
      throw KiptoAuthFlowException(
        alreadyLinked ? 'identity_already_exists' : 'provider_failed',
        alreadyLinked
            ? 'This account already has a Kipto library.'
            : 'Could not protect this library. Please try again.',
      );
    }
  }

  @override
  Future<void> signInExistingWithApple() =>
      _signInExisting(KiptoIdentityProvider.apple);

  @override
  Future<void> signInExistingWithGoogle() =>
      _signInExisting(KiptoIdentityProvider.google);

  Future<void> _signInExisting(KiptoIdentityProvider provider) async {
    if (currentUser != null) {
      throw const KiptoAuthFlowException(
        'session_exists',
        'Sign out before restoring a different library.',
      );
    }
    _log('auth.restore.started', provider);
    final launched = await _auth.signInWithOAuth(provider, _restoreRedirectUrl);
    if (!launched) {
      throw const KiptoAuthFlowException(
        'launch_failed',
        'Could not open the sign-in page.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    _log('auth.signout', null);
  }

  void _log(String event, KiptoIdentityProvider? provider) {
    assert(() {
      // Deliberately logs only a controlled provider name, never tokens/URLs.
      // ignore: avoid_print
      print(
        '$event ${provider == null ? '{}' : '{provider: ${provider.name}}'}',
      );
      return true;
    }());
  }

  KiptoAuthState _stateFor(
    KiptoSession? session, {
    required bool fallbackSignedOut,
  }) {
    final user = session?.user ?? _auth.currentUser;
    if (user == null) {
      return KiptoAuthState(
        fallbackSignedOut
            ? KiptoAuthStatus.signedOut
            : KiptoAuthStatus.initializing,
      );
    }
    return KiptoAuthState(
      user.isAnonymous ? KiptoAuthStatus.anonymous : KiptoAuthStatus.permanent,
      userId: user.id,
    );
  }
}

enum AuthGatewayEvent {
  initial,
  signedIn,
  tokenRefreshed,
  signedOut,
  userUpdated,
}

final class AuthGatewayState {
  const AuthGatewayState(this.event, this.session);
  final AuthGatewayEvent event;
  final KiptoSession? session;
}

abstract interface class AuthGateway {
  KiptoUser? get currentUser;
  KiptoSession? get currentSession;
  Stream<AuthGatewayState> get onAuthStateChange;
  Future<KiptoSession?> refreshSession();
  Future<KiptoSession?> signInAnonymously();
  Future<bool> linkIdentity(KiptoIdentityProvider provider, String redirectUrl);
  Future<bool> signInWithOAuth(
    KiptoIdentityProvider provider,
    String redirectUrl,
  );
  Future<void> signOut();
}

final class GoTrueAuthGateway implements AuthGateway {
  GoTrueAuthGateway(this._auth);
  final GoTrueClient _auth;

  @override
  KiptoUser? get currentUser => _mapUser(_auth.currentUser);
  @override
  KiptoSession? get currentSession => _mapSession(_auth.currentSession);
  @override
  Stream<AuthGatewayState> get onAuthStateChange => _auth.onAuthStateChange.map(
    (state) => AuthGatewayState(switch (state.event) {
      AuthChangeEvent.initialSession => AuthGatewayEvent.initial,
      AuthChangeEvent.signedIn => AuthGatewayEvent.signedIn,
      AuthChangeEvent.tokenRefreshed => AuthGatewayEvent.tokenRefreshed,
      AuthChangeEvent.signedOut => AuthGatewayEvent.signedOut,
      _ => AuthGatewayEvent.userUpdated,
    }, _mapSession(state.session)),
  );

  @override
  Future<KiptoSession?> refreshSession() async =>
      _mapSession((await _auth.refreshSession()).session);
  @override
  Future<KiptoSession?> signInAnonymously() async =>
      _mapSession((await _auth.signInAnonymously()).session);

  @override
  Future<bool> linkIdentity(
    KiptoIdentityProvider provider,
    String redirectUrl,
  ) => _auth.linkIdentity(_oauthProvider(provider), redirectTo: redirectUrl);

  @override
  Future<bool> signInWithOAuth(
    KiptoIdentityProvider provider,
    String redirectUrl,
  ) => _auth.signInWithOAuth(_oauthProvider(provider), redirectTo: redirectUrl);

  @override
  Future<void> signOut() => _auth.signOut();

  static OAuthProvider _oauthProvider(KiptoIdentityProvider provider) =>
      switch (provider) {
        KiptoIdentityProvider.apple => OAuthProvider.apple,
        KiptoIdentityProvider.google => OAuthProvider.google,
      };

  static KiptoUser? _mapUser(User? user) => user == null
      ? null
      : KiptoUser(
          id: user.id,
          isAnonymous: user.isAnonymous,
          identityProviders: List.unmodifiable(
            (user.identities ?? const <UserIdentity>[])
                .map(
                  (identity) => switch (identity.provider) {
                    'apple' => KiptoIdentityProvider.apple,
                    'google' => KiptoIdentityProvider.google,
                    _ => null,
                  },
                )
                .whereType<KiptoIdentityProvider>(),
          ),
        );
  static KiptoSession? _mapSession(Session? session) => session == null
      ? null
      : KiptoSession(
          user: _mapUser(session.user)!,
          isExpired: session.isExpired,
        );
}
