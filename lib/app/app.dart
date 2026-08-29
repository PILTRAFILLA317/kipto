import 'package:flutter/material.dart';
import 'package:kipto/app/router/app_router.dart';
import 'package:kipto/app/theme/app_theme.dart';
import 'package:kipto/features/photo_library/presentation/photo_library_lifecycle.dart';

class KiptoApp extends StatelessWidget {
  const KiptoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Kipto',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: ThemeMode.system,
    routerConfig: appRouter,
    builder: (context, child) =>
        PhotoLibraryLifecycle(child: child ?? const SizedBox.shrink()),
  );
}
