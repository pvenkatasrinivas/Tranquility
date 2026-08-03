import 'package:hive_flutter/hive_flutter.dart';
import '../models/restricted_app.dart';
import '../models/app_settings.dart';
import '../models/app_stats.dart';

class HiveService {
  static late Box<RestrictedApp> appsBox;
  static late Box<AppSettings> settingsBox;
  static late Box<AppStats> statsBox;

  // ✅ NEW: iOS open counts box
  static late Box<int> iosOpenCountsBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(RestrictedAppAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(AppStatsAdapter());

    appsBox = await Hive.openBox<RestrictedApp>('restricted_apps');
    settingsBox = await Hive.openBox<AppSettings>('settings');
    statsBox = await Hive.openBox<AppStats>('stats');

    // ✅ NEW: open iOS counts box
    iosOpenCountsBox = await Hive.openBox<int>('ios_open_counts');

    if (settingsBox.isEmpty) {
      settingsBox.put('settings', AppSettings());
    }
    if (statsBox.isEmpty) {
      statsBox.put('stats', AppStats());
    }
  }

  static AppSettings get settings =>
      settingsBox.get('settings') ?? AppSettings();

  static AppStats get stats => statsBox.get('stats') ?? AppStats();

  static List<RestrictedApp> get restrictedApps => appsBox.values.toList();

  static Future<void> saveSettings(AppSettings s) =>
      settingsBox.put('settings', s);

  static Future<void> saveStats(AppStats s) =>
      statsBox.put('stats', s);

  static Future<void> addRestrictedApp(RestrictedApp app) =>
      appsBox.put(app.id, app);

  static Future<void> removeRestrictedApp(String id) =>
      appsBox.delete(id);

  static Future<void> updateApp(RestrictedApp app) =>
      appsBox.put(app.id, app);

  static Future<void> recordAppOpen(String packageName) async {
    final apps = appsBox.values
        .where((a) => a.packageName == packageName && a.enabled)
        .toList();

    for (final app in apps) {
      app.openCount++;
      await appsBox.put(app.id, app);
    }
  }

  // ✅ NEW: iOS open tracking
  static Future<void> recordIOSAppOpen(String appName) async {
    final key = appName.toLowerCase().trim();
    final current = iosOpenCountsBox.get(key, defaultValue: 0)!;
    await iosOpenCountsBox.put(key, current + 1);
  }

  static int getIOSOpenCount(String appName) {
    final key = appName.toLowerCase().trim();
    return iosOpenCountsBox.get(key, defaultValue: 0)!;
  }

  // ✅ Hard Mode
  static bool get hardModeEnabled =>
      settingsBox.get('settings')?.hardModeEnabled ?? false;

  static Future<void> saveHardMode(bool enabled) async {
    final s = settings;
    s.hardModeEnabled = enabled;
    await settingsBox.put('settings', s);
  }

  // ✅ Global Open Limit
  static int get globalOpenLimit =>
      settingsBox.get('settings')?.globalOpenLimit ?? 0;

  static Future<void> saveGlobalOpenLimit(int limit) async {
    final s = settings;
    s.globalOpenLimit = limit;
    await settingsBox.put('settings', s);
  }
}