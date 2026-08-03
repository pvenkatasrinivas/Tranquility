import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/stats_provider.dart';
import '../theme/app_theme.dart';

enum _Phase { ready, inhale, hold1, exhale, hold2 }

class BreatheScreen extends ConsumerStatefulWidget {
  const BreatheScreen({super.key});

  @override
  ConsumerState<BreatheScreen> createState() => _BreatheScreenState();
}

class _BreatheScreenState extends ConsumerState<BreatheScreen>
    with TickerProviderStateMixin {
  late AnimationController _circleCtrl;
  late AnimationController _arcController;

  _Phase _phase = _Phase.ready;
  int _countdown = 4;
  int _cycles = 0;
  Timer? _timer;
  bool _running = false;

  static const _phaseDurations = {
    _Phase.inhale: 4,
    _Phase.hold1: 4,
    _Phase.exhale: 4,
    _Phase.hold2: 4,
  };

  static const _phaseLabels = {
    _Phase.ready: 'Inhale...',
    _Phase.inhale: 'Inhale...',
    _Phase.hold1: 'Hold...',
    _Phase.exhale: 'Exhale...',
    _Phase.hold2: 'Hold...',
  };

  static const _phaseDescriptions = {
    _Phase.ready: 'Box breathing — 4 · 4 · 4 · 4',
    _Phase.inhale: 'Breathe in through your nose',
    _Phase.hold1: 'Hold your breath',
    _Phase.exhale: 'Breathe out slowly',
    _Phase.hold2: 'Hold before inhaling',
  };

  @override
  void initState() {
    super.initState();
    _circleCtrl = AnimationController(vsync: this);
    _arcController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _circleCtrl.dispose();
    _arcController.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _running = true;
      _cycles = 0;
      _phase = _Phase.inhale;
      _countdown = 4;
    });
    _arcController.repeat();
    _runPhase(_Phase.inhale);
  }

  void _stop() {
    _timer?.cancel();
    _circleCtrl.stop();
    _arcController.stop();
    setState(() {
      _running = false;
      _phase = _Phase.ready;
      _countdown = 4;
      _cycles = 0;
    });
  }

  void _runPhase(_Phase phase) {
    final duration = _phaseDurations[phase]!;
    setState(() {
      _phase = phase;
      _countdown = duration;
    });

    final (begin, end, curve) = switch (phase) {
      _Phase.inhale => (0.5, 1.0, Curves.easeInOut),
      _Phase.exhale => (1.0, 0.5, Curves.easeInOut),
      _ => (_circleCtrl.value, _circleCtrl.value, Curves.linear),
    };

    _circleCtrl.animateTo(
      end,
      duration: Duration(seconds: duration),
      curve: curve,
    );

    _timer?.cancel();
    int elapsed = 0;

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      elapsed++;
      setState(() => _countdown = duration - elapsed);

      if (elapsed >= duration) {
        t.cancel();
        if (!mounted) return;

        final nextPhase = switch (phase) {
          _Phase.inhale => _Phase.hold1,
          _Phase.hold1 => _Phase.exhale,
          _Phase.exhale => _Phase.hold2,
          _Phase.hold2 => () {
            _cycles++;
            if (_cycles >= 4) {
              ref.read(statsProvider.notifier).recordBreathing();
              _stop();
              return _Phase.ready;
            }
            return _Phase.inhale;
          }(),
          _ => _Phase.ready,
        };

        if (nextPhase != _Phase.ready) {
          _runPhase(nextPhase);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1B3E),
              Color(0xFF0A1628),
              Color(0xFF060D1F),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Header
                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 6), // ✅
                //   child: Row(
                //     children: [
                //       Icon(Icons.menu, color: AppColors.textSecondary, size: 22),
                //       const Expanded(
                //         child: Text(
                //           'Tranquility',
                //           textAlign: TextAlign.center,
                //           style: AppTextStyles.h3,
                //         ),
                //       ),
                //       const SizedBox(width: 38),
                //     ],
                //   ),
                // ),
                //
                // const SizedBox(height: 0), // ✅
                const SizedBox(height: 8),
                Text(
                  'TECHNIQUE',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 0), // ✅

                Text(
                  'Box Breathing',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 38,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.9,
                  ),
                ),

                const SizedBox(height: 4), // ✅

                // Rings + Circle
                Center(
                  child: AnimatedBuilder(
                    animation: _circleCtrl,
                    builder: (context, child) {
                      final scale = 0.92 + _circleCtrl.value * 0.16;
                      return SizedBox(
                        width: 285,
                        height: 285,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            _buildRing(281, 0.04),
                            _buildRing(265, 0.05),
                            _buildRing(255, 0.06),
                            Transform.scale(
                              scale: scale,
                              child: _buildBreathingCircle(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 2), // ✅

                Container(
                  width: 6,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA4C9FF).withOpacity(0.35),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),

                const SizedBox(height: 2), // ✅

                _buildMorningFocusCard(),

                const Spacer(),

                if (_running) ...[
                  Text(
                    'Cycle ${_cycles + 1} of 4',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFFA4C9FF).withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                          (i) => Container(
                        width: i < _cycles ? 8 : 6,
                        height: i < _cycles ? 8 : 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < _cycles
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],

                _buildArcButton(),

                const SizedBox(height: 4),

                Text(
                  _running
                      ? '${((_cycles / 4) * 100).toInt()}% of session completed'
                      : '0% of session completed',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFFA4C9FF).withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 0), // ✅
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRing(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFA4C9FF).withOpacity(opacity),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildBreathingCircle() {
    return Container(
      width: 253,
      height: 253,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFF3D5070),
            Color(0xFF2A3D5C),
            Color(0xFF1E2E47),
          ],
          stops: [0.0, 0.5, 1.0],
          center: Alignment.center,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 50,
            spreadRadius: -12,
            offset: const Offset(0, 25),
          ),
          BoxShadow(
            color: const Color(0xFFA4C9FF).withOpacity(0.06),
            blurRadius: 40,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFA4C9FF).withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _phaseLabels[_phase]!,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          if (_running)
            Text(
              '$_countdown',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final bool active = i == _cycles % 4 && _running;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 8 : 6,
                height: active ? 8 : 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMorningFocusCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(48),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF222A3D).withOpacity(0.40),
            borderRadius: BorderRadius.circular(48),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFA4C9FF).withOpacity(0.12),
                  border: Border.all(
                    color: const Color(0xFFA4C9FF).withOpacity(0.2),
                  ),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Color(0xFFA4C9FF),
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Morning Focus',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _phaseDescriptions[_phase]!,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.55,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArcButton() {
    return SizedBox(
      height: 95,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _arcController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(double.infinity, 110),
                painter: _ThreeSegmentArcPainter(_arcController.value),
              );
            },
          ),
          _buildHoldButton(),
        ],
      ),
    );
  }

  Widget _buildHoldButton() {
    return GestureDetector(
      onTap: _running ? _stop : _start,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(32, 12, 32, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: const Color(0xFFA4C9FF),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA4C9FF).withOpacity(0.30),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _running ? 'Stop Session' : 'Hold to Complete',
              style: const TextStyle(
                color: Color(0xFF0A1628),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            _running
                ? const Icon(Icons.stop, color: Color(0xFF0A1628), size: 18)
                : Transform.translate(
              offset: const Offset(0, 1),
              child: const SizedBox(
                width: 22,
                height: 18,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      top: 1,
                      child: Icon(Icons.check,
                          color: Color(0xFF0A1628), size: 16),
                    ),
                    Positioned(
                      left: 8,
                      top: 1,
                      child: Icon(Icons.check,
                          color: Color(0xFF0A1628), size: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreeSegmentArcPainter extends CustomPainter {
  final double progress;

  _ThreeSegmentArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 60,
      height: size.height * 1.85,
    );

    final paint = Paint()
      ..color = const Color(0xFFA4C9FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    const segmentSweep = pi / 3;
    const gap = (2 * pi) / 3;

    for (int i = 0; i < 3; i++) {
      final startAngle = pi / 2 + (progress * 2 * pi) + (i * gap);
      final path = Path()..addArc(rect, startAngle, segmentSweep);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ThreeSegmentArcPainter oldDelegate) =>
      progress != oldDelegate.progress;
}