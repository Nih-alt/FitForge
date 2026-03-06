import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_settings_model.dart';
import '../models/diet_log_model.dart';
import '../models/measurement_model.dart';
import '../models/personal_record_model.dart';
import '../models/progress_photo_model.dart';
import '../models/user_model.dart';
import '../models/water_log_model.dart';
import '../models/weight_log_model.dart';
import '../models/workout_log_model.dart';

class HiveService extends GetxService {
  static const String _userBox = 'user_box';
  static const String _workoutBox = 'workout_log_box';
  static const String _dietBox = 'diet_log_box';
  static const String _waterBox = 'water_log_box';
  static const String _weightBox = 'weight_log_box';
  static const String _measurementBox = 'measurement_box';
  static const String _progressPhotoBox = 'progress_photo_box';
  static const String _personalRecordBox = 'personal_record_box';
  static const String _settingsBox = 'settings_box';

  late Box<UserModel> userBox;
  late Box<WorkoutLogModel> workoutBox;
  late Box<DietLogModel> dietBox;
  late Box<WaterLogModel> waterBox;
  late Box<WeightLogModel> weightBox;
  late Box<MeasurementModel> measurementBox;
  late Box<ProgressPhotoModel> progressPhotoBox;
  late Box<PersonalRecordModel> personalRecordBox;
  late Box<AppSettingsModel> settingsBox;

  Future<HiveService> init() async {
    userBox = await Hive.openBox<UserModel>(_userBox);
    workoutBox = await Hive.openBox<WorkoutLogModel>(_workoutBox);
    dietBox = await Hive.openBox<DietLogModel>(_dietBox);
    waterBox = await Hive.openBox<WaterLogModel>(_waterBox);
    weightBox = await Hive.openBox<WeightLogModel>(_weightBox);
    measurementBox = await Hive.openBox<MeasurementModel>(_measurementBox);
    progressPhotoBox =
        await Hive.openBox<ProgressPhotoModel>(_progressPhotoBox);
    personalRecordBox =
        await Hive.openBox<PersonalRecordModel>(_personalRecordBox);
    settingsBox = await Hive.openBox<AppSettingsModel>(_settingsBox);
    return this;
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  USER
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> saveUser(UserModel user) async {
    await userBox.put('current_user', user);
  }

  UserModel? getUser() => userBox.get('current_user');

  Future<void> updateUser(UserModel user) async {
    await user.save();
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  WORKOUT LOGS
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> saveWorkoutLog(WorkoutLogModel log) async {
    await workoutBox.put(log.id, log);
  }

  List<WorkoutLogModel> getWorkoutLogs() => workoutBox.values.toList();

  List<WorkoutLogModel> getWorkoutLogsByDate(DateTime date) {
    return workoutBox.values.where((log) {
      return log.date.year == date.year &&
          log.date.month == date.month &&
          log.date.day == date.day;
    }).toList();
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  DIET LOGS
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> saveDietLog(DietLogModel log) async {
    await dietBox.put(log.id, log);
  }

  List<DietLogModel> getDietLogsByDate(DateTime date) {
    return dietBox.values.where((log) {
      return log.date.year == date.year &&
          log.date.month == date.month &&
          log.date.day == date.day;
    }).toList();
  }

  Future<void> deleteDietLog(String id) async {
    await dietBox.delete(id);
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  WATER LOGS
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> saveWaterLog(WaterLogModel log) async {
    final key =
        '${log.date.year}-${log.date.month}-${log.date.day}';
    await waterBox.put(key, log);
  }

  WaterLogModel? getWaterLogByDate(DateTime date) {
    final key = '${date.year}-${date.month}-${date.day}';
    return waterBox.get(key);
  }

  Future<void> updateWaterLog(WaterLogModel log) async {
    await log.save();
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  WEIGHT LOGS
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> saveWeightLog(WeightLogModel log) async {
    final key =
        '${log.date.year}-${log.date.month}-${log.date.day}';
    await weightBox.put(key, log);
  }

  List<WeightLogModel> getWeightLogs() {
    final logs = weightBox.values.toList();
    logs.sort((a, b) => a.date.compareTo(b.date));
    return logs;
  }

  List<WeightLogModel> getLast30DaysWeight() {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    return getWeightLogs().where((log) => log.date.isAfter(cutoff)).toList();
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  MEASUREMENTS
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> saveMeasurement(MeasurementModel m) async {
    final key =
        '${m.date.year}-${m.date.month}-${m.date.day}';
    await measurementBox.put(key, m);
  }

  MeasurementModel? getLatestMeasurement() {
    if (measurementBox.isEmpty) return null;
    final list = measurementBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return list.first;
  }

  List<MeasurementModel> getMeasurementHistory() {
    final list = measurementBox.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  PROGRESS PHOTOS
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> saveProgressPhoto(ProgressPhotoModel photo) async {
    await progressPhotoBox.put(photo.id, photo);
  }

  List<ProgressPhotoModel> getProgressPhotos() {
    final list = progressPhotoBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> deleteProgressPhoto(String id) async {
    await progressPhotoBox.delete(id);
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  PERSONAL RECORDS
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> savePersonalRecord(PersonalRecordModel record) async {
    await personalRecordBox.put(record.exerciseName, record);
  }

  List<PersonalRecordModel> getPersonalRecords() =>
      personalRecordBox.values.toList();

  Future<void> updatePersonalRecord(PersonalRecordModel record) async {
    await record.save();
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  APP SETTINGS
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> saveSettings(AppSettingsModel settings) async {
    await settingsBox.put('app_settings', settings);
  }

  AppSettingsModel getSettings() {
    return settingsBox.get('app_settings') ?? AppSettingsModel();
  }

  Future<void> updateSettings(AppSettingsModel settings) async {
    await settings.save();
  }
}
