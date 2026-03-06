import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../controllers/user_controller.dart';
import '../../models/app_settings_model.dart';
import '../../models/user_model.dart';
import '../../models/weight_log_model.dart';
import '../../screens/home/home_screen.dart';
import '../../services/hive_service.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  // ── Step 2: Personal Info ────────────────────────────────────────────
  final nameController = TextEditingController();
  final selectedDob = Rxn<DateTime>();

  int? get calculatedAge {
    final dob = selectedDob.value;
    if (dob == null) return null;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  // ── Step 3: Body Stats ───────────────────────────────────────────────
  final weight = 70.0.obs;
  final height = 170.0.obs;

  // ── Step 4: Goal ─────────────────────────────────────────────────────
  final selectedGoal = ''.obs;

  static const int totalPages = 4;

  @override
  void onClose() {
    pageController.dispose();
    nameController.dispose();
    super.onClose();
  }

  // ── Navigation ───────────────────────────────────────────────────────

  bool _validateCurrentPage() {
    switch (currentPage.value) {
      case 0:
        return true;
      case 1:
        if (nameController.text.trim().isEmpty) {
          _showError('Please enter your name');
          return false;
        }
        final age = calculatedAge;
        if (age == null) {
          _showError('Please select your date of birth');
          return false;
        }
        if (age < 10 || age > 100) {
          _showError('Age must be between 10 and 100 years');
          return false;
        }
        return true;
      case 2:
        return true;
      case 3:
        if (selectedGoal.value.isEmpty) {
          _showError('Please select a goal');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void nextPage() {
    if (!_validateCurrentPage()) return;

    if (currentPage.value < totalPages - 1) {
      pageController.animateToPage(
        currentPage.value + 1,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _saveAndFinish();
    }
  }

  void skipToLast() {
    pageController.animateToPage(
      totalPages - 1,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  // ── Body Stats Steppers ──────────────────────────────────────────────

  void incrementWeight() {
    if (weight.value < 300) {
      weight.value = (weight.value * 2 + 1).round() / 2;
    }
  }

  void decrementWeight() {
    if (weight.value > 20) {
      weight.value = (weight.value * 2 - 1).round() / 2;
    }
  }

  void incrementHeight() {
    if (height.value < 250) height.value++;
  }

  void decrementHeight() {
    if (height.value > 50) height.value--;
  }

  /// Try to set weight from manual input. Returns true if valid.
  bool setWeightManual(String text) {
    final val = double.tryParse(text);
    if (val != null && val >= 20 && val <= 300) {
      weight.value = (val * 2).round() / 2; // snap to 0.5
      return true;
    }
    return false;
  }

  /// Try to set height from manual input. Returns true if valid.
  bool setHeightManual(String text) {
    final val = double.tryParse(text);
    if (val != null && val >= 50 && val <= 250) {
      height.value = val.roundToDouble();
      return true;
    }
    return false;
  }

  // ── Goal Selection ───────────────────────────────────────────────────

  void selectGoal(String goal) => selectedGoal.value = goal;

  // ── Persistence ──────────────────────────────────────────────────────

  Future<void> _saveAndFinish() async {
    try {
      final hive = Get.find<HiveService>();
      final userCtrl = Get.find<UserController>();

      final name = nameController.text.trim().isEmpty
          ? 'Athlete'
          : nameController.text.trim();
      final dob = selectedDob.value ?? DateTime(2000, 1, 1);
      final age = calculatedAge ?? 25;

      // Save user model
      final userModel = UserModel(
        name: name,
        dateOfBirth: dob,
        age: age,
        weight: weight.value,
        height: height.value,
        goal: selectedGoal.value,
        createdAt: DateTime.now(),
      );
      await userCtrl.saveNewUser(userModel);

      // Save default app settings
      final defaultSettings = AppSettingsModel(
        themeMode: 'system',
        weightUnit: 'kg',
        heightUnit: 'cm',
        workoutReminderOn: true,
        mealReminderOn: true,
        waterReminderOn: true,
        progressUpdateOn: true,
        achievementOn: true,
        weeklyWorkoutGoal: 4,
        dailyCalorieGoal: 2200,
        dailyWaterGoal: 8,
        dailyStepsGoal: 10000,
      );
      await userCtrl.saveSettings(defaultSettings);

      // Save initial weight log
      await hive.saveWeightLog(WeightLogModel(
        date: DateTime.now(),
        weight: weight.value,
      ));

      // Mark onboarding complete in legacy box
      final box = Hive.box('user_profile');
      await box.put('onboarding_complete', true);

      Get.offAll(() => const HomeScreen());
    } catch (e) {
      _showError('Failed to save data. Please try again.');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  void _showError(String message) {
    if (Get.isSnackbarOpen) return;
    Get.rawSnackbar(
      message: message,
      backgroundColor: const Color(0xFF1A1A27),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }
}
