import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kipto/app/theme/app_tokens.dart';

class KiptoBackground extends StatelessWidget {
  const KiptoBackground({super.key, required this.child, this.ambient = true});

  final Widget child;
  final bool ambient;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.surfaceContainerLowest,
                  colors.surface,
                  colors.surface,
                ],
                stops: const [0, 0.34, 1],
              ),
            ),
          ),
          if (ambient) ...[
            Positioned(
              top: -190,
              right: -140,
              width: 390,
              height: 390,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        colors.secondary.withValues(alpha: dark ? 0.15 : 0.08),
                        colors.secondary.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -240,
              left: -210,
              width: 470,
              height: 470,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        colors.primary.withValues(alpha: dark ? 0.09 : 0.05),
                        colors.primary.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          child,
        ],
      ),
    );
  }
}

class KiptoGlassSurface extends StatelessWidget {
  const KiptoGlassSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadii.pill)),
    this.padding = EdgeInsets.zero,
    this.blur = true,
    this.shadow = true,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final bool blur;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh.withValues(
          alpha: dark ? 0.72 : 0.82,
        ),
        borderRadius: borderRadius,
        border: Border.all(
          color: colors.onSurface.withValues(alpha: dark ? 0.12 : 0.10),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.onSurface.withValues(alpha: dark ? 0.075 : 0.055),
            colors.onSurface.withValues(alpha: dark ? 0.025 : 0.015),
          ],
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
    final clipped = ClipRRect(
      borderRadius: borderRadius,
      child: blur
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: content,
            )
          : content,
    );
    if (!shadow) return clipped;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: AppShadows.floating,
      ),
      child: clipped,
    );
  }
}

class KiptoPressable extends StatefulWidget {
  const KiptoPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadii.md)),
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final String? semanticLabel;

  @override
  State<KiptoPressable> createState() => _KiptoPressableState();
}

class _KiptoPressableState extends State<KiptoPressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final content = AnimatedScale(
      duration: reduceMotion ? Duration.zero : AppDurations.fast,
      curve: Curves.easeOutCubic,
      scale: _pressed && widget.onTap != null ? 0.982 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: widget.borderRadius,
          onTap: widget.onTap,
          onHighlightChanged: (value) {
            if (_pressed != value) setState(() => _pressed = value);
          },
          child: widget.child,
        ),
      ),
    );
    if (widget.semanticLabel == null) return content;
    return Semantics(
      button: widget.onTap != null,
      enabled: widget.onTap != null,
      label: widget.semanticLabel,
      child: content,
    );
  }
}

class KiptoIconButton extends StatelessWidget {
  const KiptoIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.selected = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: KiptoGlassSurface(
        blur: true,
        shadow: false,
        child: SizedBox.square(
          dimension: 44,
          child: KiptoPressable(
            onTap: onPressed,
            semanticLabel: tooltip,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: Icon(
              icon,
              size: 20,
              color: selected ? colors.primary : colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class KiptoPill extends StatelessWidget {
  const KiptoPill({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
    this.count,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final child = AnimatedContainer(
      duration: AppDurations.normal,
      curve: Curves.easeOutCubic,
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: selected
            ? colors.onSurface.withValues(alpha: 0.13)
            : colors.surfaceContainer.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: colors.onSurface.withValues(alpha: selected ? 0.15 : 0.07),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: colors.onSurfaceVariant),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected ? colors.onSurface : colors.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 3),
            Transform.translate(
              offset: const Offset(0, -3),
              child: Text(
                '$count',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return child;
    return KiptoPressable(
      onTap: onTap,
      semanticLabel: label,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: child,
    );
  }
}

class KiptoSectionHeader extends StatelessWidget {
  const KiptoSectionHeader({
    super.key,
    required this.title,
    this.count,
    this.trailing,
  });

  final String title;
  final int? count;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Text.rich(
          TextSpan(
            text: title,
            children: count == null
                ? null
                : [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.top,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: Text(
                          '$count',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ],
          ),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      ?trailing,
    ],
  );
}

class KiptoScreenHeader extends StatelessWidget {
  const KiptoScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.ml,
      AppSpacing.xs,
      AppSpacing.ml,
      AppSpacing.md,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                Text(
                  eyebrow!,
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: AppSpacing.xxs),
              ],
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              if (subtitle != null) ...[
                const SizedBox(height: 5),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.sm),
          Row(mainAxisSize: MainAxisSize.min, children: actions),
        ],
      ],
    ),
  );
}

class KiptoSurface extends StatelessWidget {
  const KiptoSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = AppRadii.lg,
    this.color,
    this.border = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      elevation: 0,
      color: color ?? colors.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: border
            ? BorderSide(color: colors.onSurface.withValues(alpha: 0.08))
            : BorderSide.none,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class KiptoActionRow extends StatelessWidget {
  const KiptoActionRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.completed = false,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool completed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = destructive
        ? colors.error
        : completed
        ? colors.tertiary
        : colors.onSurface;
    final row = Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainer.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.onSurface.withValues(alpha: 0.055),
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(
                color: colors.onSurface.withValues(alpha: 0.06),
              ),
            ),
            child: Icon(icon, size: 19, color: foreground),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: foreground, fontSize: 14.5),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          trailing ??
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colors.onSurfaceVariant,
              ),
        ],
      ),
    );
    return KiptoPressable(
      onTap: onTap,
      semanticLabel: title,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: row,
    );
  }
}

class KiptoStateView extends StatelessWidget {
  const KiptoStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh
                    .withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(icon, size: 25),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    ),
  );
}

class KiptoSkeleton extends StatelessWidget {
  const KiptoSkeleton({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.radius = AppRadii.lg,
  });

  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surfaceContainerLow,
            colors.surfaceContainerHigh.withValues(alpha: 0.72),
            colors.surfaceContainerLow,
          ],
        ),
      ),
    );
  }
}

class KiptoNavDestination {
  const KiptoNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class KiptoBottomNavigation extends StatelessWidget {
  const KiptoBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<KiptoNavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: KiptoGlassSurface(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
            child: SizedBox(
              height: 56,
              child: Row(
                children: [
                  for (var index = 0; index < destinations.length; index++)
                    Expanded(
                      child: _KiptoNavItem(
                        destination: destinations[index],
                        selected: selectedIndex == index,
                        selectedColor: colors.onSurface,
                        unselectedColor: colors.onSurfaceVariant,
                        onTap: () => onSelected(index),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KiptoNavItem extends StatelessWidget {
  const _KiptoNavItem({
    required this.destination,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final KiptoNavDestination destination;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return KiptoPressable(
      onTap: onTap,
      semanticLabel: destination.label,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: AnimatedContainer(
        duration: AppDurations.normal,
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: AppDurations.normal,
              curve: Curves.easeOutCubic,
              width: 38,
              height: 29,
              decoration: BoxDecoration(
                color: selected
                    ? colors.onSurface.withValues(alpha: 0.09)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(
                    selected ? destination.selectedIcon : destination.icon,
                    size: 20,
                    color: selected ? selectedColor : unselectedColor,
                  ),
                  if (selected)
                    Positioned(
                      top: -2,
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: colors.tertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 1),
            Text(
              destination.label,
              maxLines: 1,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? selectedColor : unselectedColor,
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
