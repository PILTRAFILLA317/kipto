import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/app/router/app_router.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';

final class NotificationLifecycle extends ConsumerStatefulWidget {
  const NotificationLifecycle({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationLifecycle> createState() =>
      _NotificationLifecycleState();
}

final class _NotificationLifecycleState
    extends ConsumerState<NotificationLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    try {
      final payload = await ref
          .read(reminderNotificationSchedulerProvider)
          .initialize((value) => unawaited(_openPayload(value)));
      if (payload != null) await _openPayload(payload);
      _refreshSettings();
    } on Object {
      // Device integrations must never prevent the local-first app from opening.
    }
  }

  Future<void> _openPayload(String value) async {
    final route = await ref
        .read(notificationRouteResolverProvider)
        .routeForPayload(value);
    appRouter.go(route);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    unawaited(_resume());
  }

  Future<void> _resume() async {
    try {
      await ref.read(reminderNotificationSchedulerProvider).reconcile();
      _refreshSettings();
    } on Object {
      // Scheduling failure is recoverable on the next resume or explicit action.
    }
  }

  void _refreshSettings() {
    ref.invalidate(notificationPermissionStatusProvider);
    ref.invalidate(scheduledReminderCountProvider);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
