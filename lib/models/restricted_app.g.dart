// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restricted_app.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RestrictedAppAdapter extends TypeAdapter<RestrictedApp> {
  @override
  final int typeId = 0;

  @override
  RestrictedApp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RestrictedApp(
      id: fields[0] as String,
      name: fields[1] as String,
      packageName: fields[2] as String,
      enabled: fields[3] as bool,
      openCount: fields[4] as int,
      usageMinutes: fields[5] as int,
      dailyAverage: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RestrictedApp obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.packageName)
      ..writeByte(3)
      ..write(obj.enabled)
      ..writeByte(4)
      ..write(obj.openCount)
      ..writeByte(5)
      ..write(obj.usageMinutes)
      ..writeByte(6)
      ..write(obj.dailyAverage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestrictedAppAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
