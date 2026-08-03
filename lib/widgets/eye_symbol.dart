import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EyeSymbol extends StatefulWidget {
  final double size;
  final bool glowing;

  const EyeSymbol({super.key, this.size = 80, this.glowing = true});

  @override
  State<EyeSymbol> createState() => _EyeSymbolState();
}

class _EyeSymbolState extends State<EyeSymbol>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) => CustomPaint(
        size: Size(widget.size * 2.2, widget.size * 2.2),
        painter: _EyePainter(
          pulse: _pulse.value,
          glowing: widget.glowing,
          size: widget.size,
        ),
      ),
    );
  }
}

class _EyePainter extends CustomPainter {
  final double pulse;
  final bool glowing;
  final double size;

  _EyePainter({required this.pulse, required this.glowing, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);

    // Concentric rings
    for (int i = 3; i >= 1; i--) {
      final ringRadius = size * 0.52 * i * pulse;
      final ringPaint = Paint()
        ..color = AppColors.blue.withOpacity(0.06 * i)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(center, ringRadius, ringPaint);
    }

    // Glow background circle
    if (glowing) {
      final glowPaint = Paint()
        ..color = AppColors.blue.withOpacity(0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
      canvas.drawCircle(center, size * 0.65 * pulse, glowPaint);
    }

    // Main circle border
    final circlePaint = Paint()
      ..color = AppColors.blue.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, size * 0.55, circlePaint);

    // Dark filled bg
    final bgPaint = Paint()
      ..color = const Color(0xFF0E1B30)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size * 0.52, bgPaint);

    // Eye white outline
    final eyePath = _buildEyePath(center, size * 0.34, size * 0.17);
    final eyePaint = Paint()
      ..color = AppColors.blue.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(eyePath, eyePaint);

    // Iris
    final irisPaint = Paint()
      ..color = AppColors.blue.withOpacity(0.80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, size * 0.10, irisPaint);

    // Pupil
    final pupilPaint = Paint()
      ..color = AppColors.blueLight
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size * 0.04, pupilPaint);
  }

  Path _buildEyePath(Offset center, double halfW, double halfH) {
    final left = Offset(center.dx - halfW, center.dy);
    final right = Offset(center.dx + halfW, center.dy);
    return Path()
      ..moveTo(left.dx, left.dy)
      ..quadraticBezierTo(center.dx, center.dy - halfH, right.dx, right.dy)
      ..quadraticBezierTo(center.dx, center.dy + halfH, left.dx, left.dy)
      ..close();
  }

  @override
  bool shouldRepaint(_EyePainter old) =>
      old.pulse != pulse || old.glowing != glowing;
}
