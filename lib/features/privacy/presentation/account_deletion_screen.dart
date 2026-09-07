import 'package:kipto/core/presentation/widgets/kipto_ui.dart';
import 'package:go_router/go_router.dart';

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/features/account/presentation/account_providers.dart';
import 'package:kipto/features/backup/presentation/backup_providers.dart';
import 'package:kipto/features/analysis/presentation/analysis_providers.dart';
import 'package:kipto/features/settings/application/privacy_preferences.dart';
import 'package:kipto/l10n/app_localizations.dart';

const accountDeletionKey = 'account.pendingDeletion.v1';
Future<void> beginAccountDeletion(WidgetRef ref) async {
  final user = ref.read(authRepositoryProvider).userId;
  if (user == null) throw StateError('Sign in first');
  final p = await SharedPreferences.getInstance();
  if (!await p.setString(
    accountDeletionKey,
    jsonEncode({'owner': user, 'requestId': const Uuid().v4()}),
  )) {
    throw StateError('Could not persist deletion');
  }
  ref.read(analysisQueueProvider).invalidateAccountOrConsent();
  await ref.read(fileQueueProvider).pause();
  await ref
      .read(privacyPreferencesProvider.notifier)
      .update(sync: false, analysis: false, backup: false);
  await ref.read(syncServiceProvider).stopForAccountChange();
}

class AccountDeletionScreen extends ConsumerStatefulWidget {
  const AccountDeletionScreen({super.key});
  @override
  ConsumerState<AccountDeletionScreen> createState() =>
      _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends ConsumerState<AccountDeletionScreen> {
  bool _busy = false, _complete = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _retry());
  }

  Future<void> _retry() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = jsonDecode(
        prefs.getString(accountDeletionKey) ?? '{}',
      ) as Map<String, dynamic>;
      final owner = ref.read(authRepositoryProvider).userId;
      if (saved['requestId'] == null ||
          owner != null && owner != saved['owner']) {
        throw StateError('Account changed');
      }
      final config = ref.read(appConfigProvider);
      final request = await client.postUrl(
        Uri.parse('${config.supabaseUrl}/functions/v1/delete-account'),
      );
      request.followRedirects = false;
      request.headers.contentType = ContentType.json;
      request.headers.set('apikey', config.supabasePublishableKey);
      final token = ref
          .read(supabaseClientProvider)
          ?.auth
          .currentSession
          ?.accessToken;
      if (token != null) request.headers.set('Authorization', 'Bearer $token');
      request.add(
        utf8.encode(
          jsonEncode({
            'confirmation': 'deleteAccount',
            'requestId': saved['requestId'],
          }),
        ),
      );
      final response = await request.close().timeout(
        const Duration(seconds: 60),
      );
      final bytes = <int>[];
      await for (final chunk in response.timeout(const Duration(seconds: 30))) {
        if (bytes.length + chunk.length > 4096) {
          throw StateError('Invalid response');
        }
        bytes.addAll(chunk);
      }
      final body = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      if (response.statusCode != 200 && response.statusCode != 202) {
        throw StateError('Deletion pending');
      }
      if (body['requestId'] != null) {
        saved['requestId'] = body['requestId'];
        await prefs.setString(accountDeletionKey, jsonEncode(saved));
      }
      if (body['state'] == 'complete') {
        await ref
            .read(accountServiceProvider)
            .finishAccountDeletion(saved['owner'] as String);
        await prefs.remove(accountDeletionKey);
        if (mounted) setState(() => _complete = true);
      }
    } on Object {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).deletePending);
      }
    } finally {
      client.close(force: true);
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopScope(
      canPop: _complete,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.deleteAccount),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                _complete ? l.accountDeleted : l.accountDeletionPending,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              if (!_complete) Text(l.accountDeletionWait),
              if (_error != null) Text(_error!),
              if (_busy)
                KiptoProgress(label: l.accountDeletionPending, linear: true),
              if (!_complete)
                FilledButton(
                  onPressed: _busy ? null : _retry,
                  child: Text(l.retry),
                ),
              if (_complete)
                FilledButton(
                  onPressed: () => context.go('/inbox'),
                  child: Text(l.close),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
