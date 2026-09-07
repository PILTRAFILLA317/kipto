import 'package:flutter/services.dart';
import 'package:kipto/app/theme/motion_preferences.dart';
import 'package:kipto/app/theme/app_tokens.dart';
import 'package:kipto/core/presentation/widgets/kipto_animated_sliver_list.dart';
import 'package:kipto/core/providers/sync_providers.dart';

import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/presentation/widgets/kipto_ui.dart';
import 'package:kipto/core/presentation/widgets/life_admin_card.dart';
import 'package:kipto/features/inbox/presentation/providers/inbox_providers.dart';
import 'package:kipto/l10n/app_localizations.dart';

class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});
  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  ItemStatus? _filter;
  String _query = '';
  Timer? _debounce;
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    ref.watch(authStateProvider.select((s) => s.valueOrNull?.userId));
    final owner = ref.read(authRepositoryProvider).userId;
    final matching = _query.isEmpty
        ? null
        : ref.watch(searchIdsProvider(_query));
    return CustomScrollView(
      key: const PageStorageKey('archive-scroll'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.archive,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 24),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: l.searchHint,
                  ),
                  onChanged: (text) {
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 200), () {
                      if (mounted) setState(() => _query = text.trim());
                    });
                  },
                ),
                const SizedBox(height: 16),
                DefaultTabController(
                  length: 3,
                  animationDuration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : AppDurations.normal,
                  child: TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface
                          .withValues(alpha: .13),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    labelColor: Theme.of(context).colorScheme.onSurface,
                    unselectedLabelColor: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                    tabs: [
                      Tab(text: l.all),
                      Tab(text: l.saved),
                      Tab(text: l.resolved),
                    ],
                    onTap: (index) async {
                      final next = [
                        null,
                        ItemStatus.archived,
                        ItemStatus.resolved,
                      ][index];
                      if (_filter == next) return;
                      setState(() => _filter = next);
                      if (ref.read(motionPreferencesProvider).haptics) {
                        try {
                          await HapticFeedback.selectionClick();
                        } on Object {
                          // Optional feedback must not gate filtering.
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        ...ref
            .watch(archivedItemsProvider)
            .when(
              loading: () => [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: KiptoSkeleton(height: 106),
                  ),
                ),
              ],
              error: (_, _) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: KiptoStateView(
                    icon: Icons.error_outline,
                    title: l.localError,
                    message: '',
                    actionLabel: l.retry,
                    onAction: () => ref.invalidate(archivedItemsProvider),
                  ),
                ),
              ],
              data: (items) {
                final visible = items
                    .where(
                      (item) =>
                          item.ownerId == owner &&
                          (_filter == null || item.status == _filter) &&
                          (_query.isEmpty ||
                              (matching?.valueOrNull?.contains(item.id) ??
                                  false)),
                    )
                    .toList();
                if (matching?.isLoading == true) {
                  return [
                    const SliverToBoxAdapter(child: KiptoSkeleton(height: 100)),
                  ];
                }
                if (matching?.hasError == true) {
                  return [SliverToBoxAdapter(child: Text(l.localError))];
                }
                return [
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: KiptoAnimatedSliverList(
                      accountScope: owner,
                      items: visible,
                      idOf: (item) => item.id,
                      itemBuilder: (_, item, index) => LifeAdminCard(
                        itemId: item.id,
                        title: item.title,
                        onTap: () => context.push('/items/${item.id}'),
                        status: item.status == ItemStatus.resolved
                            ? l.resolved
                            : l.saved,
                      ),
                    ),
                  ),
                  if (visible.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: KiptoStateView(
                        icon: Icons.inventory_2_outlined,
                        title: l.emptyArchiveTitle,
                        message: l.emptyArchiveBody,
                      ),
                    ),
                ];
              },
            ),
      ],
    );
  }
}
