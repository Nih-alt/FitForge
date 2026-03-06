import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'workout_detail_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
//  GETX CONTROLLER
// ════════════════════════════════════════════════════════════════════════════

class ActiveWorkoutController extends GetxController {
  ActiveWorkoutController({
    required this.workoutName,
    required this.exercises,
  });

  final String workoutName;
  final List<ExerciseInfo> exercises;

  final elapsedSeconds = 0.obs;
  Timer? _elapsedTimer;

  final currentExerciseIndex = 0.obs;
  late final List<RxInt> setsCompleted;

  final isResting = false.obs;
  final restSecondsLeft = 30.obs;
  static const int restDuration = 30;
  Timer? _restTimer;

  @override
  void onInit() {
    super.onInit();
    setsCompleted = List.generate(exercises.length, (_) => 0.obs);
    _elapsedTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => elapsedSeconds.value++,
    );
  }

  @override
  void onClose() {
    _elapsedTimer?.cancel();
    _restTimer?.cancel();
    super.onClose();
  }

  // ── Formatting ───────────────────────────────────────────────────────────

  String get elapsedFormatted {
    final m = elapsedSeconds.value ~/ 60;
    final s = elapsedSeconds.value % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get formattedTotalTime {
    final m = elapsedSeconds.value ~/ 60;
    final s = elapsedSeconds.value % 60;
    if (m == 0) return '${s}s';
    if (s == 0) return '${m}m';
    return '${m}m ${s}s';
  }

  // ── Set helpers ──────────────────────────────────────────────────────────

  int setsFor(int idx) {
    final parts = exercises[idx].setsReps.split(' x ');
    return int.tryParse(parts[0].trim()) ?? 3;
  }

  bool get currentSetsDone {
    final idx = currentExerciseIndex.value;
    return setsCompleted[idx].value >= setsFor(idx);
  }

  int get totalSetsCompleted =>
      setsCompleted.fold<int>(0, (sum, rx) => sum + rx.value);

  void completeSet() {
    final idx = currentExerciseIndex.value;
    final total = setsFor(idx);
    if (setsCompleted[idx].value < total) {
      setsCompleted[idx].value++;
      HapticFeedback.lightImpact();
      if (setsCompleted[idx].value < total) {
        _startRestTimer();
      }
    }
  }

  // ── Rest timer ───────────────────────────────────────────────────────────

  void _startRestTimer() {
    isResting.value = true;
    restSecondsLeft.value = restDuration;
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (restSecondsLeft.value > 0) {
        restSecondsLeft.value--;
      } else {
        t.cancel();
        isResting.value = false;
        HapticFeedback.mediumImpact();
      }
    });
  }

  void skipRest() {
    _restTimer?.cancel();
    isResting.value = false;
    HapticFeedback.lightImpact();
  }

  void stopTimers() {
    _elapsedTimer?.cancel();
    _restTimer?.cancel();
    isResting.value = false;
  }

  // ── Exercise navigation ──────────────────────────────────────────────────

  bool get isFirstExercise => currentExerciseIndex.value == 0;
  bool get isLastExercise => currentExerciseIndex.value == exercises.length - 1;

  void goToPrevious() {
    if (!isFirstExercise) {
      _restTimer?.cancel();
      isResting.value = false;
      currentExerciseIndex.value--;
    }
  }

  void goToNext() {
    if (!isLastExercise) {
      _restTimer?.cancel();
      isResting.value = false;
      currentExerciseIndex.value++;
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  ACTIVE WORKOUT SCREEN
// ════════════════════════════════════════════════════════════════════════════

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({
    super.key,
    required this.workoutName,
    required this.exercises,
  });

  final String workoutName;
  final List<ExerciseInfo> exercises;

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late final ActiveWorkoutController _ctrl;

  @override
  void initState() {
    super.initState();
    Get.delete<ActiveWorkoutController>(force: true);
    _ctrl = Get.put(
      ActiveWorkoutController(
        workoutName: widget.workoutName,
        exercises: widget.exercises,
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<ActiveWorkoutController>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Obx(() {
          final idx = _ctrl.currentExerciseIndex.value;
          final exercise = widget.exercises[idx];
          final totalSets = _ctrl.setsFor(idx);
          final doneSets = _ctrl.setsCompleted[idx].value;
          final isResting = _ctrl.isResting.value;
          final allDone = _ctrl.currentSetsDone;
          final progress =
              (idx + 1) / widget.exercises.length.toDouble();

          return Column(
            children: [
              // ── Top bar ────────────────────────────────────────────────
              _TopBar(
                workoutName: widget.workoutName,
                controller: _ctrl,
                onQuit: _showQuitDialog,
              ),

              const SizedBox(height: 8),

              // ── Workout progress bar ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _WorkoutProgressBar(
                  progress: progress,
                  current: idx + 1,
                  total: widget.exercises.length,
                ),
              ),

              const SizedBox(height: 12),

              // ── Exercise hero card ─────────────────────────────────────
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _ExerciseHeroCard(
                      key: ValueKey(idx),
                      exercise: exercise,
                      exerciseNumber: idx + 1,
                      totalExercises: widget.exercises.length,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Set tracker / rest timer ───────────────────────────────
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: isResting
                        ? _RestTimer(
                            controller: _ctrl,
                            key: const ValueKey('rest'),
                          )
                        : _SetTracker(
                            doneSets: doneSets,
                            totalSets: totalSets,
                            allDone: allDone,
                            key: ValueKey('sets_$idx'),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Complete Set / Rest / Done button ──────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _CompleteSetButton(
                  isResting: isResting,
                  allDone: allDone,
                  onComplete: _ctrl.completeSet,
                ),
              ),

              const SizedBox(height: 10),

              // ── Bottom navigation ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _BottomNav(
                  isFirst: _ctrl.isFirstExercise,
                  isLast: _ctrl.isLastExercise,
                  onPrevious: _ctrl.goToPrevious,
                  onNext: _ctrl.goToNext,
                  onFinish: _triggerFinish,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  void _showQuitDialog() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(
          'Quit Workout?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            decoration: TextDecoration.none,
          ),
        ),
        content: Text(
          'Your progress will be lost.',
          style: GoogleFonts.inter(
            fontSize: 13,
            decoration: TextDecoration.none,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppColors.accentOrange,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Quit',
              style: GoogleFonts.inter(decoration: TextDecoration.none),
            ),
          ),
        ],
      ),
    );
  }

  void _triggerFinish() {
    _ctrl.stopTimers();
    final totalTime = _ctrl.formattedTotalTime;
    final totalSets = _ctrl.totalSetsCompleted;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 450),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: child,
      ),
      pageBuilder: (ctx, anim1, anim2) => _FinishOverlay(
        totalTime: totalTime,
        totalExercises: widget.exercises.length,
        totalSets: totalSets,
        onDone: () =>
            Navigator.of(ctx).popUntil((route) => route.isFirst),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  TOP BAR — X quit | Workout name | Elapsed timer pill
// ════════════════════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.workoutName,
    required this.controller,
    required this.onQuit,
  });

  final String workoutName;
  final ActiveWorkoutController controller;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // X quit — outlined circle
          GestureDetector(
            onTap: onQuit,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                ),
              ),
              child: Icon(
                CupertinoIcons.xmark,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                size: 16,
              ),
            ),
          ),

          // Workout name — centered
          Expanded(
            child: Text(
              workoutName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                decoration: TextDecoration.none,
              ),
            ),
          ),

          // Elapsed timer — pill shaped
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                ),
              ),
              child: Text(
                controller.elapsedFormatted,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentOrange,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  decoration: TextDecoration.none,
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
//  WORKOUT PROGRESS BAR — thin gradient fill, shows exercise position
// ════════════════════════════════════════════════════════════════════════════

class _WorkoutProgressBar extends StatelessWidget {
  const _WorkoutProgressBar({
    required this.progress,
    required this.current,
    required this.total,
  });

  final double progress;
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Track + fill
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 4,
            child: Stack(
              children: [
                // Track
                Container(
                  color: theme.cardTheme.color,
                  width: double.infinity,
                ),
                // Gradient fill
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.accentGradient,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  EXERCISE HERO CARD — gradient border + radial glow + centered content
// ════════════════════════════════════════════════════════════════════════════

class _ExerciseHeroCard extends StatelessWidget {
  const _ExerciseHeroCard({
    super.key,
    required this.exercise,
    required this.exerciseNumber,
    required this.totalExercises,
  });

  final ExerciseInfo exercise;
  final int exerciseNumber;
  final int totalExercises;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displaySets = exercise.setsReps.replaceAll(' x ', ' × ');

    return Container(
      width: double.infinity,
      // Outer gradient border
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppColors.accentOrange, AppColors.accentGold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Stack(
          children: [
            // Subtle radial orange glow at center
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.85,
                      colors: [
                        AppColors.accentOrange.withAlpha(14),
                        AppColors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Exercise number badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Exercise $exerciseNumber of $totalExercises',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentOrange,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),

                  // Exercise name
                  Text(
                    exercise.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      height: 1.2,
                      decoration: TextDecoration.none,
                    ),
                  ),

                  // Sets × reps — gradient hero number
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) =>
                        AppColors.accentGradient.createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                    child: Text(
                      displaySets,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        height: 1,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),

                  // Bottom tags row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _HeroTag(label: exercise.muscleGroup),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SET TRACKER — label row + set circles, fits inside Expanded flex:3
// ════════════════════════════════════════════════════════════════════════════

class _SetTracker extends StatelessWidget {
  const _SetTracker({
    super.key,
    required this.doneSets,
    required this.totalSets,
    required this.allDone,
  });

  final int doneSets;
  final int totalSets;
  final bool allDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final remaining = totalSets - doneSets;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Label row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sets',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              allDone ? 'All done ✓' : '$remaining remaining',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: allDone
                    ? AppColors.success
                    : isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Set circles row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSets, (i) {
            final isDone = i < doneSets;
            final isCurrent = i == doneSets && !allDone;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _SetCircle(
                setNumber: i + 1,
                isDone: isDone,
                isCurrent: isCurrent,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SetCircle extends StatelessWidget {
  const _SetCircle({
    required this.setNumber,
    required this.isDone,
    required this.isCurrent,
  });

  final int setNumber;
  final bool isDone;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isDone ? AppColors.accentGradient : null,
        color: isDone ? null : theme.cardTheme.color,
        border: Border.all(
          color: isDone
              ? AppColors.transparent
              : isCurrent
                  ? AppColors.accentOrange
                  : isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.accentOrange.withAlpha(50),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Center(
        child: isDone
            ? const Icon(
                CupertinoIcons.checkmark_alt,
                color: AppColors.white,
                size: 20,
              )
            : Text(
                '$setNumber',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isCurrent
                      ? theme.colorScheme.onSurface
                      : isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  decoration: TextDecoration.none,
                ),
              ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  REST TIMER — compact 120px ring + skip button, fits inside Expanded flex:3
// ════════════════════════════════════════════════════════════════════════════

class _RestTimer extends StatelessWidget {
  const _RestTimer({super.key, required this.controller});

  final ActiveWorkoutController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Rest',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            letterSpacing: 1.5,
            decoration: TextDecoration.none,
          ),
        ),

        const SizedBox(height: 10),

        // Circular ring countdown
        Obx(() {
          final progress = controller.restSecondsLeft.value /
              ActiveWorkoutController.restDuration;
          return SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(120, 120),
                  painter: _RestRingPainter(
                    progress: progress,
                    trackColor: isDark
                        ? const Color(0x10FFFFFF)
                        : const Color(0x15000000),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${controller.restSecondsLeft.value}',
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        height: 1,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      'sec',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 10),

        // Skip Rest — small text button
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: controller.skipRest,
          child: Text(
            'Skip Rest',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.accentOrange,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Rest ring CustomPainter ───────────────────────────────────────────────

class _RestRingPainter extends CustomPainter {
  const _RestRingPainter({required this.progress, required this.trackColor});

  final double progress;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 8;
    const strokeWidth = 8.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final progressPaint = Paint()
        ..shader = const SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: [AppColors.accentOrange, AppColors.accentGold],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RestRingPainter old) =>
      old.progress != progress || old.trackColor != trackColor;
}

// ════════════════════════════════════════════════════════════════════════════
//  COMPLETE SET BUTTON — scale-on-press, changes state for rest/done
// ════════════════════════════════════════════════════════════════════════════

class _CompleteSetButton extends StatefulWidget {
  const _CompleteSetButton({
    required this.isResting,
    required this.allDone,
    required this.onComplete,
  });

  final bool isResting;
  final bool allDone;
  final VoidCallback onComplete;

  @override
  State<_CompleteSetButton> createState() => _CompleteSetButtonState();
}

class _CompleteSetButtonState extends State<_CompleteSetButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDisabled = widget.isResting || widget.allDone;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onComplete();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: isDisabled
                ? LinearGradient(
                    colors: isDark
                        ? const [Color(0xFF22223A), Color(0xFF2A2A44)]
                        : [Colors.grey.shade300, Colors.grey.shade400],
                  )
                : AppColors.accentGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: AppColors.accentOrange.withAlpha(50),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              widget.isResting
                  ? 'Rest...'
                  : widget.allDone
                      ? 'All Sets Done  ✓'
                      : 'Complete Set',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDisabled
                    ? isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight
                    : AppColors.white,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  BOTTOM NAV — Previous (#1A1A27 bg) | Next Exercise (outlined orange)
// ════════════════════════════════════════════════════════════════════════════

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.isFirst,
    required this.isLast,
    required this.onPrevious,
    required this.onNext,
    required this.onFinish,
  });

  final bool isFirst;
  final bool isLast;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color;

    return Row(
      children: [
        // Previous — card background, onSurface text
        Expanded(
          child: GestureDetector(
            onTap: isFirst ? null : onPrevious,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isFirst
                    ? cardColor?.withAlpha(80)
                    : cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Previous',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isFirst
                        ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withAlpha(80)
                        : theme.colorScheme.onSurface,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Next Exercise / Finish — outlined orange
        Expanded(
          child: GestureDetector(
            onTap: isLast ? onFinish : onNext,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accentOrange,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  isLast ? 'Finish Workout' : 'Next Exercise',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentOrange,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  FINISH OVERLAY — full screen celebration with floating particles + stats
// ════════════════════════════════════════════════════════════════════════════

class _FinishOverlay extends StatelessWidget {
  const _FinishOverlay({
    required this.totalTime,
    required this.totalExercises,
    required this.totalSets,
    required this.onDone,
  });

  final String totalTime;
  final int totalExercises;
  final int totalSets;
  final VoidCallback onDone;

  // Fixed particle positions [xFraction, yFraction, size, isGold]
  static const List<List<double>> _particles = [
    [0.08, 0.08, 6, 0], [0.88, 0.12, 4, 1], [0.22, 0.22, 5, 0],
    [0.75, 0.18, 7, 1], [0.50, 0.06, 4, 0], [0.15, 0.50, 5, 1],
    [0.92, 0.40, 6, 0], [0.35, 0.78, 4, 1], [0.68, 0.72, 5, 0],
    [0.82, 0.62, 6, 1], [0.10, 0.85, 4, 0], [0.55, 0.90, 5, 1],
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            // Floating particles
            ..._particles.asMap().entries.map((entry) {
              final i = entry.key;
              final p = entry.value;
              final isGold = p[3] > 0.5;
              return Positioned(
                left: size.width * p[0],
                top: size.height * p[1],
                child: Container(
                  width: p[2],
                  height: p[2],
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isGold
                        ? AppColors.accentGold
                        : AppColors.accentOrange,
                  ),
                )
                    .animate(
                      onPlay: (c) => c.repeat(),
                      delay: Duration(milliseconds: i * 170),
                    )
                    .moveY(
                      begin: 0,
                      end: -260,
                      duration: 2800.ms,
                      curve: Curves.easeIn,
                    )
                    .fadeOut(duration: 2800.ms),
              );
            }),

            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Trophy emoji
                    const Text(
                      '🎉',
                      style: TextStyle(
                        fontSize: 72,
                        decoration: TextDecoration.none,
                      ),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.3, 0.3),
                          duration: 700.ms,
                          curve: Curves.elasticOut,
                        ),

                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Workout Complete!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        height: 1.2,
                        decoration: TextDecoration.none,
                      ),
                    )
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.3, curve: Curves.easeOut),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'You crushed it. Keep forging ahead.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        decoration: TextDecoration.none,
                      ),
                    )
                        .animate(delay: 350.ms)
                        .fadeIn(duration: 500.ms),

                    const SizedBox(height: 36),

                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: CupertinoIcons.timer,
                            value: totalTime,
                            label: 'Time',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: CupertinoIcons.bolt_fill,
                            value: '$totalExercises',
                            label: 'Exercises',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: CupertinoIcons.checkmark_seal_fill,
                            value: '$totalSets',
                            label: 'Sets Done',
                          ),
                        ),
                      ],
                    )
                        .animate(delay: 500.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.2, curve: Curves.easeOut),

                    const SizedBox(height: 36),

                    // Back to Home button
                    GradientButton(
                      onPressed: onDone,
                      child: Text(
                        'Back to Home',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    )
                        .animate(delay: 700.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.15, curve: Curves.easeOut),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accentOrange, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              height: 1,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
