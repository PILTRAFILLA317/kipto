import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kipto/core/providers/sync_providers.dart';

class PrivacyPreferences {
  const PrivacyPreferences({
    this.sync = false,
    this.analysis = false,
    this.backup = false,
  });
  final bool sync, analysis, backup;
}

final privacyPreferencesProvider =
    StateNotifierProvider<PrivacyPreferencesController, PrivacyPreferences>((
      ref,
    ) {
      ref.watch(authStateProvider.select((s) => s.valueOrNull?.userId));
      return PrivacyPreferencesController(
        scope: ref.read(authRepositoryProvider).userId ?? 'local',
      );
    });

class PrivacyPreferencesController extends StateNotifier<PrivacyPreferences> {
  PrivacyPreferencesController({this.scope = 'local'})
    : super(const PrivacyPreferences()) {
    ready = _load();
  }
  final String scope;
  String get _key => 'privacy.$scope.v1';
  Future<void> _writes = Future.value();
  int _revision = 0;
  late final Future<void> ready;
  bool _edited = false;
  PrivacyPreferences? _desired;
  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (mounted && !_edited) {
        final saved =
            jsonDecode(p.getString(_key) ?? '{}') as Map<String, dynamic>;
        if (saved['version'] == 1) {
          state = PrivacyPreferences(
            sync: saved['sync'] == true,
            analysis: saved['analysis'] == true,
            backup: saved['backup'] == true,
          );
        }
      }
    } on Object {
      /* Default is no external transfer. */
    }
  }

  Future<void> update({bool? sync, bool? analysis, bool? backup}) async {
    await ready;
    if (!mounted) return;
    _edited = true;
    final previous = _desired ?? state;
    final next = PrivacyPreferences(
      sync: sync ?? previous.sync,
      analysis: analysis ?? previous.analysis,
      backup: backup ?? previous.backup,
    );
    _desired = next;
    // Disabling takes effect immediately even when preferences cannot be saved.
    if (sync == false || analysis == false || backup == false) {
      state = PrivacyPreferences(
        sync: sync == false ? false : state.sync,
        analysis: analysis == false ? false : state.analysis,
        backup: backup == false ? false : state.backup,
      );
    }
    final revision = ++_revision;
    final write = _writes.then((_) async {
      if (!mounted || revision != _revision) return;
      final p = await SharedPreferences.getInstance();
      if (!await p.setString(
        _key,
        jsonEncode({
          'version': 1,
          'acceptedAt': DateTime.now().toUtc().toIso8601String(),
          'sync': next.sync,
          'analysis': next.analysis,
          'backup': next.backup,
        }),
      )) {
        throw StateError('Preferences could not be saved');
      }
      if (mounted && revision == _revision) state = next;
    });
    _writes = write.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    try {
      await write;
    } on Object {
      if (mounted && revision == _revision) _desired = state;
      rethrow;
    }
  }
}
