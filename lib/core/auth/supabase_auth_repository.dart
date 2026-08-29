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
        fallbackSignedOut: change.event == AuthGatewayEvent.signedOut,
      ),
    );
  }

  @override
  Future<KiptoSession?> ensureSession() => _ensureInFlight ??= _ensureSession()
      .whenComplete(() => _ensureInFlight = null);

  Future<KiptoSession?> _ensureSession() async {
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
    final created = await _auth.signInAnonymously();
    if (created == null) {
      throw StateError('Anonymous sign-in returned no session');
    }
    return created;
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

  static KiptoUser? _mapUser(User? user) => user == null
      ? null
      : KiptoUser(id: user.id, isAnonymous: user.isAnonymous);
  static KiptoSession? _mapSession(Session? session) => session == null
      ? null
      : KiptoSession(
          user: KiptoUser(
            id: session.user.id,
            isAnonymous: session.user.isAnonymous,
          ),
          isExpired: session.isExpired,
        );
}
