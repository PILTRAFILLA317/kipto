import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kipto/app/shell/main_shell.dart';
import 'package:kipto/features/account/presentation/auth_gate.dart';
import 'package:kipto/features/inbox/presentation/inbox_screen.dart';
import 'package:kipto/features/settings/presentation/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/inbox',
  routes: [
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/auth/callback',
      builder: (context, state) => AuthCallbackScreen(
        callbackError:
            state.uri.queryParameters['error_code'] ??
            state.uri.queryParameters['error_description'] ??
            state.uri.queryParameters['error'],
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/inbox',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: InboxScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: SettingsScreen()),
            ),
          ],
        ),
      ],
    ),
  ],
);
