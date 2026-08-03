import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';
import '../widgets/gradient_background.dart';
import '../theme/app_theme.dart';
import '../models/recent_interaction.dart';
import '../widgets/recent_interactions.dart';

import 'deep_dive_screen.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);

    final total = stats.goodDecisions + stats.badDecisions;
    final resistRate = total == 0 ? 0.0 : stats.goodDecisions / total;

    return GradientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row(
              //   children: [
              //     Icon(Icons.menu, color: AppColors.textSecondary, size: 22),
              //     const Expanded(
              //       child: Text('Tranquility', textAlign: TextAlign.center, style: AppTextStyles.h3),
              //     ),
              //     const SizedBox(width: 38),
              //   ],
              // ),
              // const SizedBox(height: 8),

              const Text('Your Progress', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Tracking your journey since January', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 32),

              _buildMindfulnessCard(context, resistRate),

              const SizedBox(height: 24),

              _buildDailyStreakCard(stats),

              const SizedBox(height: 32),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildSmallStatCard(Icons.shield_outlined, const Color(0xFF4CAF50), '${stats.goodDecisions}', 'Resisted'),
                  _buildSmallStatCard(Icons.timer_outlined, const Color(0xFF2196F3), '${stats.totalSessions}', 'Sessions'),
                  _buildSmallStatCard(Icons.air, const Color(0xFF9C27B0), '${stats.breathingSessions}', 'Breathing'),
                  _buildSmallStatCard(Icons.star_outline, const Color(0xFFFFC107), '${stats.xp}', 'XP Earned'),
                ],
              ),

              const SizedBox(height: 32),

              const RecentInteractionsWidget(),

              const SizedBox(height: 40),

              _buildTranscendCard(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallStatCard(IconData icon, Color color, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2A44).withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
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

  Widget _buildMindfulnessCard(BuildContext context, double resistRate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
      ),
      child: Column(
        children: [
          const Text('Mindfulness Mastery', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Text(
            'You\'ve reached a state of deep focus for ${(resistRate * 100).round()}% of your recorded sessions this week.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 24),
          Container(
            width: 140,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFA4C9FF), Color(0xFF4A7CC7)]),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeepDiveScreen(),
                  ),
                );
              },
              child: const Text('Deep Dive', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 32),
          _buildCircularProgress(resistRate * 100),
        ],
      ),
    );
  }

  Widget _buildDailyStreakCard(dynamic stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daily Streak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.gold, size: 20),
                  const SizedBox(width: 6),
                  Text('${stats.currentStreak} Days', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.gold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildStreakGraph(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Next reward in 3 days', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              TextButton(onPressed: () {}, child: const Text('View Rewards', style: TextStyle(fontSize: 12, color: AppColors.blueLight, fontWeight: FontWeight.w600))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTranscendCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
      ),
      child: Column(
        children: [
          const Text('Ready to transcend?', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          const Text(
            'Unlock your advanced neurological profile and see how your patterns compare to the Tranquility community.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA4C9FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999))),
              child: const Text('Get Premium Access', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.textPrimary, side: BorderSide(color: Colors.white.withOpacity(0.15)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999))),
              child: const Text('Explore Analytics', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(double percent) {
    return SizedBox(
      width: 210,
      height: 210,
      child: CustomPaint(
        painter: _CircularProgressPainter(percent: percent),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${percent.toInt()}%', style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const Text('INTENTIONAL', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, letterSpacing: 2)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakGraph() {
    return SizedBox(
      height: 90,
      child: CustomPaint(size: const Size(double.infinity, 90), painter: _StreakGraphPainter()),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double percent;
  _CircularProgressPainter({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 14;
    const stroke = 13.0;

    canvas.drawCircle(center, radius, Paint()
      ..color = AppColors.border.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke);

    final progressPaint = Paint()
      ..color = const Color(0xFFA4C9FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final sweep = 2 * pi * (percent / 100);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, sweep, false, progressPaint);

    final glowPaint = Paint()
      ..color = const Color(0xFFA4C9FF).withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke + 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, sweep, false, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _StreakGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [0.35, 0.65, 0.45, 0.8, 0.6, 0.9, 0.75];
    final spacing = size.width / (points.length - 1);
    final linePaint = Paint()
      ..color = const Color(0xFFA4C9FF).withOpacity(0.75)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      final x1 = i * spacing;
      final y1 = size.height * (1 - points[i]);
      final x2 = (i + 1) * spacing;
      final y2 = size.height * (1 - points[i + 1]);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
    }

    final dotPaint = Paint()..color = const Color(0xFFA4C9FF);
    for (int i = 0; i < points.length; i++) {
      final x = i * spacing;
      final y = size.height * (1 - points[i]);
      canvas.drawCircle(Offset(x, y), 4.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}