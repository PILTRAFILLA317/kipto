import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kipto/app/notification_lifecycle.dart';
import 'package:kipto/core/auth/kipto_auth_state.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';
import 'package:kipto/features/photo_library/presentation/photo_library_lifecycle.dart';

final class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

final class _AuthGateState extends ConsumerState<AuthGate> {
  String? _restoredUserId;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    return auth.when(
      loading: () => const _AuthLoading(),
      error: (_, _) => const _WelcomeScreen(
        message: 'Cloud sign-in is temporarily unavailable.',
      ),
      data: (state) {
        if (state.status == KiptoAuthStatus.unconfigured) {
          return _authenticatedApp();
        }
        if (state.status == KiptoAuthStatus.initializing) {
          return const _AuthLoading();
        }
        if (state.status == KiptoAuthStatus.signedOut ||
            state.status == KiptoAuthStatus.error) {
          return _WelcomeScreen(message: state.message);
        }
        if (state.status == KiptoAuthStatus.permanent &&
            state.userId != null &&
            _restoredUserId != state.userId) {
          return _RestoreGate(
            userId: state.userId!,
            onReady: () {
              if (!mounted) return;
              setState(() => _restoredUserId = state.userId);
            },
          );
        }
        return _authenticatedApp();
      },
    );
  }

  Widget _authenticatedApp() =>
      NotificationLifecycle(child: PhotoLibraryLifecycle(child: widget.child));
}

final class AuthCallbackScreen extends ConsumerStatefulWidget {
  const AuthCallbackScreen({
    super.key,
    required this.flow,
    required this.callbackError,
  });

  final String? flow;
  final String? callbackError;

  @override
  ConsumerState<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

final class _AuthCallbackScreenState extends ConsumerState<AuthCallbackScreen> {
  bool _navigating = false;

  bool get _isProtectFlow => widget.flow == 'protect';
  String get _destination => _isProtectFlow ? '/settings' : '/inbox';

  @override
  Widget build(BuildContext context) {
    if (widget.callbackError case final callbackError?) {
      final alreadyUsed =
          callbackError.toLowerCase().contains('already') ||
          callbackError.toLowerCase().contains('identity');
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, size: 44),
                    const SizedBox(height: 18),
                    Text(
                      alreadyUsed
                          ? 'This account already has a Kipto library.'
                          : 'Could not complete sign in.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isProtectFlow
                          ? 'Your current library is unchanged.'
                          : 'No local data was changed.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => context.go(_destination),
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final state = ref.watch(authStateProvider).valueOrNull;
    if (!_navigating && state?.status == KiptoAuthStatus.permanent) {
      _navigating = true;
      scheduleMicrotask(() {
        if (mounted) context.go(_destination);
      });
    }

    return const _AuthLoading();
  }
}

class _AuthLoading extends StatelessWidget {
  const _AuthLoading();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _WelcomeScreen extends ConsumerStatefulWidget {
  const _WelcomeScreen({this.message});
  final String? message;

  @override
  ConsumerState<_WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<_WelcomeScreen> {
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.auto_awesome_mosaic_outlined,
                  size: 58,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Kipto',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your screenshots are unfinished actions.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _busy ? null : _getStarted,
                  child: const Text('Get started'),
                ),
                const SizedBox(height: 30),
                Text(
                  'Already use Kipto?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _restore(KiptoIdentityProvider.apple),
                  icon: const Icon(Icons.apple),
                  label: const Text('Sign in with Apple'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _restore(KiptoIdentityProvider.google),
                  icon: const Icon(Icons.account_circle_outlined),
                  label: const Text('Sign in with Google'),
                ),
                if (_busy) ...[
                  const SizedBox(height: 18),
                  const Center(child: CircularProgressIndicator()),
                ],
                if (_error ?? widget.message case final message?) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _getStarted() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).ensureSession();
    } on Object {
      if (mounted) setState(() => _error = 'Could not start cloud sync.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore(KiptoIdentityProvider provider) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repository = ref.read(authRepositoryProvider);
      if (provider == KiptoIdentityProvider.apple) {
        await repository.signInExistingWithApple();
      } else {
        await repository.signInExistingWithGoogle();
      }
    } on KiptoAuthFlowException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } on Object {
      if (mounted) setState(() => _error = 'Could not open sign in.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _RestoreGate extends ConsumerStatefulWidget {
  const _RestoreGate({required this.userId, required this.onReady});
  final String userId;
  final VoidCallback onReady;

  @override
  ConsumerState<_RestoreGate> createState() => _RestoreGateState();
}

class _RestoreGateState extends ConsumerState<_RestoreGate> {
  late final Future<int> _restore = _run();

  Future<int> _run() async {
    final database = ref.read(appDatabaseProvider);
    final localState = await (database.select(
      database.cloudSyncStates,
    )..where((row) => row.id.equals('local'))).getSingleOrNull();
    if (localState?.userId != widget.userId) {
      await ref.read(syncServiceProvider).initialize();
      await ref.read(reminderNotificationSchedulerProvider).reconcile();
    }
    final count = await database.savedItemsDao.getActive();
    scheduleMicrotask(widget.onReady);
    return count.length;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: FutureBuilder<int>(
        future: _restore,
        builder: (context, snapshot) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!snapshot.hasData) const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              snapshot.hasData
                  ? 'Restored ${snapshot.data} items'
                  : 'Restoring your Kipto library…',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (snapshot.hasError) ...[
              const SizedBox(height: 8),
              const Text('Your local library is safe. Sync will retry.'),
            ],
          ],
        ),
      ),
    ),
  );
}
