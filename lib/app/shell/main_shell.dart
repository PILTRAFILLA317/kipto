import 'package:kipto/features/capture/presentation/shared_intake.dart';
import 'package:kipto/app/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kipto/core/presentation/widgets/content_width.dart';
import 'package:kipto/core/presentation/widgets/kipto_ui.dart';
import 'package:kipto/features/capture/presentation/add_sheet.dart';
import 'package:kipto/l10n/app_localizations.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: KiptoBackground(
        child: SafeArea(
          child: ContentWidth(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Kipto',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      KiptoIconButton(
                        icon: Icons.search_outlined,
                        tooltip: l.search,
                        onPressed: () => context.push('/search'),
                      ),
                      const SizedBox(width: 8),
                      KiptoIconButton(
                        icon: Icons.settings_outlined,
                        tooltip: l.settings,
                        onPressed: () => context.push('/settings'),
                      ),
                    ],
                  ),
                ),
                const SharedIntakeBanner(),
                Expanded(child: navigationShell),
                KiptoBottomDock(
                  selectedIndex: navigationShell.currentIndex,
                  onSelected: navigationShell.goBranch,
                  onAdd: () => showAddSheet(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class KiptoBottomDock extends StatelessWidget {
  const KiptoBottomDock({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.onAdd,
  });
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: KiptoGlassSurface(
              padding: const EdgeInsets.all(6),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedAlign(
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : AppDurations.normal,
                        curve: Curves.easeInOutCubic,
                        alignment: selectedIndex == 0
                            ? AlignmentDirectional.centerStart
                            : AlignmentDirectional.centerEnd,
                        child: FractionallySizedBox(
                          widthFactor: .5,
                          heightFactor: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSurface
                                  .withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(
                                AppRadii.pill,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (final destination in [
                        (Icons.inbox_outlined, l.pending),
                        (Icons.inventory_2_outlined, l.archive),
                      ].asMap().entries)
                        Expanded(
                          child: Semantics(
                            selected: selectedIndex == destination.key,
                            button: true,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                minimumSize: const Size(48, 60),
                                foregroundColor: Theme.of(context)
                                    .colorScheme
                                    .onSurface,
                              ),
                              onPressed: () => onSelected(destination.key),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(destination.value.$1, size: 22),
                                  const SizedBox(height: 4),
                                  Text(
                                    destination.value.$2,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filled(
            key: const Key('add-button'),
            tooltip: l.add,
            style: IconButton.styleFrom(minimumSize: const Size.square(60)),
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 28),
          ),
        ],
      ),
    );
  }
}
