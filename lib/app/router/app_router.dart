import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kipto/app/shell/main_shell.dart';
import 'package:kipto/features/account/presentation/auth_gate.dart';
import 'package:kipto/features/inbox/presentation/inbox_screen.dart';
import 'package:kipto/features/library/presentation/library_screen.dart';
import 'package:kipto/features/saved_item/presentation/saved_item_detail_screen.dart';
import 'package:kipto/features/search/presentation/search_screen.dart';
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
        flow: state.uri.queryParameters['flow'],
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
              path: '/library',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: LibraryScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: SearchScreen()),
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
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/item/:id',
      builder: (context, state) =>
          SavedItemDetailScreen(itemId: state.pathParameters['id']!),
    ),
  ],
);
