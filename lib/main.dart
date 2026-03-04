// FitForge UI Philosophy: Cupertino-first for premium iOS-like feel.
// Prefer CupertinoSwitch, CupertinoAlertDialog, CupertinoActivityIndicator,
// CupertinoDatePicker, and CupertinoPageRoute over their Material equivalents.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/splash/splash_screen.dart';
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
  await Hive.openBox('user_profile');

  // ── System chrome ────────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const FitForgeApp());
}

class FitForgeApp extends StatelessWidget {
  const FitForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FitForge',
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // ── Navigation ─────────────────────────────────────────────────
      defaultTransition: Transition.cupertino,
      home: const SplashScreen(),

      // ── Global text decoration reset ───────────────────────────────
      // Prevents yellow underlines that appear when Text widgets are
      // rendered inside Cupertino overlays (showCupertinoModalPopup)
      // which run outside the normal Material widget tree.
      builder: (context, child) => DefaultTextStyle.merge(
        style: const TextStyle(decoration: TextDecoration.none),
        child: child!,
      ),
    );
  }
}
