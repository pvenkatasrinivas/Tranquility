// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 1;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      delaySeconds: fields[0] as int,
      silentMode: fields[1] as bool,
      quickPause: fields[2] as bool,
      hardModeEnabled: fields[3] as bool,
      globalOpenLimit: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.delaySeconds)
      ..writeByte(1)
      ..write(obj.silentMode)
      ..writeByte(2)
      ..write(obj.quickPause)
      ..writeByte(3)
      ..write(obj.hardModeEnabled)
      ..writeByte(4)
      ..write(obj.globalOpenLimit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
