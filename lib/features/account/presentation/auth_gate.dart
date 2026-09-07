import 'package:kipto/app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kipto/app/notification_lifecycle.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/l10n/app_localizations.dart';

// Account setup is optional; explicit capture is always available locally.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authStateProvider, (before, after) {
      final previous = before?.valueOrNull?.userId;
      final next = after.valueOrNull?.userId;
      if (previous != null && next != previous) {
        // Dismiss routes holding old document snapshots when leaving an account.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          final router = appRouter;
          if (router.routeInformationProvider.value.uri.path !=
              '/account-deletion') {
            resetAccountNavigation();
          }
        });
      }
    });
    return NotificationLifecycle(child: child);
  }
}

class AuthCallbackScreen extends StatelessWidget {
  const AuthCallbackScreen({super.key, this.callbackError});
  final String? callbackError;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  callbackError == null ? l.account : l.operationFailed,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go('/inbox'),
                  child: Text(l.pending),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
