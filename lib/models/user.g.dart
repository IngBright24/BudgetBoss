// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 4;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      email: fields[0] as String,
      phone: fields[1] as String,
      registrationDate: fields[2] as DateTime,
      name: fields[3] as String,
      pin: fields[4] as String,
      password: fields[5] as String?,
      isEmailVerified: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.registrationDate)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.pin)
      ..writeByte(5)
      ..write(obj.password)
      ..writeByte(6)
      ..write(obj.isEmailVerified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
