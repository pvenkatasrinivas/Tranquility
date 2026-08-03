import 'package:flutter/material.dart';   // ← This was missing

class RecentInteraction {
  final IconData icon;
  final String title;
  final String subtitle;
  final String xp;
  final String time;

  RecentInteraction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.xp,
    required this.time,
  });
}