import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'active_workout_screen.dart';
import 'workout_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
//  WORKOUT DETAIL SCREEN — Full workout info + exercise list
// ════════════════════════════════════════════════════════════════════════════

class WorkoutDetailScreen extends StatelessWidget {
  const WorkoutDetailScreen({super.key, required this.workout});

  final WorkoutData workout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final exercises = _exercisesFor(workout.name);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Scrollable content ──────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top hero section
                  _TopSection(workout: workout),

                  // About section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About this workout',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _descriptionFor(workout.name),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.1, curve: Curves.easeOut),

                  // Exercises header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                    child: Row(
                      children: [
                        Text(
                          'Exercises',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange.withAlpha(25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${exercises.length}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 400.ms),

                  // Exercise cards
                  ...exercises.asMap().entries.map((entry) {
                    final index = entry.key;
                    final exercise = entry.value;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: _ExerciseCard(
                        number: index + 1,
                        exercise: exercise,
                      ),
                    )
                        .animate(
                          delay: Duration(milliseconds: 350 + 80 * index),
                        )
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: 0.06, curve: Curves.easeOut);
                  }),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Bottom button ───────────────────────────────────────────
          Container(
            color: theme.scaffoldBackgroundColor,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: GradientButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => ActiveWorkoutScreen(
                          workoutName: workout.name,
                          exercises: exercises,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Start Workout',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  TOP SECTION — Hero header with gradient & glow (280px)
// ════════════════════════════════════════════════════════════════════════════

class _TopSection extends StatelessWidget {
  const _TopSection({required this.workout});

  final WorkoutData workout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.cardTheme.color ?? AppColors.cardDark,
            theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          // ── Orange glow ─────────────────────────────────────────────
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentOrange.withAlpha(30),
                    AppColors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: -60,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentGold.withAlpha(15),
                    AppColors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  CupertinoNavigationBarBackButton(
                    color: AppColors.accentOrange,
                    onPressed: () => Navigator.of(context).pop(),
                  ),

                  const Spacer(),

                  // Workout name
                  Text(
                    workout.name,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      height: 1.2,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.15, curve: Curves.easeOut),

                  const SizedBox(height: 18),

                  // Tag pills
                  Row(
                    children: [
                      _TagPill(
                        icon: CupertinoIcons.timer,
                        label: '${workout.minutes} min',
                      ),
                      const SizedBox(width: 10),
                      _TagPill(
                        icon: CupertinoIcons.chart_bar_fill,
                        label: workout.difficulty,
                      ),
                      const SizedBox(width: 10),
                      _TagPill(
                        icon: CupertinoIcons.flame_fill,
                        label: '${workout.calories} kcal',
                      ),
                    ],
                  )
                      .animate(delay: 100.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOut),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tag pill for duration / difficulty / calories ─────────────────────────

class _TagPill extends StatelessWidget {
  const _TagPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.accentOrange, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  EXERCISE CARD — Single exercise item
// ════════════════════════════════════════════════════════════════════════════

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.number,
    required this.exercise,
  });

  final int number;
  final ExerciseInfo exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
      ),
      child: Row(
        children: [
          // ── Number badge ─────────────────────────────────────────────
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$number',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentOrange,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // ── Info ─────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  exercise.setsReps,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),

          // ── Muscle group tag ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: theme.colorScheme.surface,
              border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
            ),
            child: Text(
              exercise.muscleGroup,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  EXERCISE DATA — Placeholder exercises per workout
// ════════════════════════════════════════════════════════════════════════════

class ExerciseInfo {
  const ExerciseInfo({
    required this.name,
    required this.setsReps,
    required this.muscleGroup,
  });

  final String name;
  final String setsReps;
  final String muscleGroup;
}

List<ExerciseInfo> _exercisesFor(String workoutName) {
  return _exerciseMap[workoutName] ?? _exerciseMap['default']!;
}

String _descriptionFor(String workoutName) {
  return _descriptionMap[workoutName] ??
      'A balanced workout designed to challenge your body and build overall fitness.';
}

const _descriptionMap = <String, String>{
  'Upper Body Blast':
      'Target your chest, shoulders, and arms with this intense upper body routine designed to build strength and muscle definition.',
  'Morning Cardio Rush':
      'Kickstart your day with this high-energy cardio session that boosts metabolism and improves cardiovascular endurance.',
  'Core & Abs Shred':
      'Sculpt and strengthen your core with this targeted routine hitting every angle of your abs and obliques.',
  'Full Body HIIT':
      'Push your limits with this high-intensity interval workout that torches calories and builds total-body power.',
  'Flexibility Flow':
      'Restore your body with gentle stretches and yoga-inspired poses that improve flexibility and reduce muscle tension.',
  'Active Recovery':
      'Promote healing and reduce soreness with this low-impact session focused on gentle movement and mindful breathing.',
  'Full Body Burn':
      'An all-out compound workout hitting every major muscle group. Designed to maximize calorie burn and build functional strength.',
};

const _exerciseMap = <String, List<ExerciseInfo>>{
  'Upper Body Blast': [
    ExerciseInfo(name: 'Bench Press', setsReps: '4 x 10', muscleGroup: 'Chest'),
    ExerciseInfo(name: 'Shoulder Press', setsReps: '3 x 12', muscleGroup: 'Shoulders'),
    ExerciseInfo(name: 'Bicep Curls', setsReps: '3 x 15', muscleGroup: 'Arms'),
    ExerciseInfo(name: 'Tricep Dips', setsReps: '3 x 12', muscleGroup: 'Arms'),
    ExerciseInfo(name: 'Lat Pulldown', setsReps: '4 x 10', muscleGroup: 'Back'),
    ExerciseInfo(name: 'Push-ups', setsReps: '3 x 15', muscleGroup: 'Chest'),
  ],
  'Morning Cardio Rush': [
    ExerciseInfo(name: 'Jumping Jacks', setsReps: '3 x 30s', muscleGroup: 'Full Body'),
    ExerciseInfo(name: 'High Knees', setsReps: '4 x 20s', muscleGroup: 'Legs'),
    ExerciseInfo(name: 'Burpees', setsReps: '3 x 10', muscleGroup: 'Full Body'),
    ExerciseInfo(name: 'Mountain Climbers', setsReps: '3 x 30s', muscleGroup: 'Core'),
    ExerciseInfo(name: 'Jump Rope', setsReps: '3 x 60s', muscleGroup: 'Full Body'),
  ],
  'Core & Abs Shred': [
    ExerciseInfo(name: 'Crunches', setsReps: '4 x 20', muscleGroup: 'Core'),
    ExerciseInfo(name: 'Plank Hold', setsReps: '3 x 45s', muscleGroup: 'Core'),
    ExerciseInfo(name: 'Russian Twists', setsReps: '3 x 20', muscleGroup: 'Obliques'),
    ExerciseInfo(name: 'Leg Raises', setsReps: '4 x 15', muscleGroup: 'Lower Abs'),
    ExerciseInfo(name: 'Bicycle Crunches', setsReps: '3 x 20', muscleGroup: 'Core'),
  ],
  'Full Body HIIT': [
    ExerciseInfo(name: 'Burpees', setsReps: '4 x 10', muscleGroup: 'Full Body'),
    ExerciseInfo(name: 'Squat Jumps', setsReps: '4 x 15', muscleGroup: 'Legs'),
    ExerciseInfo(name: 'Push-up Variations', setsReps: '3 x 12', muscleGroup: 'Chest'),
    ExerciseInfo(name: 'Lunges', setsReps: '3 x 12', muscleGroup: 'Legs'),
    ExerciseInfo(name: 'Plank Jacks', setsReps: '3 x 20', muscleGroup: 'Core'),
    ExerciseInfo(name: 'Box Jumps', setsReps: '4 x 10', muscleGroup: 'Legs'),
  ],
  'Flexibility Flow': [
    ExerciseInfo(name: 'Cat-Cow Stretch', setsReps: '3 x 30s', muscleGroup: 'Back'),
    ExerciseInfo(name: 'Downward Dog', setsReps: '3 x 30s', muscleGroup: 'Full Body'),
    ExerciseInfo(name: 'Pigeon Pose', setsReps: '2 x 45s', muscleGroup: 'Hips'),
    ExerciseInfo(name: 'Seated Forward Fold', setsReps: '3 x 30s', muscleGroup: 'Hamstrings'),
    ExerciseInfo(name: 'Spinal Twist', setsReps: '2 x 30s', muscleGroup: 'Back'),
  ],
  'Active Recovery': [
    ExerciseInfo(name: 'Foam Rolling', setsReps: '5 x 60s', muscleGroup: 'Full Body'),
    ExerciseInfo(name: 'Light Walking', setsReps: '1 x 5min', muscleGroup: 'Legs'),
    ExerciseInfo(name: 'Gentle Stretching', setsReps: '4 x 30s', muscleGroup: 'Full Body'),
    ExerciseInfo(name: 'Deep Breathing', setsReps: '3 x 60s', muscleGroup: 'Core'),
    ExerciseInfo(name: 'Yoga Flow', setsReps: '1 x 5min', muscleGroup: 'Full Body'),
  ],
  'Full Body Burn': [
    ExerciseInfo(name: 'Squat to Press', setsReps: '4 x 12', muscleGroup: 'Full Body'),
    ExerciseInfo(name: 'Deadlifts', setsReps: '4 x 10', muscleGroup: 'Back & Legs'),
    ExerciseInfo(name: 'Push-up to Row', setsReps: '3 x 12', muscleGroup: 'Chest & Back'),
    ExerciseInfo(name: 'Walking Lunges', setsReps: '3 x 16', muscleGroup: 'Legs'),
    ExerciseInfo(name: 'Plank to Push-up', setsReps: '3 x 10', muscleGroup: 'Core & Arms'),
    ExerciseInfo(name: 'Kettlebell Swings', setsReps: '4 x 15', muscleGroup: 'Full Body'),
  ],
  'default': [
    ExerciseInfo(name: 'Warm-up', setsReps: '1 x 5min', muscleGroup: 'Full Body'),
    ExerciseInfo(name: 'Main Exercise', setsReps: '4 x 12', muscleGroup: 'Full Body'),
    ExerciseInfo(name: 'Accessory Work', setsReps: '3 x 15', muscleGroup: 'Full Body'),
    ExerciseInfo(name: 'Cool-down', setsReps: '1 x 5min', muscleGroup: 'Full Body'),
  ],
};
