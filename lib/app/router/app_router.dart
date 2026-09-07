import 'package:kipto/features/privacy/presentation/account_deletion_screen.dart';
import 'package:kipto/features/billing/presentation/pro_screen.dart';
import 'package:kipto/features/items/presentation/item_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:kipto/features/archive/presentation/archive_screen.dart';
import 'package:kipto/features/search/presentation/search_screen.dart';
import 'package:kipto/features/design/presentation/design_preview_screen.dart';
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
      path: '/items/:id',
      builder: (_, state) =>
          ItemDetailScreen(itemId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/account-deletion',
      builder: (_, _) => const AccountDeletionScreen(),
    ),
    GoRoute(path: '/pro', builder: (_, _) => const ProScreen()),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
    GoRoute(path: '/search', builder: (_, _) => const SearchScreen()),
    if (kDebugMode)
      GoRoute(
        path: '/design-preview',
        builder: (_, _) => const DesignPreviewScreen(),
      ),
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
              path: '/archive',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ArchiveScreen()),
            ),
          ],
        ),
      ],
    ),
  ],
);

void resetAccountNavigation() {
  _rootNavigatorKey.currentState?.popUntil((route) => route.isFirst);
  appRouter.go('/inbox');
}
