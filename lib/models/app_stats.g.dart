// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppStatsAdapter extends TypeAdapter<AppStats> {
  @override
  final int typeId = 2;

  @override
  AppStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppStats(
      totalSessions: fields[0] as int,
      goodDecisions: fields[1] as int,
      badDecisions: fields[2] as int,
      breathingSessions: fields[3] as int,
      currentStreak: fields[4] as int,
      longestStreak: fields[5] as int,
      xp: fields[6] as int,
      lastSessionDate: fields[7] as String,
      recentInteractions: (fields[8] as List).cast<RecentInteraction>(),
    );
  }

  @override
  void write(BinaryWriter writer, AppStats obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.totalSessions)
      ..writeByte(1)
      ..write(obj.goodDecisions)
      ..writeByte(2)
      ..write(obj.badDecisions)
      ..writeByte(3)
      ..write(obj.breathingSessions)
      ..writeByte(4)
      ..write(obj.currentStreak)
      ..writeByte(5)
      ..write(obj.longestStreak)
      ..writeByte(6)
      ..write(obj.xp)
      ..writeByte(7)
      ..write(obj.lastSessionDate)
      ..writeByte(8)
      ..write(obj.recentInteractions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
