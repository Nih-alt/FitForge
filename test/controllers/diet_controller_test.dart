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
import 'package:elevate_ai_fitness/controllers/diet_controller.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_diet_');
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

  group('DietController', () {
    test('addFoodLog updates totals correctly', () async {
      final controller = Get.put(DietController());

      final log = DietLogModel(
        id: 'food_1',
        date: DateTime.now(),
        mealType: 'Breakfast',
        foodName: 'Oatmeal',
        calories: 300,
        protein: 10.0,
        carbs: 50.0,
        fat: 6.0,
        quantity: '1 bowl',
      );

      await controller.addFoodLog(log);

      expect(controller.totalCalories.value, 300);
      expect(controller.totalProtein.value, 10.0);
      expect(controller.totalCarbs.value, 50.0);
      expect(controller.totalFat.value, 6.0);
      expect(controller.todayLogs.length, 1);
    });

    test('multiple food logs sum correctly', () async {
      final controller = Get.put(DietController());

      await controller.addFoodLog(DietLogModel(
        id: 'food_1',
        date: DateTime.now(),
        mealType: 'Breakfast',
        foodName: 'Eggs',
        calories: 200,
        protein: 14.0,
        carbs: 2.0,
        fat: 15.0,
        quantity: '2',
      ));

      await controller.addFoodLog(DietLogModel(
        id: 'food_2',
        date: DateTime.now(),
        mealType: 'Lunch',
        foodName: 'Chicken',
        calories: 500,
        protein: 40.0,
        carbs: 30.0,
        fat: 10.0,
        quantity: '200g',
      ));

      expect(controller.totalCalories.value, 700);
      expect(controller.totalProtein.value, 54.0);
      expect(controller.totalCarbs.value, 32.0);
      expect(controller.totalFat.value, 25.0);
    });

    test('deleteFoodLog removes and recalculates', () async {
      final controller = Get.put(DietController());

      await controller.addFoodLog(DietLogModel(
        id: 'keep',
        date: DateTime.now(),
        mealType: 'Breakfast',
        foodName: 'Toast',
        calories: 200,
        protein: 5.0,
        carbs: 30.0,
        fat: 5.0,
        quantity: '2 slices',
      ));

      await controller.addFoodLog(DietLogModel(
        id: 'delete_me',
        date: DateTime.now(),
        mealType: 'Lunch',
        foodName: 'Burger',
        calories: 800,
        protein: 30.0,
        carbs: 50.0,
        fat: 40.0,
        quantity: '1',
      ));

      expect(controller.totalCalories.value, 1000);

      await controller.deleteFoodLog('delete_me');

      expect(controller.todayLogs.length, 1);
      expect(controller.totalCalories.value, 200);
      expect(controller.totalProtein.value, 5.0);
    });

    test('water glass updates correctly', () async {
      final controller = Get.put(DietController());

      expect(controller.waterGlasses.value, 0);

      await controller.updateWaterGlasses(3);
      expect(controller.waterGlasses.value, 3);

      await controller.updateWaterGlasses(5);
      expect(controller.waterGlasses.value, 5);
    });

    test('remainingCalories calculation', () async {
      final controller = Get.put(DietController());

      // Default goal is 2000
      expect(controller.remainingCalories, 2000);

      await controller.addFoodLog(DietLogModel(
        id: 'food_rc',
        date: DateTime.now(),
        mealType: 'Lunch',
        foodName: 'Rice',
        calories: 500,
        protein: 10.0,
        carbs: 80.0,
        fat: 2.0,
        quantity: '1 bowl',
      ));

      expect(controller.remainingCalories, 1500);
    });

    test('date navigation loads correct data', () async {
      final controller = Get.put(DietController());

      final today = DateTime.now();

      // Add log for today
      await controller.addFoodLog(DietLogModel(
        id: 'today_food',
        date: today,
        mealType: 'Breakfast',
        foodName: 'Cereal',
        calories: 250,
        protein: 8.0,
        carbs: 40.0,
        fat: 4.0,
        quantity: '1 bowl',
      ));

      expect(controller.totalCalories.value, 250);

      // Navigate to yesterday
      controller.navigateDate(-1);
      expect(controller.totalCalories.value, 0);
      expect(controller.todayLogs.length, 0);

      // Navigate back to today
      controller.navigateDate(1);
      expect(controller.totalCalories.value, 250);
    });

    test('logsForMeal filters correctly', () async {
      final controller = Get.put(DietController());

      await controller.addFoodLog(DietLogModel(
        id: 'b1', date: DateTime.now(), mealType: 'Breakfast',
        foodName: 'Eggs', calories: 200, protein: 14.0, carbs: 2.0, fat: 15.0, quantity: '2',
      ));
      await controller.addFoodLog(DietLogModel(
        id: 'l1', date: DateTime.now(), mealType: 'Lunch',
        foodName: 'Salad', calories: 300, protein: 10.0, carbs: 20.0, fat: 15.0, quantity: '1 bowl',
      ));
      await controller.addFoodLog(DietLogModel(
        id: 'b2', date: DateTime.now(), mealType: 'Breakfast',
        foodName: 'Toast', calories: 150, protein: 4.0, carbs: 25.0, fat: 3.0, quantity: '2 slices',
      ));

      expect(controller.logsForMeal('Breakfast').length, 2);
      expect(controller.logsForMeal('Lunch').length, 1);
      expect(controller.logsForMeal('Dinner').length, 0);
    });

    test('caloriesForMeal sums correctly', () async {
      final controller = Get.put(DietController());

      await controller.addFoodLog(DietLogModel(
        id: 'b1', date: DateTime.now(), mealType: 'Breakfast',
        foodName: 'Eggs', calories: 200, protein: 14.0, carbs: 2.0, fat: 15.0, quantity: '2',
      ));
      await controller.addFoodLog(DietLogModel(
        id: 'b2', date: DateTime.now(), mealType: 'Breakfast',
        foodName: 'Toast', calories: 150, protein: 4.0, carbs: 25.0, fat: 3.0, quantity: '2',
      ));

      expect(controller.caloriesForMeal('Breakfast'), 350);
      expect(controller.caloriesForMeal('Dinner'), 0);
    });
  });
}
