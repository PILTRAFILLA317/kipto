import 'package:flutter/material.dart';
import 'package:kipto/core/presentation/widgets/kipto_ui.dart';

class AsyncErrorView extends StatelessWidget {
  const AsyncErrorView({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => KiptoStateView(
    icon: Icons.cloud_off_outlined,
    title: 'Kipto could not load this content',
    message: error.toString(),
    actionLabel: onRetry == null ? null : 'Try again',
    onAction: onRetry,
  );
}
