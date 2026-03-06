// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutLogModelAdapter extends TypeAdapter<WorkoutLogModel> {
  @override
  final int typeId = 1;

  @override
  WorkoutLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutLogModel(
      id: fields[0] as String,
      workoutName: fields[1] as String,
      date: fields[2] as DateTime,
      durationSeconds: fields[3] as int,
      caloriesBurned: fields[4] as int,
      exercisesCompleted: fields[5] as int,
      exercises: (fields[6] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutLogModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.workoutName)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.durationSeconds)
      ..writeByte(4)
      ..write(obj.caloriesBurned)
      ..writeByte(5)
      ..write(obj.exercisesCompleted)
      ..writeByte(6)
      ..write(obj.exercises);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
