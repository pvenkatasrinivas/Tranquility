import 'package:flutter/services.dart';
import 'dart:io';

class IOSChannelService {
  static const MethodChannel _channel =
  MethodChannel('com.tranquility.mobile/ios_control');

  // Send user to home screen (they chose Cancel)
  static Future<void> goHome() async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('goHome');
    } catch (_) {}
  }

  // Re-open the original app (they chose Continue)
  static Future<bool> openApp(String urlScheme) async {
    if (!Platform.isIOS) return false;
    try {
      final result = await _channel.invokeMethod<bool>(
        'openApp',
        {'urlScheme': urlScheme},
      );
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  // Get URL scheme from app name or package name
  static String getUrlScheme(String appIdentifier) {
    final lower = appIdentifier.toLowerCase();
    if (lower.contains('instagram'))  return 'instagram://';
    if (lower.contains('youtube'))    return 'youtube://';
    if (lower.contains('whatsapp'))   return 'whatsapp://';
    if (lower.contains('facebook'))   return 'fb://';
    if (lower.contains('snapchat'))   return 'snapchat://';
    if (lower.contains('tiktok'))     return 'snssdk1233://';
    if (lower.contains('twitter'))    return 'twitter://';
    if (lower.contains('reddit'))     return 'reddit://';
    if (lower.contains('telegram'))   return 'tg://';
    return '$lower://';
  }
}