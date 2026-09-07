import 'package:flutter/material.dart';
import 'package:kipto/app/theme/app_tokens.dart';
import 'package:kipto/core/presentation/widgets/kipto_ui.dart';

class LifeAdminCard extends StatelessWidget {
  const LifeAdminCard({
    super.key,
    required this.title,
    required this.status,
    this.subtitle,
    this.itemId,
    this.hero = false,
    this.onTap,
    this.actionLabel,
    this.icon = Icons.description_outlined,
  });
  final String title;
  final String? itemId;
  final String status;
  final String? subtitle;
  final String? actionLabel;
  final bool hero;
  final VoidCallback? onTap;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = hero
        ? AppColors.textPrimary
        : theme.colorScheme.onSurface;
    final secondary = hero
        ? AppColors.textSecondary
        : theme.colorScheme.onSurfaceVariant;
    final card = Semantics(
      container: true,
      child: KiptoPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(hero ? 34 : 28),
        child: Container(
          constraints: BoxConstraints(minHeight: hero ? 200 : 106),
          padding: EdgeInsets.all(hero ? 24 : 20),
          decoration: BoxDecoration(
            color: hero ? null : theme.colorScheme.surfaceContainerLow,
            gradient: hero
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF543249),
                      Color(0xFF392638),
                      Color(0xFF221F25),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(hero ? 34 : 28),
            border: Border.all(color: foreground.withValues(alpha: .10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, size: 22, color: foreground),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      status,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style:
                    (hero
                            ? theme.textTheme.headlineSmall
                            : theme.textTheme.titleMedium)
                        ?.copyWith(
                          color: foreground,
                          fontSize: hero ? 24 : 16,
                          height: 1.25,
                        ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 10),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(color: secondary),
                ),
              ],
              if (actionLabel != null && onTap != null) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        actionLabel!,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: foreground,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: foreground,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
    if (itemId == null || MediaQuery.disableAnimationsOf(context)) return card;
    return Hero(
      tag: 'matter:$itemId',
      child: Material(type: MaterialType.transparency, child: card),
    );
  }
}
