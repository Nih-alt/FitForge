import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../theme/app_colors.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final box = Hive.box('user_profile');
    final onboardingComplete = box.get('onboarding_complete', defaultValue: false) as bool;

    if (onboardingComplete) {
      Get.offAll(() => const HomeScreen());
    } else {
      Get.offAll(() => OnboardingScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: AppColors.white,
                size: 44,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              'FitForge',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                letterSpacing: -0.5,
              ),
            )
                .animate(delay: 300.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.3, curve: Curves.easeOut),
            const SizedBox(height: 8),
            Text(
              'FORGE YOUR BEST SELF',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryDark,
                letterSpacing: 3,
              ),
            )
                .animate(delay: 600.ms)
                .fadeIn(duration: 500.ms),
          ],
        ),
      ),
    );
  }
}
