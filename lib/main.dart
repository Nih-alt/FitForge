// FitForge UI Philosophy: Cupertino-first for premium iOS-like feel.
// Prefer CupertinoSwitch, CupertinoAlertDialog, CupertinoActivityIndicator,
// CupertinoDatePicker, and CupertinoPageRoute over their Material equivalents.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'controllers/diet_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/workout_controller.dart';
import 'models/app_settings_model.dart';
import 'models/diet_log_model.dart';
import 'models/measurement_model.dart';
import 'models/personal_record_model.dart';
import 'models/progress_photo_model.dart';
import 'models/user_model.dart';
import 'models/water_log_model.dart';
import 'models/weight_log_model.dart';
import 'models/workout_log_model.dart';
import 'screens/splash/splash_screen.dart';
import 'services/hive_service.dart';
import 'theme/app_theme.dart';

// ── Firebase initialization ────────────────────────────────────────────
// Uncomment once google-services.json / GoogleService-Info.plist are added:
//
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// ───────────────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase ─────────────────────────────────────────────────────────
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // ── Hive (local storage) ─────────────────────────────────────────────
  await Hive.initFlutter();

  // Register all Hive adapters
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(WorkoutLogModelAdapter());
  Hive.registerAdapter(DietLogModelAdapter());
  Hive.registerAdapter(WaterLogModelAdapter());
  Hive.registerAdapter(WeightLogModelAdapter());
  Hive.registerAdapter(MeasurementModelAdapter());
  Hive.registerAdapter(ProgressPhotoModelAdapter());
  Hive.registerAdapter(PersonalRecordModelAdapter());
  Hive.registerAdapter(AppSettingsModelAdapter());

  // Legacy box (used by splash screen for onboarding check)
  await Hive.openBox('user_profile');

  // Open ALL typed boxes directly — ensures they're ready before any read
  await Hive.openBox<AppSettingsModel>('settings_box');
  await Hive.openBox<UserModel>('user_box');
  await Hive.openBox<WorkoutLogModel>('workout_log_box');
  await Hive.openBox<DietLogModel>('diet_log_box');
  await Hive.openBox<WaterLogModel>('water_log_box');
  await Hive.openBox<WeightLogModel>('weight_log_box');
  await Hive.openBox<MeasurementModel>('measurement_box');
  await Hive.openBox<ProgressPhotoModel>('progress_photo_box');
  await Hive.openBox<PersonalRecordModel>('personal_record_box');

  // Read theme SYNCHRONOUSLY from already-opened Hive box
  final initialThemeMode = ThemeController.readInitialThemeMode();
  debugPrint('[main] Initial theme mode: $initialThemeMode');

  // Initialize HiveService (boxes already open, just assigns references)
  final hiveService = HiveService();
  await hiveService.init();
  Get.put(hiveService);

  // ── System chrome ────────────────────────────────────────────────────
  final isDark = initialThemeMode == ThemeMode.dark ||
      (initialThemeMode == ThemeMode.system &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDark ? Colors.black : Colors.white,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  Get.put(UserController());
  Get.put(WorkoutController());
  Get.put(DietController());
  Get.put(ThemeController(initialThemeMode));

  runApp(FitForgeApp(initialThemeMode: initialThemeMode));
}

class FitForgeApp extends StatelessWidget {
  const FitForgeApp({super.key, required this.initialThemeMode});

  final ThemeMode initialThemeMode;

  @override
  Widget build(BuildContext context) {
    final themeCtrl = ThemeController.to;

    return Obx(() => GetMaterialApp(
          title: 'FitForge',
          debugShowCheckedModeBanner: false,

          // ── Theme ──────────────────────────────────────────────────────
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeCtrl.themeMode,

          // ── Navigation ─────────────────────────────────────────────────
          defaultTransition: Transition.cupertino,
          home: const SplashScreen(),

          // ── Global text decoration reset ───────────────────────────────
          builder: (context, child) => DefaultTextStyle.merge(
            style: const TextStyle(decoration: TextDecoration.none),
            child: child!,
          ),
        ));
  }
}

