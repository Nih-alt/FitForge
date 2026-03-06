import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../models/diet_log_model.dart';
import '../models/water_log_model.dart';
import '../services/hive_service.dart';

// ════════════════════════════════════════════════════════════════════════════
//  MEAL SECTION — config only (name / icon / goal calories / expand state)
// ════════════════════════════════════════════════════════════════════════════

class MealSection {
  final String name;
  final String icon;
  final int goalKcal;
  final RxBool expanded;

  MealSection({
    required this.name,
    required this.icon,
    required this.goalKcal,
  }) : expanded = true.obs;
}

// ════════════════════════════════════════════════════════════════════════════
//  DIET CONTROLLER
// ════════════════════════════════════════════════════════════════════════════

class DietController extends GetxController {
  final _hive = Get.find<HiveService>();

  // ── Reactive state ────────────────────────────────────────────────────────
  final todayLogs    = RxList<DietLogModel>([]);
  final selectedDate = Rx<DateTime>(DateTime.now());
  final totalCalories = RxInt(0);
  final totalProtein  = RxDouble(0.0);
  final totalCarbs    = RxDouble(0.0);
  final totalFat      = RxDouble(0.0);
  final waterGlasses  = RxInt(0);

  // ── Goals (loaded from AppSettings, with sensible defaults) ───────────────
  final calorieGoal = RxInt(2000);
  final proteinGoal = RxDouble(160.0);
  final carbsGoal   = RxDouble(220.0);
  final fatGoal     = RxDouble(60.0);
  final waterGoal   = RxInt(8);

  // ── Meal sections (config only — items come from todayLogs) ──────────────
  late final List<MealSection> meals;

  @override
  void onInit() {
    super.onInit();
    meals = [
      MealSection(name: 'Breakfast', icon: '🌅', goalKcal: 600),
      MealSection(name: 'Lunch',     icon: '☀️', goalKcal: 700),
      MealSection(name: 'Dinner',    icon: '🌙', goalKcal: 650),
      MealSection(name: 'Snacks',    icon: '🍎', goalKcal: 250),
    ];
    _loadGoals();
    loadDataForDate(DateTime.now());
  }

  // ── Load goals from AppSettings ──────────────────────────────────────────
  void _loadGoals() {
    try {
      final settings = _hive.getSettings();
      if (settings.dailyCalorieGoal > 0) calorieGoal.value = settings.dailyCalorieGoal;
      if (settings.dailyWaterGoal   > 0) waterGoal.value   = settings.dailyWaterGoal;
    } catch (_) {
      // defaults already set
    }
  }

  // ── Load diet + water data for a given date ───────────────────────────────
  void loadDataForDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    selectedDate.value = d;
    try {
      todayLogs.value = _hive.getDietLogsByDate(d);
    } catch (_) {
      todayLogs.value = [];
    }
    try {
      final waterLog = _hive.getWaterLogByDate(d);
      waterGlasses.value = waterLog?.glassesCount ?? 0;
    } catch (_) {
      waterGlasses.value = 0;
    }
    calculateTotals();
  }

  // ── Add a food log entry ──────────────────────────────────────────────────
  Future<void> addFoodLog(DietLogModel log) async {
    try {
      await _hive.saveDietLog(log);
      todayLogs.add(log);
      calculateTotals();
    } catch (_) {}
  }

  // ── Delete a food log entry ───────────────────────────────────────────────
  Future<void> deleteFoodLog(String id) async {
    try {
      await _hive.deleteDietLog(id);
      todayLogs.removeWhere((log) => log.id == id);
      calculateTotals();
    } catch (_) {}
  }

  // ── Update water glasses count and persist ────────────────────────────────
  Future<void> updateWaterGlasses(int count) async {
    waterGlasses.value = count;
    try {
      await _hive.saveWaterLog(
        WaterLogModel(date: selectedDate.value, glassesCount: count),
      );
    } catch (_) {}
  }

  // ── Recalculate macro totals from todayLogs ───────────────────────────────
  void calculateTotals() {
    totalCalories.value = todayLogs.fold(0,   (s, log) => s + log.calories);
    totalProtein.value  = todayLogs.fold(0.0, (s, log) => s + log.protein);
    totalCarbs.value    = todayLogs.fold(0.0, (s, log) => s + log.carbs);
    totalFat.value      = todayLogs.fold(0.0, (s, log) => s + log.fat);
  }

  // ── Navigate ± days and reload ────────────────────────────────────────────
  void navigateDate(int days) =>
      loadDataForDate(selectedDate.value.add(Duration(days: days)));

  // ── Convenience ──────────────────────────────────────────────────────────
  int get remainingCalories =>
      (calorieGoal.value - totalCalories.value).clamp(0, calorieGoal.value);

  String get dateLabel {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d     = selectedDate.value;
    if (d == today) return 'Today';
    final yesterday = today.subtract(const Duration(days: 1));
    if (d == yesterday) return 'Yesterday';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }

  List<DietLogModel> logsForMeal(String mealType) =>
      todayLogs.where((log) => log.mealType == mealType).toList();

  int caloriesForMeal(String mealType) =>
      logsForMeal(mealType).fold(0, (s, log) => s + log.calories);

  // ── Water helpers ─────────────────────────────────────────────────────────
  void addWater() {
    if (waterGlasses.value < waterGoal.value) {
      HapticFeedback.lightImpact();
      updateWaterGlasses(waterGlasses.value + 1);
    }
  }

  void toggleWaterGlass(int index) {
    HapticFeedback.lightImpact();
    updateWaterGlasses(index < waterGlasses.value ? index : index + 1);
  }
}
