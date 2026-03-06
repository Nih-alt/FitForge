// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MeasurementModelAdapter extends TypeAdapter<MeasurementModel> {
  @override
  final int typeId = 5;

  @override
  MeasurementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MeasurementModel(
      date: fields[0] as DateTime,
      chest: fields[1] as double,
      waist: fields[2] as double,
      hips: fields[3] as double,
      biceps: fields[4] as double,
      thighs: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, MeasurementModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.chest)
      ..writeByte(2)
      ..write(obj.waist)
      ..writeByte(3)
      ..write(obj.hips)
      ..writeByte(4)
      ..write(obj.biceps)
      ..writeByte(5)
      ..write(obj.thighs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeasurementModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
