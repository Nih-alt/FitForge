import 'package:hive/hive.dart';

part 'app_settings_model.g.dart';

@HiveType(typeId: 8)
class AppSettingsModel extends HiveObject {
  @HiveField(0)
  String themeMode;

  @HiveField(1)
  String weightUnit;

  @HiveField(2)
  String heightUnit;

  @HiveField(3)
  bool workoutReminderOn;

  @HiveField(4)
  bool mealReminderOn;

  @HiveField(5)
  bool waterReminderOn;

  @HiveField(6)
  bool progressUpdateOn;

  @HiveField(7)
  bool achievementOn;

  @HiveField(8)
  int weeklyWorkoutGoal;

  @HiveField(9)
  int dailyCalorieGoal;

  @HiveField(10)
  int dailyWaterGoal;

  @HiveField(11)
  int dailyStepsGoal;

  @HiveField(12)
  int workoutReminderHour;

  @HiveField(13)
  int workoutReminderMinute;

  AppSettingsModel({
    this.themeMode = 'system',
    this.weightUnit = 'kg',
    this.heightUnit = 'cm',
    this.workoutReminderOn = true,
    this.mealReminderOn = false,
    this.waterReminderOn = false,
    this.progressUpdateOn = true,
    this.achievementOn = true,
    this.weeklyWorkoutGoal = 4,
    this.dailyCalorieGoal = 2000,
    this.dailyWaterGoal = 8,
    this.dailyStepsGoal = 10000,
    this.workoutReminderHour = 8,
    this.workoutReminderMinute = 0,
  });
}
