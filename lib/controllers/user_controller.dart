import 'package:get/get.dart';

import '../models/app_settings_model.dart';
import '../models/user_model.dart';
import '../models/weight_log_model.dart';
import '../services/hive_service.dart';

class UserController extends GetxController {
  final _hive = Get.find<HiveService>();

  final user = Rxn<UserModel>();
  late final Rx<AppSettingsModel> settings;

  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    settings = Rx<AppSettingsModel>(AppSettingsModel());
    loadUser();
    loadSettings();
  }

  void loadUser() {
    try {
      user.value = _hive.getUser();
    } catch (e) {
      user.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveNewUser(UserModel model) async {
    try {
      await _hive.saveUser(model);
      user.value = _hive.getUser();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser({
    String? name,
    int? age,
    double? weight,
    double? height,
    String? goal,
    String? profilePhotoPath,
  }) async {
    final current = user.value;
    if (current == null) return;

    try {
      if (name != null) current.name = name;
      if (age != null) current.age = age;
      if (height != null) current.height = height;
      if (goal != null) current.goal = goal;
      if (profilePhotoPath != null) current.profilePhotoPath = profilePhotoPath;

      final oldWeight = current.weight;
      if (weight != null) current.weight = weight;

      await _hive.saveUser(current);
      user.refresh();

      if (weight != null && weight != oldWeight) {
        await _hive.saveWeightLog(WeightLogModel(
          date: DateTime.now(),
          weight: weight,
        ));
      }
    } catch (e) {
      rethrow;
    }
  }

  void loadSettings() {
    try {
      settings.value = _hive.getSettings();
    } catch (e) {
      settings.value = AppSettingsModel();
    }
  }

  Future<void> saveSettings(AppSettingsModel model) async {
    try {
      await _hive.saveSettings(model);
      settings.value = _hive.getSettings();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSettings({
    String? themeMode,
    String? weightUnit,
    String? heightUnit,
    bool? workoutReminderOn,
    bool? mealReminderOn,
    bool? waterReminderOn,
    bool? progressUpdateOn,
    bool? achievementOn,
    int? weeklyWorkoutGoal,
    int? dailyCalorieGoal,
    int? dailyWaterGoal,
    int? dailyStepsGoal,
    int? workoutReminderHour,
    int? workoutReminderMinute,
  }) async {
    final s = settings.value;
    try {
      if (themeMode != null) s.themeMode = themeMode;
      if (weightUnit != null) s.weightUnit = weightUnit;
      if (heightUnit != null) s.heightUnit = heightUnit;
      if (workoutReminderOn != null) s.workoutReminderOn = workoutReminderOn;
      if (mealReminderOn != null) s.mealReminderOn = mealReminderOn;
      if (waterReminderOn != null) s.waterReminderOn = waterReminderOn;
      if (progressUpdateOn != null) s.progressUpdateOn = progressUpdateOn;
      if (achievementOn != null) s.achievementOn = achievementOn;
      if (weeklyWorkoutGoal != null) s.weeklyWorkoutGoal = weeklyWorkoutGoal;
      if (dailyCalorieGoal != null) s.dailyCalorieGoal = dailyCalorieGoal;
      if (dailyWaterGoal != null) s.dailyWaterGoal = dailyWaterGoal;
      if (dailyStepsGoal != null) s.dailyStepsGoal = dailyStepsGoal;
      if (workoutReminderHour != null) s.workoutReminderHour = workoutReminderHour;
      if (workoutReminderMinute != null) s.workoutReminderMinute = workoutReminderMinute;

      await _hive.saveSettings(s);
      settings.refresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearAllData() async {
    try {
      final hive = _hive;
      await hive.userBox.clear();
      await hive.workoutBox.clear();
      await hive.dietBox.clear();
      await hive.waterBox.clear();
      await hive.weightBox.clear();
      await hive.measurementBox.clear();
      await hive.progressPhotoBox.clear();
      await hive.personalRecordBox.clear();
      await hive.settingsBox.clear();
      user.value = null;
      settings.value = AppSettingsModel();
    } catch (e) {
      rethrow;
    }
  }
}
