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
import 'package:elevate_ai_fitness/controllers/workout_controller.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_workout_');
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

  group('WorkoutController', () {
    test('saveWorkoutLog saves correctly', () async {
      final controller = Get.put(WorkoutController());

      final log = WorkoutLogModel(
        id: 'w1',
        workoutName: 'Upper Body',
        date: DateTime.now(),
        durationSeconds: 3600,
        caloriesBurned: 350,
        exercisesCompleted: 8,
        exercises: ['Bench Press', 'Shoulder Press', 'Bicep Curls'],
      );

      await controller.saveWorkoutLog(log);

      expect(controller.workoutLogs.length, 1);
      expect(controller.workoutLogs.first.workoutName, 'Upper Body');
      expect(controller.workoutLogs.first.caloriesBurned, 350);
    });

    test('calculateStreak with consecutive days', () async {
      final controller = Get.put(WorkoutController());

      final now = DateTime.now();

      // Add workouts for 3 consecutive days
      for (int i = 0; i < 3; i++) {
        await controller.saveWorkoutLog(WorkoutLogModel(
          id: 'streak_$i',
          workoutName: 'Day $i',
          date: DateTime(now.year, now.month, now.day - i),
          durationSeconds: 1800,
          caloriesBurned: 200,
          exercisesCompleted: 5,
          exercises: ['Push-ups'],
        ));
      }

      expect(controller.currentStreak.value, 3);
    });

    test('calculateStreak breaks on gap', () async {
      final controller = Get.put(WorkoutController());

      final now = DateTime.now();

      // Today
      await controller.saveWorkoutLog(WorkoutLogModel(
        id: 's1',
        workoutName: 'Day 1',
        date: DateTime(now.year, now.month, now.day),
        durationSeconds: 1800,
        caloriesBurned: 200,
        exercisesCompleted: 5,
        exercises: ['Squats'],
      ));

      // 2 days ago (gap yesterday)
      await controller.saveWorkoutLog(WorkoutLogModel(
        id: 's2',
        workoutName: 'Day 2',
        date: DateTime(now.year, now.month, now.day - 2),
        durationSeconds: 1800,
        caloriesBurned: 200,
        exercisesCompleted: 5,
        exercises: ['Lunges'],
      ));

      expect(controller.currentStreak.value, 1);
    });

    test('weeklyStats counts this week workouts', () async {
      final controller = Get.put(WorkoutController());

      final now = DateTime.now();
      // Week starts Monday (weekday=1). Ensure both dates are in the same week.
      final today = DateTime(now.year, now.month, now.day);
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      // Use Monday and Tuesday of this week (guaranteed same week)
      final day1 = weekStart;
      final day2 = weekStart.add(const Duration(days: 1));

      await controller.saveWorkoutLog(WorkoutLogModel(
        id: 'wk1',
        workoutName: 'Day 1',
        date: day1,
        durationSeconds: 2400,
        caloriesBurned: 250,
        exercisesCompleted: 6,
        exercises: ['Running'],
      ));

      await controller.saveWorkoutLog(WorkoutLogModel(
        id: 'wk2',
        workoutName: 'Day 2',
        date: day2,
        durationSeconds: 3600,
        caloriesBurned: 400,
        exercisesCompleted: 10,
        exercises: ['Deadlifts', 'Rows'],
      ));

      expect(controller.weeklyWorkoutsCompleted.value, greaterThanOrEqualTo(2));
      expect(controller.totalCaloriesBurned.value, greaterThanOrEqualTo(650));
    });

    test('todayCaloriesBurned sums todays workouts', () async {
      final controller = Get.put(WorkoutController());

      final now = DateTime.now();

      await controller.saveWorkoutLog(WorkoutLogModel(
        id: 'tc1',
        workoutName: 'Cardio',
        date: DateTime(now.year, now.month, now.day),
        durationSeconds: 1800,
        caloriesBurned: 300,
        exercisesCompleted: 1,
        exercises: ['Running'],
      ));

      await controller.saveWorkoutLog(WorkoutLogModel(
        id: 'tc2',
        workoutName: 'Strength',
        date: DateTime(now.year, now.month, now.day),
        durationSeconds: 2700,
        caloriesBurned: 250,
        exercisesCompleted: 6,
        exercises: ['Squats', 'Press'],
      ));

      expect(controller.todayCaloriesBurned.value, 550);
    });

    test('hasWorkoutOnDate returns correct values', () async {
      final controller = Get.put(WorkoutController());

      final workoutDate = DateTime(2026, 3, 10);
      await controller.saveWorkoutLog(WorkoutLogModel(
        id: 'hw1',
        workoutName: 'Legs',
        date: workoutDate,
        durationSeconds: 3000,
        caloriesBurned: 300,
        exercisesCompleted: 7,
        exercises: ['Squats'],
      ));

      expect(controller.hasWorkoutOnDate(workoutDate), true);
      expect(controller.hasWorkoutOnDate(DateTime(2026, 3, 11)), false);
    });

    test('activityLevel categorizes correctly', () async {
      final controller = Get.put(WorkoutController());

      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day);

      // No workout = level 0
      expect(controller.activityLevel(date), 0);

      // Light workout < 150 cal = level 1
      await controller.saveWorkoutLog(WorkoutLogModel(
        id: 'al1',
        workoutName: 'Walk',
        date: date,
        durationSeconds: 900,
        caloriesBurned: 100,
        exercisesCompleted: 1,
        exercises: ['Walking'],
      ));
      expect(controller.activityLevel(date), 1);
    });

    test('empty workout logs returns zero streak', () {
      final controller = Get.put(WorkoutController());

      expect(controller.currentStreak.value, 0);
      expect(controller.weeklyWorkoutsCompleted.value, 0);
      expect(controller.totalCaloriesBurned.value, 0);
    });
  });
}
