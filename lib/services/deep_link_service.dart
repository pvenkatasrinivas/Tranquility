import 'dart:async';
import 'package:app_links/app_links.dart';

class DeepLinkService {
  static final _appLinks = AppLinks();
  static StreamSubscription<Uri>? _sub;

  static void Function(String appName, String urlScheme)? onInterventionLink;

  static Future<void> init() async {
    // Handle cold-start (app was closed when Shortcut fired)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (_) {}

    // Handle warm/hot links (app already open in background)
    _sub = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (_) {},
    );
  }

  static void dispose() {
    _sub?.cancel();
  }

  // Expected URL: tranquility://intervention?app=Instagram&scheme=instagram://
  static void _handleUri(Uri uri) {
    if (uri.host != 'intervention') return;

    final appName   = uri.queryParameters['app']    ?? 'App';
    final urlScheme = uri.queryParameters['scheme'] ?? '';

    if (onInterventionLink != null) {
      onInterventionLink!(appName, urlScheme);
    }
  }
}