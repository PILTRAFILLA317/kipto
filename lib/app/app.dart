import 'package:flutter/material.dart';
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
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: ref.watch(themeModeProvider),
    routerConfig: appRouter,
    builder: (context, child) =>
        AuthGate(child: child ?? const SizedBox.shrink()),
  );
}
