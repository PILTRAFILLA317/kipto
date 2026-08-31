import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kipto/app/app.dart';
import 'package:kipto/core/auth/kipto_auth_state.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/features/account/presentation/auth_gate.dart';

import 'fakes/fake_sync_dependencies.dart';

void main() {
  testWidgets('signed-out first run offers restore before anonymous creation', (
    tester,
  ) async {
    final auth = FakeAuthRepository(null);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(auth)],
        child: const KiptoApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Already use Kipto?'), findsOneWidget);
    expect(find.text('Sign in with Apple'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(auth.currentUser, isNull);
  });

  testWidgets('successful protect callback returns to settings', (
    tester,
  ) async {
    final auth = FakeAuthRepository(
      const KiptoUser(id: 'user-a', isAnonymous: false),
    );
    final router = GoRouter(
      initialLocation: '/auth/callback?flow=protect',
      routes: [
        GoRoute(
          path: '/auth/callback',
          builder: (context, state) => AuthCallbackScreen(
            flow: state.uri.queryParameters['flow'],
            callbackError: null,
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, _) => const Scaffold(body: Text('Settings destination')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(auth)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings destination'), findsOneWidget);
  });

  testWidgets('callback identity conflict is safe and does not navigate', (
    tester,
  ) async {
    final auth = FakeAuthRepository(
      const KiptoUser(id: 'user-a', isAnonymous: false),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(auth)],
        child: const MaterialApp(
          home: AuthCallbackScreen(
            flow: 'protect',
            callbackError: 'identity_already_exists',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('This account already has a Kipto library.'),
      findsOneWidget,
    );
    expect(find.text('Your current library is unchanged.'), findsOneWidget);
  });
}
