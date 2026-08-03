import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/eye_symbol.dart';
import '../theme/app_theme.dart';

/// Full-screen intervention shown when a restricted app is opened.
/// Matches the reference design: LOW badge, stats row, gradient button.
class InterventionScreen extends StatefulWidget {
  final String appName;
  final int openCount;
  final int usageMinutes;
  final VoidCallback onCancel;
  final VoidCallback? onContinue;   // ✅ changed to nullable because blocked case lo null undochu
  final bool isBlocked;             // ✅ NEW parameter

  const InterventionScreen({
    super.key,
    required this.appName,
    required this.openCount,
    required this.usageMinutes,
    required this.onCancel,
    required this.onContinue,
    this.isBlocked = false,         // ✅ default false
  });

  @override
  State<InterventionScreen> createState() => _InterventionScreenState();
}

class _InterventionScreenState extends State<InterventionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  // Hold-to-continue progress
  double _holdProgress = 0.0;
  Timer? _holdTimer;
  bool _holding = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
        begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _holdTimer?.cancel();
    super.dispose();
  }

  // ── Hold-to-continue logic ──────────────────────────────────────────────

  void _startHold() {
    if (widget.isBlocked) return;   // blocked ayithe hold work avakudadu

    setState(() {
      _holding = true;
      _holdProgress = 0.0;
    });
    _holdTimer = Timer.periodic(const Duration(milliseconds: 30), (t) {
      setState(() => _holdProgress += 0.03);
      if (_holdProgress >= 1.0) {
        t.cancel();
        widget.onContinue?.call();   // safe call because nullable
      }
    });
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    setState(() {
      _holding = false;
      _holdProgress = 0.0;
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  String _usageLabel() {
    if (widget.usageMinutes == 0) return '0m';
    if (widget.usageMinutes < 60) return '${widget.usageMinutes}m';
    final h = widget.usageMinutes ~/ 60;
    final m = widget.usageMinutes % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  String _riskLabel() {
    if (widget.openCount <= 2) return 'LOW';
    if (widget.openCount <= 5) return 'MEDIUM';
    return 'HIGH';
  }

  Color _riskColor() {
    if (widget.openCount <= 2) return const Color(0xFF4CAF83);
    if (widget.openCount <= 5) return const Color(0xFFE8A843);
    return const Color(0xFFE85858);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FadeTransition(
        opacity: _fade,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xF00D1828), Color(0xF50B1120)],
            ),
          ),
          child: SafeArea(
            child: SlideTransition(
              position: _slide,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // ── Eye symbol ────────────────────────────────────
                    const EyeSymbol(size: 65, glowing: true),
                    const SizedBox(height: 28),

                    // ── Risk badge ────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: _riskColor().withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _riskColor(), width: 1.5),
                      ),
                      child: Text(
                        _riskLabel(),
                        style: TextStyle(
                          color: _riskColor(),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Open count headline ───────────────────────────
                    Text(
                      "You've opened ${widget.appName} ${widget.openCount} ${widget.openCount == 1 ? 'time' : 'times'} today.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Subtext ───────────────────────────────────────
                    const Text(
                      'Is this the best use of your time?\nFocus is a limited resource.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Stats row ─────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderFaint),
                      ),
                      child: Row(
                        children: [
                          _StatCell(
                            label: 'SESSION',
                            value: widget.openCount
                                .toString()
                                .padLeft(2, '0'),
                            color: AppColors.textPrimary,
                          ),
                          _VertDivider(),
                          _StatCell(
                            label: 'USED TODAY',
                            value: _usageLabel(),
                            color: AppColors.textPrimary,
                          ),
                          _VertDivider(),
                          _StatCell(
                            label: 'DAILY LIMIT',
                            value: '30m',
                            color: const Color(0xFF4CAF83),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ✅ BLOCKED MESSAGE - if isBlocked true
                    if (widget.isBlocked) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE85858).withOpacity(0.10),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE85858).withOpacity(0.3),
                          ),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.block, color: Color(0xFFE85858), size: 28),
                            SizedBox(height: 8),
                            Text(
                              "You've reached today's limit",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFE85858),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Disable Hard Mode in settings to continue.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFE85858),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // ── Cancel & Close (primary blue gradient) ─────────
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: widget.onCancel,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          elevation: 0,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF3A6BC9),
                                Color(0xFF5B8FE8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '✕  Cancel & Close',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ✅ Continue button - only show if NOT blocked
                    if (!widget.isBlocked) ...[
                      // ── Hold to Continue (dark outlined) ─────────────
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: GestureDetector(
                          onLongPressStart: (_) => _startHold(),
                          onLongPressEnd: (_) => _cancelHold(),
                          onLongPressCancel: () => _cancelHold(),
                          child: Stack(
                            children: [
                              // Progress fill
                              if (_holdProgress > 0)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: LinearProgressIndicator(
                                    value: _holdProgress,
                                    minHeight: 56,
                                    backgroundColor: Colors.transparent,
                                    valueColor:
                                    const AlwaysStoppedAnimation(
                                      Color(0xFF1E3050),
                                    ),
                                  ),
                                ),
                              // Button border & label
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _holding
                                      ? 'Keep holding…'
                                      : 'Hold to Continue to App  →',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: _holding
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Small helpers ───────────────────────────────────────────────────────────

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCell(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    ),
  );
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 40, color: AppColors.borderFaint);
}