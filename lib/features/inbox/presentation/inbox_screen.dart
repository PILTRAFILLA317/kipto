import 'package:kipto/core/presentation/widgets/kipto_animated_sliver_list.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/features/items/presentation/widgets/matter_swipe.dart';
import 'package:intl/intl.dart';
import 'package:kipto/features/inbox/domain/inbox_order.dart';
import 'package:kipto/core/repositories/item_queries.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/presentation/widgets/kipto_ui.dart';
import 'package:kipto/core/presentation/widgets/life_admin_card.dart';
import 'package:kipto/features/inbox/presentation/providers/inbox_providers.dart';
import 'package:kipto/l10n/app_localizations.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    ref.watch(authStateProvider.select((s) => s.valueOrNull?.userId));
    final owner = ref.read(authRepositoryProvider).userId;
    final items = ref.watch(activeItemsProvider);
    final currentItems =
        items.valueOrNull?.where((item) => item.ownerId == owner).toList() ??
        [];
    final signals = currentItems.isNotEmpty
        ? ref.watch(itemSignalsProvider).valueOrNull ?? <String, ItemSignal>{}
        : <String, ItemSignal>{};
    final ordered = orderInbox(currentItems, signals);
    return CustomScrollView(
      key: const PageStorageKey('pending-scroll'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.outOfYourHead,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 12),
                if (items.hasValue)
                  Text(
                    l.activeCount(currentItems.length),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
        ...items.when(
          loading: () => [
            const SliverPadding(
              padding: EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(child: KiptoSkeleton(height: 200)),
            ),
          ],
          error: (_, _) => [
            SliverFillRemaining(
              hasScrollBody: false,
              child: KiptoStateView(
                icon: Icons.cloud_off_outlined,
                title: l.localError,
                message: '',
                actionLabel: l.retry,
                onAction: () => ref.invalidate(activeItemsProvider),
              ),
            ),
          ],
          data: (_) => [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: KiptoAnimatedSliverList(
                accountScope: owner,
                items: ordered,
                idOf: (entry) => entry.item.id,
                itemBuilder: (context, entry, index) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (index == 0 || entry.group != ordered[index - 1].group)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Semantics(
                          header: true,
                          child: Text(switch (entry.group) {
                            InboxGroup.review => l.reviewGroup,
                            InboxGroup.dated => l.datedGroup,
                            InboxGroup.other => l.otherGroup,
                          }, style: Theme.of(context).textTheme.titleSmall),
                        ),
                      ),
                    MatterSwipe(
                      item: entry.item,
                      child: LifeAdminCard(
                        itemId: entry.item.id,
                        title: entry.item.title,
                        onTap: () => context.push('/items/${entry.item.id}'),
                        subtitle: entry.item.summary.isEmpty
                            ? null
                            : entry.item.summary,
                        status: entry.signal.needsReview
                            ? l.proposedAction
                            : entry.signal.nextReminder != null
                            ? '${l.pendingReminder} · ${DateFormat.yMMMd(l.localeName).format(entry.signal.nextReminder!.toLocal())}'
                            : entry.signal.explicitDate != null
                            ? '${l.detectedDate} · ${entry.signal.explicitDate}'
                            : entry.signal.analysisState == 'running'
                            ? l.analysisRunning
                            : entry.signal.analysisState == 'queued' ||
                                  entry.signal.analysisState == 'retry'
                            ? l.analysisQueued
                            : l.withoutDate,
                        hero: index == 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (ordered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: KiptoStateView(
                  icon: Icons.check_circle_outline,
                  title: l.emptyPendingTitle,
                  message: l.emptyPendingBody,
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ],
    );
  }
}
