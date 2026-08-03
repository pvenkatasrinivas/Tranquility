import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/restricted_app.dart';
import '../providers/apps_provider.dart';
import '../services/channel_service.dart';
import '../theme/app_theme.dart';

class AppToggleIcon extends ConsumerWidget {
  final RestrictedApp app;

  const AppToggleIcon({
    super.key,
    required this.app,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = app.enabled;

    return GestureDetector(
      onTap: () {
        ref.read(appsProvider.notifier).toggleApp(app.id);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Container with Glow Effect
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: isEnabled
                  ? [
                BoxShadow(
                  color: const Color(0xFFA4C9FF).withOpacity(0.55),
                  blurRadius: 22,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: const Color(0xFFA4C9FF).withOpacity(0.35),
                  blurRadius: 35,
                  spreadRadius: 10,
                ),
              ]
                  : [],
            ),
            child: Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A2336),
                border: Border.all(
                  color: isEnabled
                      ? const Color(0xFFA4C9FF)
                      : Colors.white.withOpacity(0.18),
                  width: 2.5,
                ),
              ),
              child: ClipOval(
                child: Icon(
                  ChannelService.getAppIconForPackage(app.packageName),
                  color: isEnabled ? const Color(0xFFA4C9FF) : Colors.white70,
                  size: 34,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Status Text
          Text(
            isEnabled ? "Enabled" : "Disabled",
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isEnabled
                  ? const Color(0xFFA4C9FF)
                  : Colors.white.withOpacity(0.55),
              letterSpacing: 0.4,
            ),
          ),

          const SizedBox(height: 3),

          // App Name
          SizedBox(
            width: 78,
            child: Text(
              app.name,
              style: const TextStyle(
                fontSize: 11.5,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}