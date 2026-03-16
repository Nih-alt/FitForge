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

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_progress_');
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

  group('Progress & BMI Calculations', () {
    double calculateBMI(double weightKg, double heightCm) {
      final heightM = heightCm / 100;
      return weightKg / (heightM * heightM);
    }

    String bmiCategory(double bmi) {
      if (bmi < 18.5) return 'Underweight';
      if (bmi < 25.0) return 'Normal';
      if (bmi < 30.0) return 'Overweight';
      return 'Obese';
    }

    test('BMI calculation: weight=70 height=175 → 22.86', () {
      final bmi = calculateBMI(70.0, 175.0);
      expect(bmi, closeTo(22.86, 0.01));
    });

    test('BMI calculation: weight=55 height=165 → 20.20', () {
      final bmi = calculateBMI(55.0, 165.0);
      expect(bmi, closeTo(20.20, 0.01));
    });

    test('BMI calculation: weight=100 height=170 → 34.60', () {
      final bmi = calculateBMI(100.0, 170.0);
      expect(bmi, closeTo(34.60, 0.01));
    });

    test('BMI category: Underweight', () {
      expect(bmiCategory(17.0), 'Underweight');
      expect(bmiCategory(18.4), 'Underweight');
    });

    test('BMI category: Normal', () {
      expect(bmiCategory(18.5), 'Normal');
      expect(bmiCategory(22.0), 'Normal');
      expect(bmiCategory(24.9), 'Normal');
    });

    test('BMI category: Overweight', () {
      expect(bmiCategory(25.0), 'Overweight');
      expect(bmiCategory(29.9), 'Overweight');
    });

    test('BMI category: Obese', () {
      expect(bmiCategory(30.0), 'Obese');
      expect(bmiCategory(40.0), 'Obese');
    });

    test('weight log saves and retrieves via HiveService', () async {
      final hive = Get.find<HiveService>();
      final log = WeightLogModel(
        date: DateTime(2026, 3, 16),
        weight: 72.5,
      );

      await hive.saveWeightLog(log);
      final logs = hive.getWeightLogs();

      expect(logs.length, 1);
      expect(logs.first.weight, 72.5);
    });

    test('weight log sorted by date ascending', () async {
      final hive = Get.find<HiveService>();

      await hive.saveWeightLog(WeightLogModel(
        date: DateTime(2026, 3, 16),
        weight: 73.0,
      ));
      await hive.saveWeightLog(WeightLogModel(
        date: DateTime(2026, 3, 10),
        weight: 74.0,
      ));
      await hive.saveWeightLog(WeightLogModel(
        date: DateTime(2026, 3, 13),
        weight: 73.5,
      ));

      final logs = hive.getWeightLogs();
      expect(logs.length, 3);
      expect(logs[0].weight, 74.0);  // Mar 10
      expect(logs[1].weight, 73.5);  // Mar 13
      expect(logs[2].weight, 73.0);  // Mar 16
    });

    test('getLast30DaysWeight filters correctly', () async {
      final hive = Get.find<HiveService>();
      final now = DateTime.now();

      // Within 30 days
      await hive.saveWeightLog(WeightLogModel(
        date: DateTime(now.year, now.month, now.day - 5),
        weight: 71.0,
      ));

      // 60 days ago
      await hive.saveWeightLog(WeightLogModel(
        date: DateTime(now.year, now.month, now.day - 60),
        weight: 75.0,
      ));

      final recent = hive.getLast30DaysWeight();
      expect(recent.length, 1);
      expect(recent.first.weight, 71.0);
    });

    test('measurement saves and retrieves latest', () async {
      final hive = Get.find<HiveService>();

      await hive.saveMeasurement(MeasurementModel(
        date: DateTime(2026, 3, 1),
        chest: 100.0, waist: 80.0, hips: 95.0, biceps: 35.0, thighs: 55.0,
      ));
      await hive.saveMeasurement(MeasurementModel(
        date: DateTime(2026, 3, 15),
        chest: 101.0, waist: 79.0, hips: 94.0, biceps: 36.0, thighs: 56.0,
      ));

      final latest = hive.getLatestMeasurement();
      expect(latest, isNotNull);
      expect(latest!.chest, 101.0);
      expect(latest.waist, 79.0);
    });
  });
}
