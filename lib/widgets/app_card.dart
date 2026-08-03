import 'package:flutter/material.dart';
import '../models/restricted_app.dart';
import '../theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final RestrictedApp app;
  final VoidCallback onTap;

  const AppCard({super.key, required this.app, required this.onTap});

  String _formatMins(int mins) {
    if (mins == 0) return '0m used';
    if (mins < 60) return '${mins}m used';
    final h = mins ~/ 60;
    final m = mins % 60;
    return m > 0 ? '${h}h ${m}m used' : '${h}h used';
  }

  IconData _iconForApp(String packageName) {
    if (packageName.contains('instagram')) return Icons.camera_alt_outlined;
    if (packageName.contains('tiktok') || packageName.contains('musically')) return Icons.music_note_outlined;
    if (packageName.contains('whatsapp')) return Icons.chat_bubble_outline;
    if (packageName.contains('youtube')) return Icons.play_circle_outline;
    if (packageName.contains('twitter') || packageName.contains('x.android')) return Icons.flutter_dash;
    if (packageName.contains('facebook')) return Icons.people_outline;
    if (packageName.contains('snapchat')) return Icons.image_outlined;
    if (packageName.contains('reddit')) return Icons.forum_outlined;
    if (packageName.contains('netflix')) return Icons.tv_outlined;
    if (packageName.contains('chrome')) return Icons.language_outlined;
    if (packageName.contains('telegram')) return Icons.send_outlined;
    if (packageName.contains('linkedin')) return Icons.business_center_outlined;
    return Icons.apps_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF141F35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderFaint,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App icon in rounded square
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.blue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconForApp(app.packageName),
                color: AppColors.blueLight,
                size: 20,
              ),
            ),
            const SizedBox(height: 10),
            // App name
            Text(
              app.name,
              style: AppTextStyles.body.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Usage stats
            Flexible(
              child: Text(
                '${app.openCount} opens · ${_formatMins(app.usageMinutes)}',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
