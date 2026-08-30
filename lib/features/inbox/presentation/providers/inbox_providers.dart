import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/domain/models/inbox_overview.dart';
import 'package:kipto/core/providers/repository_providers.dart';
import 'package:kipto/core/providers/time_provider.dart';

final inboxOverviewProvider = StreamProvider<InboxOverview>(
  (ref) => ref
      .watch(savedItemsRepositoryProvider)
      .watchInboxOverview(ref.watch(currentTimeProvider)),
);
