import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kipto/app/notification_lifecycle.dart';
import 'package:kipto/core/auth/kipto_auth_state.dart';
import 'package:kipto/core/providers/sync_providers.dart';

final class AuthGate extends ConsumerWidget {
  const AuthGate({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authStateProvider);
    return state.when(
      loading: () => const _Loading(),
      error: (_, _) => _Welcome(ref: ref),
      data: (auth) {
        if (auth.status == KiptoAuthStatus.unconfigured) {
          return child;
        }
        if (auth.status == KiptoAuthStatus.initializing) {
          return const _Loading();
        }
        if (auth.status == KiptoAuthStatus.signedOut ||
            auth.status == KiptoAuthStatus.error) {
          return _Welcome(ref: ref);
        }
        unawaited(ref.read(syncServiceProvider).initialize());
        return NotificationLifecycle(child: child);
      },
    );
  }
}

final class _Welcome extends StatelessWidget {
  const _Welcome({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Kipto', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 12),
            const Text('Life Admin foundation'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => ref.read(authRepositoryProvider).ensureSession(),
              child: const Text('Get started'),
            ),
            TextButton(
              onPressed: () =>
                  ref.read(authRepositoryProvider).signInExistingWithApple(),
              child: const Text('Restore with Apple'),
            ),
            TextButton(
              onPressed: () =>
                  ref.read(authRepositoryProvider).signInExistingWithGoogle(),
              child: const Text('Restore with Google'),
            ),
          ],
        ),
      ),
    ),
  );
}

final class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

final class AuthCallbackScreen extends StatelessWidget {
  const AuthCallbackScreen({super.key, this.callbackError});
  final String? callbackError;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: callbackError == null
            ? FilledButton(
                onPressed: () => context.go('/inbox'),
                child: const Text('Continue to Kipto'),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not complete sign in.'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/inbox'),
                    child: const Text('Back to Kipto'),
                  ),
                ],
              ),
      ),
    ),
  );
}
