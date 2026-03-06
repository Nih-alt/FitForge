// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsModelAdapter extends TypeAdapter<AppSettingsModel> {
  @override
  final int typeId = 8;

  @override
  AppSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettingsModel(
      themeMode: fields[0] as String,
      weightUnit: fields[1] as String,
      heightUnit: fields[2] as String,
      workoutReminderOn: fields[3] as bool,
      mealReminderOn: fields[4] as bool,
      waterReminderOn: fields[5] as bool,
      progressUpdateOn: fields[6] as bool,
      achievementOn: fields[7] as bool,
      weeklyWorkoutGoal: fields[8] as int,
      dailyCalorieGoal: fields[9] as int,
      dailyWaterGoal: fields[10] as int,
      dailyStepsGoal: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettingsModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.weightUnit)
      ..writeByte(2)
      ..write(obj.heightUnit)
      ..writeByte(3)
      ..write(obj.workoutReminderOn)
      ..writeByte(4)
      ..write(obj.mealReminderOn)
      ..writeByte(5)
      ..write(obj.waterReminderOn)
      ..writeByte(6)
      ..write(obj.progressUpdateOn)
      ..writeByte(7)
      ..write(obj.achievementOn)
      ..writeByte(8)
      ..write(obj.weeklyWorkoutGoal)
      ..writeByte(9)
      ..write(obj.dailyCalorieGoal)
      ..writeByte(10)
      ..write(obj.dailyWaterGoal)
      ..writeByte(11)
      ..write(obj.dailyStepsGoal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
