// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WaterLogModelAdapter extends TypeAdapter<WaterLogModel> {
  @override
  final int typeId = 3;

  @override
  WaterLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WaterLogModel(
      date: fields[0] as DateTime,
      glassesCount: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WaterLogModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.glassesCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WaterLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
