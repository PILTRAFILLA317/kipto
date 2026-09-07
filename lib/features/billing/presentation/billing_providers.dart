import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../application/billing_repository.dart';

final billingRepositoryProvider = Provider(
  (ref) =>
      BillingRepository(owner: () => ref.read(authRepositoryProvider).userId),
);
final billingOfferingsProvider = FutureProvider<List<Package>>((ref) {
  ref.watch(authStateProvider.select((s) => s.valueOrNull?.userId));
  return ref.watch(billingRepositoryProvider).offerings();
});
final billingStatusProvider = FutureProvider<({bool pro, int used})>((
  ref,
) async {
  ref.watch(authStateProvider.select((s) => s.valueOrNull?.userId));
  final client = ref.watch(supabaseClientProvider),
      owner = ref.read(authRepositoryProvider).userId;
  if (client == null || owner == null) throw const BillingUnavailable();
  final value =
      await client.rpc('kipto_billing_status') as Map<String, dynamic>;
  if (ref.read(authRepositoryProvider).userId != owner) {
    throw const BillingUnavailable();
  }
  return (pro: value['pro'] == true, used: value['used'] as int);
});
