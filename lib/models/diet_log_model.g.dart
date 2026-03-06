// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DietLogModelAdapter extends TypeAdapter<DietLogModel> {
  @override
  final int typeId = 2;

  @override
  DietLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DietLogModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      mealType: fields[2] as String,
      foodName: fields[3] as String,
      calories: fields[4] as int,
      protein: fields[5] as double,
      carbs: fields[6] as double,
      fat: fields[7] as double,
      quantity: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DietLogModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.mealType)
      ..writeByte(3)
      ..write(obj.foodName)
      ..writeByte(4)
      ..write(obj.calories)
      ..writeByte(5)
      ..write(obj.protein)
      ..writeByte(6)
      ..write(obj.carbs)
      ..writeByte(7)
      ..write(obj.fat)
      ..writeByte(8)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DietLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
