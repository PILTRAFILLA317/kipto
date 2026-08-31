import 'package:kipto/features/cloud_preview/domain/cloud_preview_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class CloudPreviewPreferenceState {
  const CloudPreviewPreferenceState({
    this.mode = CloudImageSyncMode.optimizedPreviews,
    this.userPaused = false,
    this.loaded = false,
  });

  final CloudImageSyncMode mode;
  final bool userPaused;
  final bool loaded;

  CloudPreviewPreferenceState copyWith({
    CloudImageSyncMode? mode,
    bool? userPaused,
    bool? loaded,
  }) => CloudPreviewPreferenceState(
    mode: mode ?? this.mode,
    userPaused: userPaused ?? this.userPaused,
    loaded: loaded ?? this.loaded,
  );
}

abstract interface class CloudPreviewPreferences {
  Future<CloudPreviewPreferenceState> load();
  Future<void> setMode(CloudImageSyncMode mode);
  Future<void> setUserPaused(bool paused);
}

final class SharedPreferencesCloudPreviewPreferences
    implements CloudPreviewPreferences {
  static const _modeKey = 'cloudPreview.mode';
  static const _pausedKey = 'cloudPreview.userPaused';

  @override
  Future<CloudPreviewPreferenceState> load() async {
    final preferences = await SharedPreferences.getInstance();
    final rawMode = preferences.getString(_modeKey);
    final mode = CloudImageSyncMode.values.where(
      (value) => value.name == rawMode,
    );
    return CloudPreviewPreferenceState(
      mode: mode.isEmpty ? CloudImageSyncMode.optimizedPreviews : mode.first,
      userPaused: preferences.getBool(_pausedKey) ?? false,
      loaded: true,
    );
  }

  @override
  Future<void> setMode(CloudImageSyncMode mode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_modeKey, mode.name);
  }

  @override
  Future<void> setUserPaused(bool paused) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_pausedKey, paused);
  }
}
