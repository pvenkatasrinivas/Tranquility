import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';
import '../theme/app_theme.dart';

class DeepDiveScreen extends ConsumerWidget {
  const DeepDiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);

    final total = stats.goodDecisions + stats.badDecisions;
    final rate = total == 0 ? 0.0 : stats.goodDecisions / total;

    final weeklyData = _generateWeeklyData(rate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Deep Dive"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 80), // ✅ bottom 40 fix
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 WEEKLY GRAPH
            const Text("Weekly Trend", style: AppTextStyles.h2),
            const SizedBox(height: 16), // ✅ even spacing

            _buildGraphCard(weeklyData),

            const SizedBox(height: 24), // ✅ even spacing

            /// 🔹 INSIGHTS
            const Text("Smart Insights", style: AppTextStyles.h2),
            const SizedBox(height: 12),

            _buildInsight("🔥 You are ${(rate * 100).toInt()}% consistent this week"),
            _buildInsight("📈 Total sessions: ${stats.totalSessions}"),
            _buildInsight("🏆 Current streak: ${stats.currentStreak} days"),

            const SizedBox(height: 24), // ✅ even spacing

            /// 🔹 SUMMARY
            const Text("Summary", style: AppTextStyles.h2),
            const SizedBox(height: 12),

            _buildSummaryCard(stats),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphCard(List<double> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 120,
            width: double.infinity, // ✅ full width
            child: CustomPaint(
              painter: _GraphPainter(data),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("M", style: TextStyle(color: AppColors.textMuted)),
              Text("T", style: TextStyle(color: AppColors.textMuted)),
              Text("W", style: TextStyle(color: AppColors.textMuted)),
              Text("T", style: TextStyle(color: AppColors.textMuted)),
              Text("F", style: TextStyle(color: AppColors.textMuted)),
              Text("S", style: TextStyle(color: AppColors.textMuted)),
              Text("S", style: TextStyle(color: AppColors.textMuted)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInsight(String text) {
    return Container(
      width: double.infinity, // ✅ full width fix
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: AppTextStyles.body),
    );
  }

  Widget _buildSummaryCard(dynamic stats) {
    return Container(
      width: double.infinity, // ✅ full width
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _row("Good Decisions", stats.goodDecisions.toString()),
          _row("Bad Decisions", stats.badDecisions.toString()),
          _row("Breathing Sessions", stats.breathingSessions.toString()),
          _row("XP Earned", stats.xp.toString()),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMuted),
          Text(value, style: AppTextStyles.body),
        ],
      ),
    );
  }

  List<double> _generateWeeklyData(double rate) {
    return [
      max(0.1, rate * 0.6),
      max(0.1, rate * 0.7),
      max(0.1, rate * 0.8),
      max(0.1, rate * 0.9),
      max(0.1, rate * 0.75),
      max(0.1, rate * 1.0),
      max(0.1, rate * 0.85),
    ];
  }
}

class _GraphPainter extends CustomPainter {
  final List<double> points;

  _GraphPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final spacing = size.width / (points.length - 1);

    final paintLine = Paint()
      ..color = AppColors.blueLight
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      final x1 = i * spacing;
      final y1 = size.height * (1 - points[i]);

      final x2 = (i + 1) * spacing;
      final y2 = size.height * (1 - points[i + 1]);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paintLine);
    }

    final dotPaint = Paint()..color = AppColors.blueLight;

    for (int i = 0; i < points.length; i++) {
      final x = i * spacing;
      final y = size.height * (1 - points[i]);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}