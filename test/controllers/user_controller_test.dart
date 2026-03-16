import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:elevate_ai_fitness/models/user_model.dart';
import 'package:elevate_ai_fitness/models/workout_log_model.dart';
import 'package:elevate_ai_fitness/models/diet_log_model.dart';
import 'package:elevate_ai_fitness/models/water_log_model.dart';
import 'package:elevate_ai_fitness/models/weight_log_model.dart';
import 'package:elevate_ai_fitness/models/measurement_model.dart';
import 'package:elevate_ai_fitness/models/progress_photo_model.dart';
import 'package:elevate_ai_fitness/models/personal_record_model.dart';
import 'package:elevate_ai_fitness/models/app_settings_model.dart';
import 'package:elevate_ai_fitness/services/hive_service.dart';
import 'package:elevate_ai_fitness/controllers/user_controller.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_user_');
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserModelAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(WorkoutLogModelAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(DietLogModelAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(WaterLogModelAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(WeightLogModelAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(MeasurementModelAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(ProgressPhotoModelAdapter());
    if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(PersonalRecordModelAdapter());
    if (!Hive.isAdapterRegistered(8)) Hive.registerAdapter(AppSettingsModelAdapter());
  });

  setUp(() async {
    // Reset GetX
    Get.reset();

    // Open boxes fresh
    await Hive.openBox<UserModel>('user_box');
    await Hive.openBox<WorkoutLogModel>('workout_log_box');
    await Hive.openBox<DietLogModel>('diet_log_box');
    await Hive.openBox<WaterLogModel>('water_log_box');
    await Hive.openBox<WeightLogModel>('weight_log_box');
    await Hive.openBox<MeasurementModel>('measurement_box');
    await Hive.openBox<ProgressPhotoModel>('progress_photo_box');
    await Hive.openBox<PersonalRecordModel>('personal_record_box');
    await Hive.openBox<AppSettingsModel>('settings_box');

    final hiveService = HiveService();
    await hiveService.init();
    Get.put(hiveService);
  });

  tearDown(() async {
    Get.reset();
    await Hive.deleteFromDisk();
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('UserController', () {
    test('loadUser returns null when no user saved', () {
      final controller = Get.put(UserController());

      expect(controller.user.value, isNull);
    });

    test('saveNewUser stores and loads correctly', () async {
      final controller = Get.put(UserController());

      final user = UserModel(
        name: 'Test User',
        dateOfBirth: DateTime(1995, 5, 10),
        age: 30,
        weight: 75.0,
        height: 180.0,
        goal: 'Build Muscle',
        createdAt: DateTime.now(),
      );

      await controller.saveNewUser(user);
      expect(controller.user.value, isNotNull);
      expect(controller.user.value!.name, 'Test User');
      expect(controller.user.value!.weight, 75.0);
    });

    test('updateUser saves changes correctly', () async {
      final controller = Get.put(UserController());

      final user = UserModel(
        name: 'Original',
        dateOfBirth: DateTime(1990, 1, 1),
        age: 36,
        weight: 80.0,
        height: 175.0,
        goal: 'Lose Weight',
        createdAt: DateTime.now(),
      );
      await controller.saveNewUser(user);

      await controller.updateUser(name: 'Updated Name', weight: 72.0);
      expect(controller.user.value!.name, 'Updated Name');
      expect(controller.user.value!.weight, 72.0);
      // Height should remain unchanged
      expect(controller.user.value!.height, 175.0);
    });

    test('clearAllData resets user and settings', () async {
      final controller = Get.put(UserController());

      final user = UserModel(
        name: 'To Clear',
        dateOfBirth: DateTime(2000, 1, 1),
        age: 26,
        weight: 65.0,
        height: 170.0,
        goal: 'Stay Fit',
        createdAt: DateTime.now(),
      );
      await controller.saveNewUser(user);
      expect(controller.user.value, isNotNull);

      await controller.clearAllData();
      expect(controller.user.value, isNull);
    });

    test('loadSettings returns defaults when none saved', () {
      final controller = Get.put(UserController());

      expect(controller.settings.value.dailyCalorieGoal, 2000);
      expect(controller.settings.value.dailyWaterGoal, 8);
      expect(controller.settings.value.themeMode, 'system');
    });

    test('saveSettings persists changes', () async {
      final controller = Get.put(UserController());

      final settings = AppSettingsModel(
        dailyCalorieGoal: 2500,
        dailyWaterGoal: 10,
        themeMode: 'dark',
      );
      await controller.saveSettings(settings);

      expect(controller.settings.value.dailyCalorieGoal, 2500);
      expect(controller.settings.value.dailyWaterGoal, 10);
      expect(controller.settings.value.themeMode, 'dark');
    });

    test('updateUser with changed weight creates WeightLogModel', () async {
      final controller = Get.put(UserController());
      final hive = Get.find<HiveService>();

      await controller.saveNewUser(UserModel(
        name: 'WeightTracker',
        dateOfBirth: DateTime(1992, 4, 10),
        age: 34,
        weight: 80.0,
        height: 175.0,
        goal: 'Lose Weight',
        createdAt: DateTime.now(),
      ));

      // Change weight — should auto-create a WeightLogModel
      await controller.updateUser(weight: 78.0);

      expect(controller.user.value!.weight, 78.0);
      final weightLogs = hive.getWeightLogs();
      expect(weightLogs.isNotEmpty, true);
      expect(weightLogs.last.weight, 78.0);
    });

    test('updateUser with same weight does NOT create WeightLogModel', () async {
      final controller = Get.put(UserController());
      final hive = Get.find<HiveService>();

      await controller.saveNewUser(UserModel(
        name: 'NoChange',
        dateOfBirth: DateTime(1990, 1, 1),
        age: 36,
        weight: 75.0,
        height: 180.0,
        goal: 'Maintain',
        createdAt: DateTime.now(),
      ));

      // Same weight — no new log
      await controller.updateUser(weight: 75.0);
      final weightLogs = hive.getWeightLogs();
      expect(weightLogs.isEmpty, true);
    });

    test('updateUser updates age, goal, and profilePhotoPath', () async {
      final controller = Get.put(UserController());

      await controller.saveNewUser(UserModel(
        name: 'Multi',
        dateOfBirth: DateTime(1995, 6, 1),
        age: 30,
        weight: 70.0,
        height: 170.0,
        goal: 'Build Muscle',
        createdAt: DateTime.now(),
      ));

      await controller.updateUser(
        age: 31,
        goal: 'Lose Weight',
        profilePhotoPath: '/photos/me.jpg',
      );

      expect(controller.user.value!.age, 31);
      expect(controller.user.value!.goal, 'Lose Weight');
      expect(controller.user.value!.profilePhotoPath, '/photos/me.jpg');
      // Unchanged fields
      expect(controller.user.value!.name, 'Multi');
      expect(controller.user.value!.weight, 70.0);
    });

    test('updateUser on null user is a no-op', () async {
      final controller = Get.put(UserController());
      // user.value is null — updateUser should return early
      await controller.updateUser(name: 'Ghost');
      expect(controller.user.value, isNull);
    });

    test('updateSettings persists theme mode change', () async {
      final controller = Get.put(UserController());

      await controller.updateSettings(themeMode: 'dark');
      expect(controller.settings.value.themeMode, 'dark');

      await controller.updateSettings(themeMode: 'light');
      expect(controller.settings.value.themeMode, 'light');

      await controller.updateSettings(themeMode: 'system');
      expect(controller.settings.value.themeMode, 'system');
    });

    test('updateSettings persists notification toggles', () async {
      final controller = Get.put(UserController());

      await controller.updateSettings(
        workoutReminderOn: false,
        mealReminderOn: true,
        waterReminderOn: true,
        progressUpdateOn: false,
        achievementOn: false,
      );

      final s = controller.settings.value;
      expect(s.workoutReminderOn, false);
      expect(s.mealReminderOn, true);
      expect(s.waterReminderOn, true);
      expect(s.progressUpdateOn, false);
      expect(s.achievementOn, false);
    });

    test('updateSettings persists unit preferences', () async {
      final controller = Get.put(UserController());

      await controller.updateSettings(
        weightUnit: 'lbs',
        heightUnit: 'ft',
      );

      expect(controller.settings.value.weightUnit, 'lbs');
      expect(controller.settings.value.heightUnit, 'ft');
    });

    test('updateSettings persists all goal fields', () async {
      final controller = Get.put(UserController());

      await controller.updateSettings(
        weeklyWorkoutGoal: 5,
        dailyCalorieGoal: 1800,
        dailyWaterGoal: 12,
        dailyStepsGoal: 15000,
      );

      final s = controller.settings.value;
      expect(s.weeklyWorkoutGoal, 5);
      expect(s.dailyCalorieGoal, 1800);
      expect(s.dailyWaterGoal, 12);
      expect(s.dailyStepsGoal, 15000);
    });

    test('updateSettings persists workout reminder time', () async {
      final controller = Get.put(UserController());

      await controller.updateSettings(
        workoutReminderHour: 18,
        workoutReminderMinute: 30,
      );

      expect(controller.settings.value.workoutReminderHour, 18);
      expect(controller.settings.value.workoutReminderMinute, 30);
    });

    test('clearAllData resets settings to defaults', () async {
      final controller = Get.put(UserController());

      // Save custom settings
      await controller.saveSettings(AppSettingsModel(
        themeMode: 'dark',
        dailyCalorieGoal: 3000,
        dailyWaterGoal: 12,
      ));
      expect(controller.settings.value.themeMode, 'dark');

      await controller.clearAllData();

      expect(controller.settings.value.themeMode, 'system');
      expect(controller.settings.value.dailyCalorieGoal, 2000);
      expect(controller.settings.value.dailyWaterGoal, 8);
    });

    test('clearAllData empties all Hive boxes', () async {
      final controller = Get.put(UserController());
      final hive = Get.find<HiveService>();

      // Populate various boxes
      await controller.saveNewUser(UserModel(
        name: 'ClearTest', dateOfBirth: DateTime(2000, 1, 1),
        age: 26, weight: 70.0, height: 175.0, goal: 'Fit',
        createdAt: DateTime.now(),
      ));
      await hive.saveWeightLog(WeightLogModel(
        date: DateTime.now(), weight: 70.0,
      ));
      await hive.saveWorkoutLog(WorkoutLogModel(
        id: 'w1', workoutName: 'Test', date: DateTime.now(),
        durationSeconds: 1000, caloriesBurned: 100,
        exercisesCompleted: 3, exercises: ['Push-ups'],
      ));

      await controller.clearAllData();

      expect(hive.getUser(), isNull);
      expect(hive.getWeightLogs(), isEmpty);
      expect(hive.getWorkoutLogs(), isEmpty);
    });

    test('isLoading becomes false after loadUser', () {
      final controller = Get.put(UserController());
      expect(controller.isLoading.value, false);
    });

    test('edge case: user with empty name', () async {
      final controller = Get.put(UserController());

      await controller.saveNewUser(UserModel(
        name: '',
        dateOfBirth: DateTime(2000, 1, 1),
        age: 26,
        weight: 65.0,
        height: 170.0,
        goal: 'Stay Fit',
        createdAt: DateTime.now(),
      ));

      expect(controller.user.value, isNotNull);
      expect(controller.user.value!.name, '');
    });

    test('edge case: user with zero weight and height', () async {
      final controller = Get.put(UserController());

      await controller.saveNewUser(UserModel(
        name: 'Zero',
        dateOfBirth: DateTime(2000, 1, 1),
        age: 26,
        weight: 0.0,
        height: 0.0,
        goal: 'None',
        createdAt: DateTime.now(),
      ));

      expect(controller.user.value, isNotNull);
      expect(controller.user.value!.weight, 0.0);
      expect(controller.user.value!.height, 0.0);
    });
  });
}
