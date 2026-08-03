import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/restricted_app.dart';
import '../services/hive_service.dart';
import '../services/channel_service.dart';

class AppsNotifier extends Notifier<List<RestrictedApp>> {
  @override
  List<RestrictedApp> build() {
    return HiveService.restrictedApps;
  }

  Future<void> addApp(RestrictedApp app) async {
    // Prevent duplicate by packageName
    final exists = state.any((a) => a.packageName == app.packageName);
    if (exists) return;

    await HiveService.addRestrictedApp(app);
    state = HiveService.restrictedApps;
    ChannelService.updateRestrictedApps(state);
  }

  Future<void> removeApp(String id) async {
    await HiveService.removeRestrictedApp(id);
    state = HiveService.restrictedApps;
    ChannelService.updateRestrictedApps(state);
  }

  Future<void> toggleApp(String id) async {
    final app = state.firstWhere((a) => a.id == id);
    app.enabled = !app.enabled;
    await HiveService.updateApp(app);
    state = HiveService.restrictedApps;
    ChannelService.updateRestrictedApps(state);
  }

  Future<void> recordOpen(String packageName) async {
    await HiveService.recordAppOpen(packageName);
    state = HiveService.restrictedApps;
  }

  Future<void> refreshUsage() async {
    for (final app in state) {
      final mins = await ChannelService.getUsageMinutes(app.packageName);
      app.usageMinutes = mins;
      await HiveService.updateApp(app);
    }
    state = HiveService.restrictedApps;
  }

  // ✅ ADD THIS METHOD (Fix for your error)
  void syncOpenCount(String packageName, int openCount) {
    final index = state.indexWhere((a) => a.packageName == packageName);
    if (index == -1) return;

    final app = state[index];
    app.openCount = openCount;

    HiveService.updateApp(app);
    state = [...state];
  }

  // NEW HELPER: Ensure default 6 apps exist (called from FocusScreen)
  Future<void> ensureDefaultApps() async {
    final defaultApps = [
      {'name': 'WhatsApp', 'packageName': 'com.whatsapp'},
      {'name': 'YouTube', 'packageName': 'com.google.android.youtube'},
      {'name': 'Instagram', 'packageName': 'com.instagram.android'},
      {'name': 'Facebook', 'packageName': 'com.facebook.katana'},
      {'name': 'Snapchat', 'packageName': 'com.snapchat.android'},
      {'name': 'Gmail', 'packageName': 'com.google.android.gm'},
    ];

    final existingPackages = state.map((a) => a.packageName).toSet();

    for (final def in defaultApps) {
      if (!existingPackages.contains(def['packageName'])) {
        final newApp = RestrictedApp(
          id: def['packageName']!,
          name: def['name']!,
          packageName: def['packageName']!,
          enabled: false,
        );
        await addApp(newApp);   // Uses the duplicate-safe addApp above
      }
    }
  }
}

final appsProvider =
NotifierProvider<AppsNotifier, List<RestrictedApp>>(AppsNotifier.new);