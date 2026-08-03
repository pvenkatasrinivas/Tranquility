import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/restricted_app.dart';
import 'dart:io';
class ChannelService {
  static const MethodChannel _method =
  MethodChannel('com.tranquility.mobile/control');
  static const EventChannel _event =
  EventChannel('com.tranquility.mobile/foreground_app');

  static void Function(Map<String, dynamic> data)? onForegroundApp;

  static void init() {
    _event.receiveBroadcastStream().listen((dynamic raw) {
      if (raw is Map && onForegroundApp != null) {
        onForegroundApp!(Map<String, dynamic>.from(raw));
      }
    });
  }

  // ── Monitoring ──────────────────────────────────────────────────────────

  static Future<void> startMonitoring() async {
    try {
      await _method.invokeMethod('startMonitoring');
    } on PlatformException catch (e) {
      print('startMonitoring: ${e.message}');
    }
  }

  static Future<void> stopMonitoring() async {
    try {
      await _method.invokeMethod('stopMonitoring');
    } on PlatformException catch (e) {
      print('stopMonitoring: ${e.message}');
    }
  }

  // ── Config ──────────────────────────────────────────────────────────────

  static Future<void> updateRestrictedApps(List<RestrictedApp> apps) async {
    final list =
    apps.where((a) => a.enabled).map((a) => a.packageName).toList();
    try {
      await _method.invokeMethod('updateRestrictedApps', {'packages': list});
    } on PlatformException catch (e) {
      print('updateRestrictedApps: ${e.message}');
    }
  }

  static Future<void> updateDelay(int seconds) async {
    if (!Platform.isIOS) {
      try {
        await _method.invokeMethod('updateDelay', {'seconds': seconds});
      } on PlatformException catch (e) {
        print('updateDelay: ${e.message}');
      }
    }
  }

  // ✅ NEW: Hard Mode sync to Kotlin
  static Future<void> updateHardMode(bool enabled) async {
    try {
      await _method.invokeMethod('updateHardMode', {'enabled': enabled});
    } on PlatformException catch (e) {
      print('updateHardMode: ${e.message}');
    }
  }

  // ✅ NEW: Global Open Limit sync to Kotlin
  static Future<void> updateGlobalOpenLimit(int limit) async {
    try {
      await _method.invokeMethod('updateGlobalOpenLimit', {'limit': limit});
    } on PlatformException catch (e) {
      print('updateGlobalOpenLimit: ${e.message}');
    }
  }

  // ── System settings navigation ───────────────────────────────────────────

  static Future<void> openAccessibilitySettings() async {
    try {
      await _method.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }

  static Future<void> openUsageAccessSettings() async {
    try {
      await _method.invokeMethod('openUsageAccessSettings');
    } catch (_) {}
  }

  // ── Queries ──────────────────────────────────────────────────────────────

  static Future<bool> isAccessibilityEnabled() async {
    try {
      return await _method.invokeMethod<bool>('isAccessibilityEnabled') ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<int> getUsageMinutes(String packageName) async {
    try {
      return await _method.invokeMethod<int>(
          'getUsageMinutes', {'package': packageName}) ??
          0;
    } catch (_) {
      return 0;
    }
  }

  static Future<void> goHome() async {
    try {
      await _method.invokeMethod('goHome');
    } catch (_) {}
  }

  static Future<void> continueToApp() async {
    try {
      await _method.invokeMethod('continueToApp');
    } catch (_) {}
  }

  static Future<List<InstalledAppInfo>> getInstalledApps() async {

    // ✅ FIX: Skip for iOS
    if (Platform.isIOS) {
      return [];
    }

    try {
      final raw =
      await _method.invokeMethod<List<dynamic>>('getInstalledApps');

      if (raw == null) return [];

      return raw
          .whereType<Map>()
          .map((m) => InstalledAppInfo(
        packageName: m['packageName'] as String? ?? '',
        appName: m['appName'] as String? ?? '',
      ))
          .where((a) => a.packageName.isNotEmpty)
          .toList();
    } on PlatformException catch (e) {
      print('getInstalledApps: ${e.message}');
      return [];
    }
  }

  // Optional Helper (used in FocusScreen for better icon fallback - does not affect existing code)
  static IconData getAppIconForPackage(String packageName) {
    final lower = packageName.toLowerCase();
    if (lower.contains('whatsapp')) return Icons.chat_bubble_outline;
    if (lower.contains('youtube')) return Icons.play_circle_outline;
    if (lower.contains('instagram')) return Icons.camera_alt_outlined;
    if (lower.contains('facebook')) return Icons.people_outline;
    if (lower.contains('snapchat')) return Icons.image_outlined;
    if (lower.contains('gmail') || lower.contains('gm')) return Icons.email_outlined;
    return Icons.apps_outlined;
  }
}

class InstalledAppInfo {
  final String packageName;
  final String appName;

  const InstalledAppInfo({
    required this.packageName,
    required this.appName,
  });
}