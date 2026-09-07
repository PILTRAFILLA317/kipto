import 'package:kipto/core/presentation/widgets/kipto_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kipto/core/presentation/widgets/content_width.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/l10n/app_localizations.dart';

import 'billing_providers.dart';

const privacyUrl = String.fromEnvironment('PRIVACY_URL');
const termsUrl = String.fromEnvironment('TERMS_URL');
bool validLegalUrl(String value) =>
    Uri.tryParse(value)?.scheme == 'https' && Uri.parse(value).host.isNotEmpty;

class ProScreen extends ConsumerStatefulWidget {
  const ProScreen({super.key});
  @override
  ConsumerState<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends ConsumerState<ProScreen> {
  bool _busy = false;
  String? _message;
  Future<void> _run(Future<String?> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final message = await action();
      if (mounted) setState(() => _message = message);
    } on Object {
      if (mounted) {
        setState(() => _message = AppLocalizations.of(context).operationFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        ref.invalidate(billingStatusProvider);
      }
    }
  }

  Future<void> _link(String url) async {
    if (!validLegalUrl(url) ||
        !await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        )) {
      throw StateError('Link unavailable');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), theme = Theme.of(context);
    final billing = ref.watch(billingRepositoryProvider),
        user = ref.watch(authRepositoryProvider).userId;
    ref.watch(authStateProvider);
    final status = ref.watch(billingStatusProvider).valueOrNull;
    final legal = validLegalUrl(privacyUrl) && validLegalUrl(termsUrl);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kipto Pro'),
        leading: IconButton(
          tooltip: l.close,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: Text(l.proHeadline, style: theme.textTheme.displaySmall),
            ),
            const SizedBox(height: 16),
            Text(l.proBody, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 28),
            for (final benefit in [
              (Icons.auto_awesome_outlined, l.proAnalysis),
              (Icons.cloud_done_outlined, l.proBackup),
            ])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(benefit.$1, color: theme.colorScheme.primary),
                title: Text(benefit.$2),
              ),
            const SizedBox(height: 24),
            if (status != null) Text(status.pro ? l.proVerified : l.freePlan),
            if (!billing.configured || user == null || !legal)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(l.billingUnavailable),
              ),
            if (billing.configured && user != null)
              ref
                  .watch(billingOfferingsProvider)
                  .when(
                    loading: () =>
                        Center(child: KiptoProgress(label: l.loading)),
                    error: (_, _) => Text(l.billingUnavailable),
                    data: (packages) => Column(
                      children: [
                        if (packages.isEmpty) Text(l.billingUnavailable),
                        for (final package in packages)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: OutlinedButton(
                              onPressed: _busy || !legal
                                  ? null
                                  : () => _run(() async {
                                      final result = await billing.purchase(
                                        package,
                                      );
                                      return result == 'cancelled'
                                          ? null
                                          : result == 'paymentPending'
                                          ? l.paymentPending
                                          : l.purchaseVerificationPending;
                                    }),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        package.packageType ==
                                                PackageType.annual
                                            ? l.annualPlan
                                            : l.monthlyPlan,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        package.storeProduct.priceString,
                                        style: theme.textTheme.titleLarge,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
            Text(l.subscriptionTerms),
            const SizedBox(height: 16),
            if (_busy) KiptoProgress(label: l.loading, linear: true),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_message!, semanticsLabel: _message),
              ),
            TextButton(
              onPressed: _busy || !billing.configured || user == null
                  ? null
                  : () => _run(() async {
                      await billing.restore();
                      return l.restorePurchaseBody;
                    }),
              child: Text(l.restorePurchases),
            ),
            TextButton(
              onPressed: _busy || !billing.configured || user == null
                  ? null
                  : () => _run(() async {
                      final url = await billing.managementUrl();
                      if (url == null) return l.noSubscription;
                      await _link(url);
                      return null;
                    }),
              child: Text(l.manageSubscription),
            ),
            TextButton(
              onPressed: _busy
                  ? null
                  : () {
                      ref.invalidate(billingStatusProvider);
                      ref.invalidate(billingOfferingsProvider);
                    },
              child: Text(l.refreshStatus),
            ),
            Wrap(
              spacing: 16,
              children: [
                if (validLegalUrl(privacyUrl))
                  TextButton(
                    onPressed: () => _run(() async {
                      await _link(privacyUrl);
                      return null;
                    }),
                    child: Text(l.privacy),
                  ),
                if (validLegalUrl(termsUrl))
                  TextButton(
                    onPressed: () => _run(() async {
                      await _link(termsUrl);
                      return null;
                    }),
                    child: Text(l.terms),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
