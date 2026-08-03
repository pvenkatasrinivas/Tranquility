import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_stats.dart';
import '../services/hive_service.dart';
import '../models/recent_interaction.dart';

class StatsNotifier extends Notifier<AppStats> {
  @override
  AppStats build() {
    return HiveService.stats;
  }

  Future<void> recordGoodDecision() async {
    final s = state;
    state = AppStats(
      totalSessions: s.totalSessions,
      goodDecisions: s.goodDecisions + 1,
      badDecisions: s.badDecisions,
      breathingSessions: s.breathingSessions,
      currentStreak: s.currentStreak,
      longestStreak: s.longestStreak,
      xp: s.xp + 15,
      lastSessionDate: s.lastSessionDate,
      recentInteractions: s.recentInteractions,
    );

    final interaction = RecentInteraction(
      icon: Icons.shield,
      title: 'Good Decision',
      subtitle: 'You resisted the urge successfully',
      xp: '+15 XP',
      time: 'Just now',
    );
    addRecentInteraction(interaction);

    await HiveService.saveStats(state);
  }

  Future<void> recordBadDecision() async {
    final s = state;
    state = AppStats(
      totalSessions: s.totalSessions,
      goodDecisions: s.goodDecisions,
      badDecisions: s.badDecisions + 1,
      breathingSessions: s.breathingSessions,
      currentStreak: s.currentStreak,
      longestStreak: s.longestStreak,
      xp: s.xp,
      lastSessionDate: s.lastSessionDate,
      recentInteractions: s.recentInteractions,
    );

    final interaction = RecentInteraction(
      icon: Icons.warning_amber,
      title: 'Bad Decision',
      subtitle: 'You gave in this time',
      xp: '0 XP',
      time: 'Just now',
    );
    addRecentInteraction(interaction);

    await HiveService.saveStats(state);
  }

  Future<void> recordBreathing() async {
    final s = state;

    final updatedStats = AppStats(
      totalSessions: s.totalSessions,
      goodDecisions: s.goodDecisions,
      badDecisions: s.badDecisions,
      breathingSessions: s.breathingSessions + 1,
      currentStreak: s.currentStreak,
      longestStreak: s.longestStreak,
      xp: s.xp + 10,
      lastSessionDate: s.lastSessionDate,
      recentInteractions: s.recentInteractions,
    );

    state = updatedStats;

    final interaction = RecentInteraction(
      icon: Icons.air,
      title: 'Breathing Session Completed',
      subtitle: 'Calm achieved • Heart rate balanced',
      xp: '+10 XP',
      time: 'Just now',
    );

    addRecentInteraction(interaction);
  }

  Future<void> recordFocusSession() async {
    final s = state;
    final newStreak = s.currentStreak + 1;
    state = AppStats(
      totalSessions: s.totalSessions + 1,
      goodDecisions: s.goodDecisions,
      badDecisions: s.badDecisions,
      breathingSessions: s.breathingSessions,
      currentStreak: newStreak,
      longestStreak: newStreak > s.longestStreak ? newStreak : s.longestStreak,
      xp: s.xp + 50,
      lastSessionDate: DateTime.now().toIso8601String(),
      recentInteractions: s.recentInteractions,
    );

    final interaction = RecentInteraction(
      icon: Icons.center_focus_strong,
      title: 'Deep Focus Session',
      subtitle: 'Completed focused work',
      xp: '+50 XP',
      time: 'Just now',
    );
    addRecentInteraction(interaction);

    await HiveService.saveStats(state);
  }

  // ==================== RECENT INTERACTIONS - FULL DYNAMIC IMPLEMENTATION ====================
  void addRecentInteraction(RecentInteraction interaction) {
    final current = state;

    List<RecentInteraction> updatedList = List.from(current.recentInteractions);
    updatedList.add(interaction);

    if (updatedList.length > 8) {
      updatedList.removeAt(0);
    }

    final newState = AppStats(
      totalSessions: current.totalSessions,
      goodDecisions: current.goodDecisions,
      badDecisions: current.badDecisions,
      breathingSessions: current.breathingSessions,
      currentStreak: current.currentStreak,
      longestStreak: current.longestStreak,
      xp: current.xp,
      lastSessionDate: current.lastSessionDate,
      recentInteractions: updatedList,
    );

    state = newState;
    HiveService.saveStats(newState);
  }
// ========================================================================
}

final statsProvider = NotifierProvider<StatsNotifier, AppStats>(StatsNotifier.new);