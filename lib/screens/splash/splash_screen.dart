import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
    // Orange status bar to match gradient
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFFE84E0F),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    final box = Hive.box('user_profile');
    final onboardingComplete =
        box.get('onboarding_complete', defaultValue: false) as bool;

    final destination = onboardingComplete
        ? () => const HomeScreen()
        : () => OnboardingScreen();

    Get.offAll(
      destination,
      transition: Transition.fade,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.2, -0.3),
            radius: 1.0,
            colors: [
              Color(0xFFFFB800),
              Color(0xFFFF6B35),
              Color(0xFFE84E0F),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Particles ────────────────────────────────────────────────
            ..._buildParticles(),

            // ── Logo + text column ───────────────────────────────────────
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Outer glow ring ──────────────────────────────────────
                SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(25),
                        ),
                      )
                          .animate()
                          .scaleXY(
                            begin: 0.5,
                            end: 1.2,
                            delay: 200.ms,
                            duration: 600.ms,
                            curve: Curves.easeOut,
                          )
                          .fadeIn(delay: 200.ms, duration: 600.ms),

                      // Inner circle
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(38),
                        ),
                      )
                          .animate()
                          .scaleXY(
                            begin: 0.0,
                            end: 1.0,
                            delay: 400.ms,
                            duration: 700.ms,
                            curve: Curves.elasticOut,
                          )
                          .fadeIn(delay: 400.ms, duration: 300.ms),

                      // Dumbbell icon
                      const Icon(
                        Icons.fitness_center_rounded,
                        size: 80,
                        color: Colors.white,
                      )
                          .animate()
                          .scaleXY(
                            begin: 0.0,
                            end: 1.0,
                            delay: 500.ms,
                            duration: 800.ms,
                            curve: Curves.elasticOut,
                          )
                          .rotate(
                            begin: -15 / 360,
                            end: 0,
                            delay: 500.ms,
                            duration: 800.ms,
                            curve: Curves.elasticOut,
                          )
                          .fadeIn(delay: 500.ms, duration: 300.ms),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── "FitForge" text ──────────────────────────────────────
                Text(
                  'FitForge',
                  style: GoogleFonts.poppins(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                )
                    .animate()
                    .slideY(
                      begin: 0.5,
                      end: 0,
                      delay: 900.ms,
                      duration: 500.ms,
                      curve: Curves.easeOut,
                    )
                    .fadeIn(delay: 900.ms, duration: 500.ms),

                const SizedBox(height: 10),

                // ── Tagline ──────────────────────────────────────────────
                Text(
                  'FORGE YOUR BEST SELF',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withAlpha(204),
                    letterSpacing: 4,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1100.ms, duration: 400.ms),
              ],
            ),

            // ── Bottom loading bar ───────────────────────────────────────
            Positioned(
              bottom: 80,
              child: Container(
                width: 60,
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1.5),
                  color: Colors.white.withAlpha(30),
                ),
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.5),
                    color: Colors.white.withAlpha(153),
                  ),
                )
                    .animate()
                    .custom(
                      delay: 400.ms,
                      duration: 1800.ms,
                      curve: Curves.easeInOut,
                      builder: (context, value, child) => FractionallySizedBox(
                        widthFactor: value,
                        child: child,
                      ),
                    )
                    .fadeIn(delay: 400.ms, duration: 300.ms),
              ),
            ),

            // ── Full-screen fade out before navigation ───────────────────
            Positioned.fill(
              child: IgnorePointer(
                child: Container(color: const Color(0xFFFF6B35))
                    .animate()
                    .fadeIn(
                      delay: 2200.ms,
                      duration: 200.ms,
                      curve: Curves.easeIn,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Particle effect ──────────────────────────────────────────────────────
  List<Widget> _buildParticles() {
    final rng = math.Random(42); // fixed seed for deterministic layout
    const count = 8;

    return List.generate(count, (i) {
      final angle = (i / count) * 2 * math.pi;
      final distance = 140.0 + rng.nextDouble() * 60;
      final size = 8.0 + rng.nextDouble() * 4;
      final delay = (i * 50).ms;

      final endX = math.cos(angle) * distance;
      final endY = math.sin(angle) * distance;

      return Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(180),
            ),
          )
              .animate()
              .fadeIn(delay: 600.ms + delay, duration: 200.ms)
              .slideX(
                begin: 0,
                end: endX / 20,
                delay: 600.ms + delay,
                duration: 900.ms,
                curve: Curves.easeOut,
              )
              .slideY(
                begin: 0,
                end: endY / 20,
                delay: 600.ms + delay,
                duration: 900.ms,
                curve: Curves.easeOut,
              )
              .fadeOut(
                delay: 1200.ms + delay,
                duration: 400.ms,
              ),
        ),
      );
    });
  }
}
