import 'package:hive_flutter/hive_flutter.dart';

part 'restricted_app.g.dart';

@HiveType(typeId: 0)
class RestrictedApp {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String packageName;

  @HiveField(3)
  bool enabled;

  @HiveField(4)
  int openCount;

  @HiveField(5)
  int usageMinutes;

  @HiveField(6)
  String dailyAverage;

  RestrictedApp({
    required this.id,
    required this.name,
    required this.packageName,
    this.enabled = false,
    this.openCount = 0,
    this.usageMinutes = 0,
    this.dailyAverage = '0m',
  });

  // Optional: Helper method (does not affect existing functionality)
  RestrictedApp copyWith({
    String? id,
    String? name,
    String? packageName,
    bool? enabled,
    int? openCount,
    int? usageMinutes,
    String? dailyAverage,
  }) {
    return RestrictedApp(
      id: id ?? this.id,
      name: name ?? this.name,
      packageName: packageName ?? this.packageName,
      enabled: enabled ?? this.enabled,
      openCount: openCount ?? this.openCount,
      usageMinutes: usageMinutes ?? this.usageMinutes,
      dailyAverage: dailyAverage ?? this.dailyAverage,
    );
  }
}
