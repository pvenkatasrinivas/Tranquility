import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';
import '../models/recent_interaction.dart';
import '../theme/app_theme.dart';

class RecentInteractionsWidget extends ConsumerWidget {
  const RecentInteractionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Interactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            TextButton(
              onPressed: () {},
              child: const Text('See full log', style: TextStyle(fontSize: 12, color: AppColors.blueLight)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Column(
          children: stats.recentInteractions.isEmpty
              ? _buildExampleInteractionCards()
              : stats.recentInteractions.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildInteractionCard(
              icon: item.icon!,
              iconColor: const Color(0xFF1E88E5),
              title: item.title!,
              subtitle: item.subtitle!,
              xp: item.xp!,
              time: item.time!,
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildInteractionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String xp,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2A44).withOpacity(0.9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(xp, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.blueLight)),
              const SizedBox(height: 4),
              Text(time, style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExampleInteractionCards() {
    return [
      _buildInteractionCard(icon: Icons.center_focus_strong, iconColor: const Color(0xFF1E88E5), title: 'Deep Focus Session', subtitle: 'Completed 45 minutes of stillness', xp: '+250 XP', time: '2H AGO'),
      const SizedBox(height: 12),
      _buildInteractionCard(icon: Icons.air, iconColor: const Color(0xFF26C6DA), title: 'Evening Breathwork', subtitle: 'Balanced heart-rate coherence', xp: '+120 XP', time: 'YESTERDAY'),
      const SizedBox(height: 12),
      _buildInteractionCard(icon: Icons.edit_note, iconColor: const Color(0xFF7E57C2), title: 'Morning settingsing', subtitle: 'Captured three points of gratitude', xp: '+50 XP', time: 'YESTERDAY'),
      const SizedBox(height: 12),
      _buildInteractionCard(icon: Icons.workspace_premium, iconColor: const Color(0xFF8BC34A), title: 'Zen Master Unlocked', subtitle: 'New badge earned for weekly consistency', xp: 'REWARD', time: '2 DAYS AGO'),
    ];
  }
}