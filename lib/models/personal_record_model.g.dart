// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonalRecordModelAdapter extends TypeAdapter<PersonalRecordModel> {
  @override
  final int typeId = 7;

  @override
  PersonalRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonalRecordModel(
      exerciseName: fields[0] as String,
      value: fields[1] as double,
      unit: fields[2] as String,
      date: fields[3] as DateTime,
      history: (fields[4] as List)
          .map((dynamic e) => (e as Map).cast<dynamic, dynamic>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, PersonalRecordModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.exerciseName)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.history);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
