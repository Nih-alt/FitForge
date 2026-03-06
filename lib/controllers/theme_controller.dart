import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_settings_model.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final Rx<ThemeMode> _themeMode;

  ThemeController(ThemeMode initial) : _themeMode = initial.obs;

  ThemeMode get themeMode => _themeMode.value;

  /// Change theme and persist to Hive immediately.
  /// Accepts a String: 'light', 'dark', or 'system'.
  Future<void> setThemeMode(String mode) async {
    final themeMode = _parseThemeMode(mode);
    _themeMode.value = themeMode;
    Get.changeThemeMode(themeMode);

    // Persist directly to Hive — no indirection
    try {
      final box = Hive.box<AppSettingsModel>('settings_box');
      final settings = box.get('app_settings') ?? AppSettingsModel();
      settings.themeMode = mode;
      await box.put('app_settings', settings);
      debugPrint('[ThemeController] Saved theme: $mode');
    } catch (e) {
      debugPrint('[ThemeController] Failed to save theme: $e');
    }
  }

  static ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Synchronously read theme from Hive BEFORE controller init.
  /// Called in main() after Hive boxes are opened.
  static ThemeMode readInitialThemeMode() {
    try {
      final box = Hive.box<AppSettingsModel>('settings_box');
      final settings = box.get('app_settings');
      final mode = settings?.themeMode ?? 'system';
      debugPrint('[ThemeController] Read initial theme from Hive: $mode');
      return _parseThemeMode(mode);
    } catch (e) {
      debugPrint('[ThemeController] Failed to read theme: $e');
      return ThemeMode.system;
    }
  }
}
