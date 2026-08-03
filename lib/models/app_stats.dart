import 'package:hive/hive.dart';
import 'recent_interaction.dart';

part 'app_stats.g.dart';

@HiveType(typeId: 2)
class AppStats extends HiveObject {
  @HiveField(0)
  int totalSessions;

  @HiveField(1)
  int goodDecisions;

  @HiveField(2)
  int badDecisions;

  @HiveField(3)
  int breathingSessions;

  @HiveField(4)
  int currentStreak;

  @HiveField(5)
  int longestStreak;

  @HiveField(6)
  int xp;

  @HiveField(7)
  String lastSessionDate;

  // ee line add chesa error fix kosam
  @HiveField(8)
  List<RecentInteraction> recentInteractions;

  AppStats({
    this.totalSessions = 0,
    this.goodDecisions = 0,
    this.badDecisions = 0,
    this.breathingSessions = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.xp = 0,
    this.lastSessionDate = '',
    this.recentInteractions = const [],   // default ga empty list
  });
}