// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationPreferencesAdapter
    extends TypeAdapter<NotificationPreferences> {
  @override
  final int typeId = 7;

  @override
  NotificationPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationPreferences(
      appEnabled: fields[0] as bool,
      emailEnabled: fields[1] as bool,
      smsEnabled: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationPreferences obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.appEnabled)
      ..writeByte(1)
      ..write(obj.emailEnabled)
      ..writeByte(2)
      ..write(obj.smsEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
