import 'dart:async';
import 'package:flutter/material.dart';

class SlidingDelayScreen extends StatefulWidget {
  final int delaySeconds;
  final VoidCallback onFinished;

  const SlidingDelayScreen({
    super.key,
    required this.delaySeconds,
    required this.onFinished,
  });

  @override
  State<SlidingDelayScreen> createState() => _SlidingDelayScreenState();
}

class _SlidingDelayScreenState extends State<SlidingDelayScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<Offset> _topSlide;
  late Animation<Offset> _bottomSlide;

  int secondsLeft = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    secondsLeft = widget.delaySeconds;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 🔥 TOP panel (slides DOWN)
    _topSlide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // 🔥 BOTTOM panel (slides UP)
    _bottomSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    // ⏳ Countdown
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft <= 1) {
        t.cancel();
        widget.onFinished();
      } else {
        setState(() => secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.3), // background visible
      child: Stack(
        children: [
          // 🔷 TOP PANEL
          Align(
            alignment: Alignment.topCenter,
            child: SlideTransition(
              position: _topSlide,
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D1828), Color(0xFF1A2840)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // 🔷 BOTTOM PANEL
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _bottomSlide,
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A2840), Color(0xFF0D1828)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // 🔥 CENTER CONTENT
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$secondsLeft',
                  style: const TextStyle(
                    fontSize: 90,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Take a breath before opening this app",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}