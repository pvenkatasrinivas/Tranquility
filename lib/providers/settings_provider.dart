import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../services/hive_service.dart';
import '../services/channel_service.dart';

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return HiveService.settings;
  }

  Future<void> setDelay(int seconds) async {
    state = AppSettings(
      delaySeconds: seconds,
      silentMode: state.silentMode,
      quickPause: state.quickPause,
    );
    await HiveService.saveSettings(state);
    ChannelService.updateDelay(seconds);
  }

  Future<void> toggleSilentMode() async {
    state = AppSettings(
      delaySeconds: state.delaySeconds,
      silentMode: !state.silentMode,
      quickPause: state.quickPause,
    );
    await HiveService.saveSettings(state);
  }

  Future<void> toggleQuickPause() async {
    state = AppSettings(
      delaySeconds: state.delaySeconds,
      silentMode: state.silentMode,
      quickPause: !state.quickPause,
    );
    await HiveService.saveSettings(state);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
