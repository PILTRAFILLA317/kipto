import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/presentation/widgets/content_width.dart';
import 'package:kipto/core/presentation/widgets/kipto_ui.dart';
import 'package:kipto/core/presentation/widgets/life_admin_card.dart';
import 'package:kipto/features/inbox/presentation/providers/inbox_providers.dart';
import 'package:kipto/l10n/app_localizations.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String query = '';
  Timer? _debounce;
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final matching = query.isEmpty ? null : ref.watch(searchIdsProvider(query));
    return Scaffold(
      appBar: AppBar(title: Text(l.search)),
      body: ContentWidth(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                autofocus: true,
                onChanged: (value) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 200), () {
                    if (mounted) setState(() => query = value.trim());
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l.searchHint,
                ),
              ),
            ),
            Expanded(
              child: ref
                  .watch(allItemsProvider)
                  .when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(20),
                      child: KiptoSkeleton(height: 106),
                    ),
                    error: (_, _) => Center(child: Text(l.localError)),
                    data: (items) {
                      final matches = items
                          .where(
                            (i) =>
                                query.isEmpty ||
                                (matching?.valueOrNull?.contains(i.id) ??
                                    false),
                          )
                          .toList();
                      if (matching?.isLoading == true) {
                        return Center(child: KiptoProgress(label: l.loading));
                      }
                      if (matching?.hasError == true) {
                        return Center(child: Text(l.localError));
                      }
                      if (matches.isEmpty) {
                        return Center(child: Text(l.noResults));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: matches.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => LifeAdminCard(
                          title: matches[i].title,
                          onTap: () => context.push('/items/${matches[i].id}'),
                          status: l.localSaved,
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
