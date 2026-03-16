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

void main() {
  late Directory tempDir;
  late HiveService hiveService;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_svc_');
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
    Get.reset();

    await Hive.openBox<UserModel>('user_box');
    await Hive.openBox<WorkoutLogModel>('workout_log_box');
    await Hive.openBox<DietLogModel>('diet_log_box');
    await Hive.openBox<WaterLogModel>('water_log_box');
    await Hive.openBox<WeightLogModel>('weight_log_box');
    await Hive.openBox<MeasurementModel>('measurement_box');
    await Hive.openBox<ProgressPhotoModel>('progress_photo_box');
    await Hive.openBox<PersonalRecordModel>('personal_record_box');
    await Hive.openBox<AppSettingsModel>('settings_box');

    hiveService = HiveService();
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

  group('HiveService — User CRUD', () {
    test('getUser returns null when empty', () {
      expect(hiveService.getUser(), isNull);
    });

    test('saveUser and getUser roundtrip', () async {
      final user = UserModel(
        name: 'Alice',
        dateOfBirth: DateTime(1998, 8, 20),
        age: 27,
        weight: 60.0,
        height: 165.0,
        goal: 'Tone Up',
        createdAt: DateTime.now(),
      );

      await hiveService.saveUser(user);
      final loaded = hiveService.getUser();

      expect(loaded, isNotNull);
      expect(loaded!.name, 'Alice');
      expect(loaded.weight, 60.0);
    });

    test('updateUser modifies existing record', () async {
      final user = UserModel(
        name: 'Bob',
        dateOfBirth: DateTime(1990, 3, 15),
        age: 36,
        weight: 85.0,
        height: 180.0,
        goal: 'Lose Weight',
        createdAt: DateTime.now(),
      );
      await hiveService.saveUser(user);

      final saved = hiveService.getUser()!;
      saved.name = 'Bobby';
      await hiveService.updateUser(saved);

      final updated = hiveService.getUser();
      expect(updated!.name, 'Bobby');
    });
  });

  group('HiveService — Workout Logs', () {
    test('empty box returns empty list', () {
      expect(hiveService.getWorkoutLogs(), isEmpty);
    });

    test('save and retrieve workout log', () async {
      final log = WorkoutLogModel(
        id: 'w1',
        workoutName: 'Push Day',
        date: DateTime(2026, 3, 16),
        durationSeconds: 3600,
        caloriesBurned: 400,
        exercisesCompleted: 8,
        exercises: ['Bench Press', 'OHP'],
      );

      await hiveService.saveWorkoutLog(log);
      final logs = hiveService.getWorkoutLogs();

      expect(logs.length, 1);
      expect(logs.first.id, 'w1');
    });

    test('getWorkoutLogsByDate filters correctly', () async {
      await hiveService.saveWorkoutLog(WorkoutLogModel(
        id: 'w1', workoutName: 'Day 1', date: DateTime(2026, 3, 16),
        durationSeconds: 1800, caloriesBurned: 200, exercisesCompleted: 5,
        exercises: ['Squats'],
      ));
      await hiveService.saveWorkoutLog(WorkoutLogModel(
        id: 'w2', workoutName: 'Day 2', date: DateTime(2026, 3, 17),
        durationSeconds: 2400, caloriesBurned: 300, exercisesCompleted: 6,
        exercises: ['Deadlifts'],
      ));

      final march16 = hiveService.getWorkoutLogsByDate(DateTime(2026, 3, 16));
      expect(march16.length, 1);
      expect(march16.first.workoutName, 'Day 1');
    });
  });

  group('HiveService — Diet Logs', () {
    test('save and retrieve by date', () async {
      final log = DietLogModel(
        id: 'd1',
        date: DateTime(2026, 3, 16),
        mealType: 'Lunch',
        foodName: 'Chicken Rice',
        calories: 550,
        protein: 35.0,
        carbs: 60.0,
        fat: 12.0,
        quantity: '1 plate',
      );

      await hiveService.saveDietLog(log);
      final logs = hiveService.getDietLogsByDate(DateTime(2026, 3, 16));

      expect(logs.length, 1);
      expect(logs.first.foodName, 'Chicken Rice');
    });

    test('deleteDietLog removes entry', () async {
      await hiveService.saveDietLog(DietLogModel(
        id: 'to_delete',
        date: DateTime(2026, 3, 16),
        mealType: 'Snacks',
        foodName: 'Cookie',
        calories: 200,
        protein: 2.0,
        carbs: 30.0,
        fat: 10.0,
        quantity: '1',
      ));

      await hiveService.deleteDietLog('to_delete');
      final logs = hiveService.getDietLogsByDate(DateTime(2026, 3, 16));
      expect(logs, isEmpty);
    });
  });

  group('HiveService — Water Logs', () {
    test('getWaterLogByDate returns null when empty', () {
      expect(hiveService.getWaterLogByDate(DateTime.now()), isNull);
    });

    test('save and retrieve water log', () async {
      final log = WaterLogModel(
        date: DateTime(2026, 3, 16),
        glassesCount: 5,
      );

      await hiveService.saveWaterLog(log);
      final loaded = hiveService.getWaterLogByDate(DateTime(2026, 3, 16));

      expect(loaded, isNotNull);
      expect(loaded!.glassesCount, 5);
    });
  });

  group('HiveService — Settings', () {
    test('getSettings returns defaults when empty', () {
      final settings = hiveService.getSettings();
      expect(settings.themeMode, 'system');
      expect(settings.dailyCalorieGoal, 2000);
      expect(settings.dailyWaterGoal, 8);
      expect(settings.weeklyWorkoutGoal, 4);
    });

    test('saveSettings persists', () async {
      final settings = AppSettingsModel(
        themeMode: 'dark',
        dailyCalorieGoal: 1800,
        dailyWaterGoal: 10,
      );

      await hiveService.saveSettings(settings);
      final loaded = hiveService.getSettings();

      expect(loaded.themeMode, 'dark');
      expect(loaded.dailyCalorieGoal, 1800);
      expect(loaded.dailyWaterGoal, 10);
    });
  });

  group('HiveService — Personal Records', () {
    test('empty box returns empty list', () {
      expect(hiveService.getPersonalRecords(), isEmpty);
    });

    test('save and retrieve personal record', () async {
      final record = PersonalRecordModel(
        exerciseName: 'Bench Press',
        value: 100.0,
        unit: 'kg',
        date: DateTime(2026, 3, 16),
        history: [
          {'date': '2026-03-10', 'value': 95.0},
          {'date': '2026-03-16', 'value': 100.0},
        ],
      );

      await hiveService.savePersonalRecord(record);
      final records = hiveService.getPersonalRecords();

      expect(records.length, 1);
      expect(records.first.exerciseName, 'Bench Press');
      expect(records.first.value, 100.0);
    });
  });

  group('HiveService — Progress Photos', () {
    test('empty box returns empty list', () {
      expect(hiveService.getProgressPhotos(), isEmpty);
    });

    test('save and retrieve sorted descending', () async {
      await hiveService.saveProgressPhoto(ProgressPhotoModel(
        id: 'p1', date: DateTime(2026, 3, 10), imagePath: '/a.jpg', weight: 73.0,
      ));
      await hiveService.saveProgressPhoto(ProgressPhotoModel(
        id: 'p2', date: DateTime(2026, 3, 15), imagePath: '/b.jpg', weight: 72.0,
      ));

      final photos = hiveService.getProgressPhotos();
      expect(photos.length, 2);
      expect(photos.first.id, 'p2');  // Most recent first
    });

    test('delete removes photo', () async {
      await hiveService.saveProgressPhoto(ProgressPhotoModel(
        id: 'del_photo', date: DateTime(2026, 3, 16), imagePath: '/c.jpg', weight: 71.0,
      ));

      await hiveService.deleteProgressPhoto('del_photo');
      expect(hiveService.getProgressPhotos(), isEmpty);
    });
  });
}
