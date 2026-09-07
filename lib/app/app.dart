import 'package:flutter/material.dart';
import 'package:kipto/l10n/app_localizations.dart';
import 'package:kipto/app/theme/motion_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/app/router/app_router.dart';
import 'package:kipto/app/theme/app_theme.dart';
import 'package:kipto/app/theme/theme_mode_controller.dart';
import 'package:kipto/features/account/presentation/auth_gate.dart';

class KiptoApp extends ConsumerWidget {
  const KiptoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'Kipto',
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: ref.watch(themeModeProvider),
    routerConfig: appRouter,
    themeAnimationDuration:
        ref.watch(motionPreferencesProvider).reduced ||
            MediaQueryData.fromView(View.of(context)).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 220),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        disableAnimations:
            MediaQuery.disableAnimationsOf(context) ||
            ref.watch(motionPreferencesProvider).reduced,
      ),
      child: AuthGate(child: child ?? const SizedBox.shrink()),
    ),
  );
}
