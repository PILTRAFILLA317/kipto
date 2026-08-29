import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/app/app.dart';
import 'package:kipto/core/providers/database_provider.dart';
import 'package:kipto/dev/seed/development_seed.dart';

class AppBootstrap extends ConsumerStatefulWidget {
  const AppBootstrap({super.key});

  @override
  ConsumerState<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<AppBootstrap> {
  late final Future<void> _initialize;

  @override
  void initState() {
    super.initState();
    _initialize = kDebugMode
        ? DevelopmentSeed(ref.read(appDatabaseProvider)).run()
        : Future<void>.value();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: _initialize,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done &&
          !snapshot.hasError) {
        return const KiptoApp();
      }
      if (snapshot.hasError) {
        return MaterialApp(
          title: 'Kipto',
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Kipto could not initialize its local database.\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      }
      return const MaterialApp(
        title: 'Kipto',
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    },
  );
}
