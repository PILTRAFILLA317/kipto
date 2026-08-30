import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const aiAnalysisEnabledPreferenceKey = 'analysis.aiAnalysisEnabled';
const aiAnalysisPausedPreferenceKey = 'analysis.userPaused';

final class AiAnalysisPreferencesState {
  const AiAnalysisPreferencesState({
    this.loaded = false,
    this.enabled = false,
    this.userPaused = false,
  });

  final bool loaded;
  final bool enabled;
  final bool userPaused;
}

final class AiAnalysisPreferencesController
    extends StateNotifier<AiAnalysisPreferencesState> {
  AiAnalysisPreferencesController() : super(const AiAnalysisPreferencesState());

  Future<void>? _loading;

  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      state = AiAnalysisPreferencesState(
        loaded: true,
        enabled: preferences.getBool(aiAnalysisEnabledPreferenceKey) ?? false,
        userPaused: preferences.getBool(aiAnalysisPausedPreferenceKey) ?? false,
      );
    } on Object {
      if (mounted) state = const AiAnalysisPreferencesState(loaded: true);
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = AiAnalysisPreferencesState(
      loaded: true,
      enabled: enabled,
      userPaused: state.userPaused,
    );
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(aiAnalysisEnabledPreferenceKey, enabled);
    } on Object {
      // The device-local selection still applies for this process.
    }
  }

  Future<void> setUserPaused(bool paused) async {
    state = AiAnalysisPreferencesState(
      loaded: true,
      enabled: state.enabled,
      userPaused: paused,
    );
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(aiAnalysisPausedPreferenceKey, paused);
    } on Object {
      // The selected pause state still applies for the current session.
    }
  }
}
