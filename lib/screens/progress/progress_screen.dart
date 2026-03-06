import 'dart:io';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/workout_controller.dart' show WorkoutController;
import '../../models/workout_log_model.dart';
import '../../theme/app_colors.dart';
import 'workout_summary_screen.dart';

// ============================================================================
//  PROGRESS SCREEN — Premium analytics dashboard
// ============================================================================

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // -- Body tab state --
  final Map<String, int> _measurements = {
    'Chest': 95,
    'Waist': 82,
    'Hips': 94,
    'Biceps': 35,
    'Thighs': 55,
  };
  final Map<String, double> _measurementChanges = {
    'Chest': 1.2,
    'Waist': -2.1,
    'Hips': -0.5,
    'Biceps': 1.8,
    'Thighs': 0.6,
  };

  // -- PR state --
  final Map<String, String> _prValues = {
    'Bench Press': '80 kg',
    'Squat': '100 kg',
    'Deadlift': '120 kg',
    'Pull-ups': '15 reps',
    'Plank': '3:20 min',
  };
  final Set<String> _newPRs = {'Bench Press', 'Deadlift'};

  // -- Photos state --
  final List<_ProgressPhoto> _photos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildAppBar(context),
          Container(
            color: theme.scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Material(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.accentOrange,
                indicatorWeight: 2.5,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppColors.accentOrange,
                unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                labelPadding: EdgeInsets.zero,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Body'),
                  Tab(text: 'Workouts'),
                  Tab(text: 'Photos'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildBodyTab(),
                _buildWorkoutsTab(),
                _buildPhotosTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your fitness journey',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
              ),
              child: const Icon(
                CupertinoIcons.share,
                color: AppColors.accentOrange,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  //  TAB 1 — OVERVIEW
  // ==========================================================================

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const _StreakCard()
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.15, curve: Curves.easeOut),
          const SizedBox(height: 20),
          const _WeeklySummaryCard()
              .animate(delay: 100.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.15, curve: Curves.easeOut),
          const SizedBox(height: 20),
          _ActivityCalendar(onCellTap: _showActivityDetail)
              .animate(delay: 200.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.15, curve: Curves.easeOut),
          const SizedBox(height: 20),
          const _WeightProgressGraph()
              .animate(delay: 300.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.15, curve: Curves.easeOut),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ==========================================================================
  //  TAB 2 — BODY
  // ==========================================================================

  Widget _buildBodyTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const _BmiCard()
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.15, curve: Curves.easeOut),
          const SizedBox(height: 20),
          _BodyMeasurementsWidget(
            measurements: _measurements,
            changes: _measurementChanges,
            onUpdate: _showUpdateMeasurementsSheet,
            onRowTap: _showMeasurementDetail,
          )
              .animate(delay: 100.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.15, curve: Curves.easeOut),
          const SizedBox(height: 20),
          const _CaloriesBurnedGraph()
              .animate(delay: 200.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.15, curve: Curves.easeOut),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ==========================================================================
  //  TAB 3 — WORKOUTS
  // ==========================================================================

  Widget _buildWorkoutsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _PersonalRecordsWidget(
            prValues: _prValues,
            newPRs: _newPRs,
            onTap: _showPRDetail,
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.15, curve: Curves.easeOut),
          const SizedBox(height: 20),
          _WorkoutHistoryWidget(logs: Get.find<WorkoutController>().workoutLogs, onTap: _openWorkoutSummary)
              .animate(delay: 100.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.15, curve: Curves.easeOut),
          const SizedBox(height: 20),
          const _MostTrainedMuscles()
              .animate(delay: 200.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.15, curve: Curves.easeOut),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ==========================================================================
  //  TAB 4 — PHOTOS
  // ==========================================================================

  Widget _buildPhotosTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _ProgressPhotosWidget(
            photos: _photos,
            onAddPhoto: _showAddPhotoSheet,
            onCompare: _showCompare,
            onPhotoTap: _showPhotoFullScreen,
            onLongPressPhoto: _showDeletePhotoSheet,
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.15, curve: Curves.easeOut),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ==========================================================================
  //  INTERACTION HANDLERS
  // ==========================================================================

  // -- Activity calendar cell tap --
  void _showActivityDetail(DateTime date, int activityLevel) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final workoutCtrl = Get.find<WorkoutController>();
    const dayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final dateStr =
        '${dayNames[date.weekday - 1]}, ${date.day} ${monthNames[date.month - 1]}';
    final dayLogs = workoutCtrl.workoutLogs
        .where((log) =>
            log.date.year == date.year &&
            log.date.month == date.month &&
            log.date.day == date.day)
        .toList();
    final totalDurationMinutes =
        dayLogs.fold<int>(0, (sum, log) => sum + log.durationSeconds) ~/
            60;
    final totalCalories =
        dayLogs.fold<int>(0, (sum, log) => sum + log.caloriesBurned);
    final workoutNames = dayLogs.isEmpty
        ? 'Rest day'
        : dayLogs.map((log) => log.workoutName).join(', ');

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withAlpha(60),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      dateStr,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(CupertinoIcons.xmark_circle_fill,
                        color: AppColors.accentOrange, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (activityLevel == 0) ...[
                Text('\u{1F634}',
                    style: GoogleFonts.poppins(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  'Rest Day',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Recovery is part of the journey',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ] else ...[
                _sheetStatRow(CupertinoIcons.flame_fill, 'Workout',
                    workoutNames),
                const SizedBox(height: 12),
                _sheetStatRow(CupertinoIcons.timer, 'Duration',
                    '$totalDurationMinutes min'),
                const SizedBox(height: 12),
                _sheetStatRow(CupertinoIcons.bolt_fill, 'Calories',
                    '$totalCalories kcal'),
                const SizedBox(height: 12),
                _sheetStatRow(
                    CupertinoIcons.list_bullet, 'Workouts', '${dayLogs.length}'),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetStatRow(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentOrange, size: 18),
          const SizedBox(width: 12),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }

  // -- Update measurements sheet --
  void _showUpdateMeasurementsSheet() {
    final controllers = <String, TextEditingController>{};
    for (final entry in _measurements.entries) {
      controllers[entry.key] =
          TextEditingController(text: entry.value.toString());
    }

    showCupertinoModalPopup(
      context: context,
      builder: (_) => _UpdateMeasurementsSheet(
        controllers: controllers,
        onSave: (newValues) {
          setState(() {
            for (final entry in newValues.entries) {
              final old = _measurements[entry.key] ?? 0;
              final diff = entry.value - old;
              _measurements[entry.key] = entry.value;
              _measurementChanges[entry.key] = diff.toDouble();
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  // -- Measurement row detail --
  void _showMeasurementDetail(String name) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final value = _measurements[name] ?? 0;
    final change = _measurementChanges[name] ?? 0;
    final isUp = change >= 0;

    // Placeholder 6-month history
    final rng = math.Random(name.hashCode);
    final spots = List.generate(6, (i) {
      return FlSpot(
          i.toDouble(), value - 3 + rng.nextDouble() * 6 + i * 0.3);
    });

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withAlpha(60),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(name,
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface)),
              const SizedBox(height: 8),
              Text('$value cm',
                  style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentOrange)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isUp
                        ? CupertinoIcons.arrow_up_right
                        : CupertinoIcons.arrow_down_right,
                    size: 14,
                    color: isUp ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${change.abs()} cm since last update',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isUp ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 160,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            const m = [
                              'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'
                            ];
                            final idx = v.toInt();
                            if (idx >= 0 && idx < m.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(m[idx],
                                    style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        gradient: AppColors.accentGradient,
                        barWidth: 2.5,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                            radius: 3,
                            color: AppColors.accentOrange,
                            strokeWidth: 0,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.accentOrange.withAlpha(30),
                              AppColors.accentOrange.withAlpha(0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _showUpdateMeasurementsSheet();
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text('Edit Value',
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -- PR detail --
  void _showPRDetail(String exercise) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final currentValue = _prValues[exercise] ?? '';
    final unit = currentValue.contains('kg')
        ? 'kg'
        : currentValue.contains('reps')
            ? 'reps'
            : 'min';
    final numericStr = currentValue.split(' ').first;

    // Placeholder history
    final history = List.generate(5, (i) {
      final daysAgo = (i + 1) * 14;
      final val = unit == 'kg'
          ? '${int.parse(numericStr) - (i + 1) * 5} $unit'
          : unit == 'reps'
              ? '${int.parse(numericStr) - (i + 1) * 2} $unit'
              : currentValue;
      return _PRHistoryEntry('${daysAgo}d ago', val);
    });

    final editController = TextEditingController(text: numericStr);

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withAlpha(60),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(exercise,
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  ShaderMask(
                    shaderCallback: (b) =>
                        AppColors.accentGradient.createShader(b),
                    child: Text(currentValue,
                        style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white)),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('History',
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface)),
                  ),
                  const SizedBox(height: 10),
                  ...history.map((h) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accentOrange.withAlpha(80),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(h.date,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                            const Spacer(),
                            Text(h.value,
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface)),
                          ],
                        ),
                      )),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Update PR',
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoTextField(
                          controller: editController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.accentOrange, width: 1.5),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          placeholder: 'Value',
                          placeholderStyle: GoogleFonts.inter(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(unit,
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      final newVal = editController.text.trim();
                      if (newVal.isNotEmpty) {
                        setState(() {
                          _prValues[exercise] = '$newVal $unit';
                          _newPRs.add(exercise);
                        });
                      }
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text('Save PR',
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -- Workout card tap --
  void _openWorkoutSummary(WorkoutLogModel log) {
    // Format duration
    final totalSec = log.durationSeconds;
    final h = totalSec ~/ 3600;
    final m = (totalSec % 3600) ~/ 60;
    final durationStr = h > 0 ? '${h}h ${m}m' : '${m}m';

    // Format date as dd MMM yyyy
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dateStr =
        '${log.date.day.toString().padLeft(2, '0')} ${monthNames[log.date.month - 1]} ${log.date.year}';

    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => WorkoutSummaryScreen(
          name: log.workoutName,
          date: dateStr,
          duration: durationStr,
          calories: '${log.caloriesBurned}',
          exerciseCount: log.exercisesCompleted,
          exerciseNames: log.exercises,
        ),
      ),
    );
  }

  // -- Add photo --
  void _showAddPhotoSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text('Add Progress Photo',
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface)),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: Text('\u{1F4F7}  Take Photo',
                style: GoogleFonts.inter(
                    fontSize: 16, color: AppColors.accentOrange)),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: Text('\u{1F5BC}  Choose from Gallery',
                style: GoogleFonts.inter(
                    fontSize: 16, color: AppColors.accentOrange)),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null || !mounted) return;
    _showPhotoConfirmation(File(picked.path));
  }

  void _showPhotoConfirmation(File imageFile) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final weightController = TextEditingController(text: '76.2');
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withAlpha(60),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Save Progress Photo',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(imageFile,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.calendar,
                                  size: 16,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                              const SizedBox(width: 8),
                              Text(dateStr,
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: theme.colorScheme.onSurface)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CupertinoTextField(
                          controller: weightController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.inter(
                              fontSize: 14, color: theme.colorScheme.onSurface),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          prefix: Padding(
                            padding: const EdgeInsets.only(left: 14),
                            child: Icon(CupertinoIcons.gauge,
                                size: 16,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          ),
                          suffix: Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: Text('kg',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _photos.add(_ProgressPhoto(
                          file: imageFile,
                          date: dateStr,
                          weight: weightController.text.trim(),
                        ));
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentOrange.withAlpha(40),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text('Save Photo',
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -- Compare --
  void _showCompare() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_photos.length < 2) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text('Not enough photos',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
          content: Text('Add at least 2 photos to compare',
              style:
                  GoogleFonts.inter(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          actions: [
            CupertinoDialogAction(
              child: Text('OK',
                  style: GoogleFonts.inter(color: AppColors.accentOrange)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withAlpha(60),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('Compare Progress',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface)),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(_photos.first.file,
                                  fit: BoxFit.cover,
                                  width: double.infinity),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(_photos.first.date,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                          Text('${_photos.first.weight} kg',
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface)),
                        ],
                      ),
                    ),
                    Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: AppColors.accentOrange.withAlpha(40),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(_photos.last.file,
                                  fit: BoxFit.cover,
                                  width: double.infinity),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(_photos.last.date,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                          Text('${_photos.last.weight} kg',
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // -- Photo full screen --
  void _showPhotoFullScreen(_ProgressPhoto photo) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(CupertinoIcons.xmark,
                          color: theme.colorScheme.onSurface, size: 22),
                    ),
                    Column(
                      children: [
                        Text(photo.date,
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface)),
                        Text('${photo.weight} kg',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _confirmDeletePhoto(photo, popAfter: true),
                      child: const Icon(CupertinoIcons.trash,
                          color: AppColors.error, size: 22),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  child: Image.file(photo.file, fit: BoxFit.contain),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -- Delete photo --
  void _showDeletePhotoSheet(_ProgressPhoto photo) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _confirmDeletePhoto(photo);
            },
            child: Text('\u{1F5D1}  Delete Photo',
                style: GoogleFonts.inter(fontSize: 16)),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
        ),
      ),
    );
  }

  void _confirmDeletePhoto(_ProgressPhoto photo, {bool popAfter = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('Delete Photo?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('This action cannot be undone.',
            style: GoogleFonts.inter()),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context); // close dialog
              if (popAfter) Navigator.pop(context); // close full screen
              setState(() => _photos.remove(photo));
            },
            child: Text('Delete', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
//  DATA CLASSES
// ============================================================================

class _ProgressPhoto {
  _ProgressPhoto({required this.file, required this.date, required this.weight});
  final File file;
  final String date;
  final String weight;
}

class _PRHistoryEntry {
  const _PRHistoryEntry(this.date, this.value);
  final String date;
  final String value;
}

// ============================================================================
//  UPDATE MEASUREMENTS BOTTOM SHEET
// ============================================================================

class _UpdateMeasurementsSheet extends StatelessWidget {
  const _UpdateMeasurementsSheet({
    required this.controllers,
    required this.onSave,
  });

  final Map<String, TextEditingController> controllers;
  final void Function(Map<String, int>) onSave;

  static const _icons = {
    'Chest': CupertinoIcons.person_fill,
    'Waist': CupertinoIcons.resize,
    'Hips': CupertinoIcons.circle_grid_hex_fill,
    'Biceps': CupertinoIcons.hand_raised_fill,
    'Thighs': CupertinoIcons.arrow_up_arrow_down,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withAlpha(60),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Update Measurements',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface)),
                const SizedBox(height: 20),
                ...controllers.entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(_icons[entry.key] ?? CupertinoIcons.circle,
                              color: AppColors.accentOrange, size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(entry.key,
                                style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface)),
                          ),
                          SizedBox(
                            width: 80,
                            child: CupertinoTextField(
                              controller: entry.value,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface),
                              decoration: BoxDecoration(
                                color: theme.scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.accentOrange, width: 1.5),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 10),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('cm',
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    final values = <String, int>{};
                    for (final e in controllers.entries) {
                      values[e.key] = int.tryParse(e.value.text) ?? 0;
                    }
                    onSave(values);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentOrange.withAlpha(40),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text('Save Changes',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
//  STREAK CARD — Hero element
// ============================================================================

class _StreakCard extends StatelessWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final workoutCtrl = Get.find<WorkoutController>();

    return Obx(() {
      final streak = workoutCtrl.currentStreak.value;
      final longest = workoutCtrl.calculateLongestStreak();

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            width: 1.5,
            color: AppColors.accentOrange.withAlpha(60),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentOrange.withAlpha(30),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentOrange.withAlpha(60),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),
                          Text('\u{1F525}',
                              style: GoogleFonts.poppins(fontSize: 40)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: streak),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.accentGradient.createShader(bounds),
                            child: Text('$value',
                                style: GoogleFonts.poppins(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                  height: 1,
                                )),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Day Streak',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface)),
                    const SizedBox(height: 2),
                    Text(streak == 0 ? 'Start your streak!' : 'Keep it going!',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Longest streak: $longest days',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accentOrange)),
            ),
          ],
        ),
      );
    });
  }
}

// ============================================================================
//  WEEKLY SUMMARY CARD
// ============================================================================

class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard();

  String _formatCalories(int cal) {
    if (cal < 1000) return '$cal';
    final str = cal.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workoutCtrl = Get.find<WorkoutController>();

    return Obx(() {
      final workouts = workoutCtrl.weeklyWorkoutsCompleted.value;
      final calories = workoutCtrl.totalCaloriesBurned.value;
      final activeTime = workoutCtrl.totalActiveTime.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This Week',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _SummaryStatCard(
                      icon: CupertinoIcons.flame_fill,
                      iconColor: AppColors.accentOrange,
                      value: '$workouts',
                      label: 'completed',
                      title: 'Workouts')),
              const SizedBox(width: 10),
              Expanded(
                  child: _SummaryStatCard(
                      icon: CupertinoIcons.bolt_fill,
                      iconColor: AppColors.accentGold,
                      value: _formatCalories(calories),
                      label: 'burned',
                      title: 'Calories')),
              const SizedBox(width: 10),
              Expanded(
                  child: _SummaryStatCard(
                      icon: CupertinoIcons.timer,
                      iconColor: AppColors.success,
                      value: activeTime,
                      label: 'total',
                      title: 'Active Time')),
            ],
          ),
        ],
      );
    });
  }
}

class _SummaryStatCard extends StatelessWidget {
  const _SummaryStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.title,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          const SizedBox(height: 4),
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: iconColor)),
        ],
      ),
    );
  }
}

// ============================================================================
//  ACTIVITY CALENDAR — GitHub-style heatmap with cell tap
// ============================================================================

class _ActivityCalendar extends StatelessWidget {
  const _ActivityCalendar({required this.onCellTap});

  final void Function(DateTime date, int level) onCellTap;

  static const _weeks = 10;
  static const _daysPerWeek = 7;

  Color _activityColor(int level, BuildContext context) {
    switch (level) {
      case 0:
        return const Color(0xFF1A1A27);
      case 1:
        return const Color(0x40FF6B35);
      case 2:
        return const Color(0x80FF6B35);
      case 3:
        return const Color(0xFFFF6B35);
      default:
        return const Color(0xFF1A1A27);
    }
  }

  String get _monthYear {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final workoutCtrl = Get.find<WorkoutController>();

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final startDate = todayDate.subtract(const Duration(days: 69));

    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Activity',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface)),
            Text(_monthYear,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
          ),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final cellSize =
                      (constraints.maxWidth - (_weeks - 1) * 4) / _weeks;
                  final clampedSize = cellSize.clamp(0.0, 16.0);

                  return Column(
                    children: List.generate(_daysPerWeek, (dayIndex) {
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: dayIndex < _daysPerWeek - 1 ? 4 : 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(_weeks, (weekIndex) {
                            final dataIndex =
                                weekIndex * _daysPerWeek + dayIndex;
                            final cellDate = startDate.add(Duration(days: weekIndex * 7 + dayIndex));
                            final isToday = cellDate.year == todayDate.year &&
                                cellDate.month == todayDate.month &&
                                cellDate.day == todayDate.day;
                            final level = workoutCtrl.activityLevel(cellDate);

                            return GestureDetector(
                                onTap: () => onCellTap(cellDate, level),
                              child: AnimatedContainer(
                                duration: Duration(
                                    milliseconds: 300 + dataIndex * 15),
                                width: clampedSize,
                                height: clampedSize,
                                decoration: BoxDecoration(
                                  color: _activityColor(level, context),
                                  borderRadius: BorderRadius.circular(3),
                                  border: isToday
                                      ? Border.all(
                                          color: AppColors.accentGold,
                                          width: 1.5)
                                      : null,
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Less',
                      style: GoogleFonts.inter(
                          fontSize: 10, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  const SizedBox(width: 6),
                  ...[0, 1, 2, 3].map((level) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _activityColor(level, context),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      )),
                  const SizedBox(width: 6),
                  Text('More',
                      style: GoogleFonts.inter(
                          fontSize: 10, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                ],
              ),
            ],
          ),
        ),
      ],
    ));
  }
}

// ============================================================================
//  WEIGHT PROGRESS GRAPH
// ============================================================================

class _WeightProgressGraph extends StatelessWidget {
  const _WeightProgressGraph();

  static final List<FlSpot> _weightData = List.generate(30, (i) {
    const base = 78.5;
    final trend = -0.08 * i;
    final noise = math.sin(i * 0.7) * 0.4 + math.cos(i * 1.3) * 0.3;
    return FlSpot(i.toDouble(), base + trend + noise);
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Weight Progress',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
              ),
              child: Text('Last 30 days',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          height: 220,
          padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: isDark ? const Color(0x08FFFFFF) : const Color(0x0A000000),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 7,
                    getTitlesWidget: (value, _) {
                      final day = value.toInt();
                      if (day == 0 || day == 7 || day == 14 ||
                          day == 21 || day == 29) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('D${day + 1}',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: 1,
                    getTitlesWidget: (value, _) {
                      if (value == value.roundToDouble() &&
                          value >= 75 &&
                          value <= 79) {
                        return Text('${value.toInt()}',
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minY: 74.5,
              maxY: 79.5,
              lineBarsData: [
                LineChartBarData(
                  spots: _weightData,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  gradient: AppColors.accentGradient,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, xPercentage, bar, index) =>
                        FlDotCirclePainter(
                      radius: 3,
                      color: AppColors.accentOrange,
                      strokeWidth: 0,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.accentOrange.withAlpha(40),
                        AppColors.accentOrange.withAlpha(0),
                      ],
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => theme.colorScheme.surface,
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        'Day ${spot.x.toInt() + 1}\n',
                        GoogleFonts.inter(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        children: [
                          TextSpan(
                            text: '${spot.y.toStringAsFixed(1)} kg',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentOrange),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
            ),
            duration: const Duration(milliseconds: 800),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
//  BMI CARD
// ============================================================================

class _BmiCard extends StatelessWidget {
  const _BmiCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
      ),
      child: Column(
        children: [
          Text('Body Mass Index',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface)),
          const SizedBox(height: 20),
          SizedBox(
            width: 220,
            height: 130,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 22.1),
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CustomPaint(
                  painter: _BmiGaugePainter(bmi: value, needleColor: theme.colorScheme.onSurface),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(value.toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                  height: 1)),
                          const SizedBox(height: 2),
                          Text('Normal',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _bmiLabel('Under', const Color(0xFFFF4D6A), context),
              _bmiLabel('Normal', AppColors.success, context),
              _bmiLabel('Over', const Color(0xFFFFB800), context),
              _bmiLabel('Obese', const Color(0xFFFF4D6A), context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bmiLabel(String text, Color color, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text,
            style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
      ],
    );
  }
}

class _BmiGaugePainter extends CustomPainter {
  _BmiGaugePainter({required this.bmi, required this.needleColor});
  final double bmi;
  final Color needleColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 4);
    final radius = size.width / 2 - 12;
    const strokeWidth = 14.0;

    final segments = <_ArcSegment>[
      _ArcSegment(const Color(0xFFFF4D6A), 0.22),
      _ArcSegment(AppColors.success, 0.35),
      _ArcSegment(const Color(0xFFFFB800), 0.23),
      _ArcSegment(const Color(0xFFFF4D6A), 0.20),
    ];

    var startAngle = math.pi;
    for (final segment in segments) {
      final sweepAngle = math.pi * segment.fraction;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = segment.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweepAngle;
    }

    final clampedBmi = bmi.clamp(15.0, 40.0);
    final needleAngle = math.pi + ((clampedBmi - 15) / 25) * math.pi;
    final needleLength = radius - 20;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    canvas.drawLine(
        center,
        needleEnd,
        Paint()
          ..color = needleColor.withAlpha(10)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round);
    canvas.drawLine(
        center,
        needleEnd,
        Paint()
          ..color = needleColor
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round);
    canvas.drawCircle(center, 5, Paint()..color = needleColor);
  }

  @override
  bool shouldRepaint(_BmiGaugePainter old) => old.bmi != bmi || old.needleColor != needleColor;
}

class _ArcSegment {
  const _ArcSegment(this.color, this.fraction);
  final Color color;
  final double fraction;
}

// ============================================================================
//  BODY MEASUREMENTS — with tap interactions
// ============================================================================

class _BodyMeasurementsWidget extends StatelessWidget {
  const _BodyMeasurementsWidget({
    required this.measurements,
    required this.changes,
    required this.onUpdate,
    required this.onRowTap,
  });

  final Map<String, int> measurements;
  final Map<String, double> changes;
  final VoidCallback onUpdate;
  final void Function(String name) onRowTap;

  static const _icons = {
    'Chest': CupertinoIcons.person_fill,
    'Waist': CupertinoIcons.resize,
    'Hips': CupertinoIcons.circle_grid_hex_fill,
    'Biceps': CupertinoIcons.hand_raised_fill,
    'Thighs': CupertinoIcons.arrow_up_arrow_down,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final entries = measurements.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Measurements',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface)),
            GestureDetector(
              onTap: onUpdate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Update',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
          ),
          child: Column(
            children: entries.asMap().entries.map((e) {
              final i = e.key;
              final name = e.value.key;
              final value = e.value.value;
              final change = changes[name] ?? 0;
              final isUp = change >= 0;
              final icon = _icons[name] ?? CupertinoIcons.circle;

              return Column(
                children: [
                  GestureDetector(
                    onTap: () => onRowTap(name),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.accentOrange.withAlpha(18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon,
                                color: AppColors.accentOrange, size: 16),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(name,
                                style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface)),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isUp
                                    ? CupertinoIcons.arrow_up_right
                                    : CupertinoIcons.arrow_down_right,
                                size: 12,
                                color: isUp
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                              const SizedBox(width: 2),
                              Text('${change.abs()}',
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isUp
                                          ? AppColors.success
                                          : AppColors.error)),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Text('$value cm',
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accentOrange)),
                        ],
                      ),
                    ),
                  ),
                  if (i < entries.length - 1)
                    Divider(
                        height: 1,
                        color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                        indent: 66),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
//  CALORIES BURNED GRAPH
// ============================================================================

class _CaloriesBurnedGraph extends StatelessWidget {
  const _CaloriesBurnedGraph();

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _values = [420.0, 580.0, 350.0, 620.0, 480.0, 390.0, 0.0];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Calories Burned',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface)),
        const SizedBox(height: 14),
        Container(
          height: 200,
          padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 700,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => theme.colorScheme.surface,
                  tooltipRoundedRadius: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${_values[group.x.toInt()].toInt()} kcal',
                      GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentOrange),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(_days[value.toInt()],
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: List.generate(7, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: _values[i],
                      width: 24,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(6)),
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [AppColors.accentOrange, AppColors.accentGold],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
//  PERSONAL RECORDS — with tap
// ============================================================================

class _PersonalRecordsWidget extends StatelessWidget {
  const _PersonalRecordsWidget({
    required this.prValues,
    required this.newPRs,
    required this.onTap,
  });

  final Map<String, String> prValues;
  final Set<String> newPRs;
  final void Function(String exercise) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final entries = prValues.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Personal Records \u{1F3C6}',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface)),
        const SizedBox(height: 14),
        ...List.generate(entries.length, (i) {
          final exercise = entries[i].key;
          final value = entries[i].value;
          final isNew = newPRs.contains(exercise);

          return Padding(
            padding:
                EdgeInsets.only(bottom: i < entries.length - 1 ? 10 : 0),
            child: GestureDetector(
              onTap: () => onTap(exercise),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(CupertinoIcons.star_fill,
                          color: AppColors.accentGold, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(exercise,
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface)),
                    ),
                    if (isNew)
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.success.withAlpha(80)),
                        ),
                        child: Text('New PR!',
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success)),
                      ),
                    ShaderMask(
                      shaderCallback: (b) =>
                          AppColors.accentGradient.createShader(b),
                      child: Text(value,
                          style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white)),
                    ),
                  ],
                ),
              ),
            )
                .animate(delay: Duration(milliseconds: 80 * i))
                .fadeIn(duration: 400.ms)
                .slideX(begin: 0.1, curve: Curves.easeOut),
          );
        }),
      ],
    );
  }
}

// ============================================================================
//  WORKOUT HISTORY — with tap
// ============================================================================

class _WorkoutHistoryWidget extends StatelessWidget {
  const _WorkoutHistoryWidget({required this.logs, required this.onTap});

  final RxList<WorkoutLogModel> logs;
  final void Function(WorkoutLogModel) onTap;

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final logDate = DateTime(date.year, date.month, date.day);
    final diff = today.difference(logDate).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }

  String _formatDuration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      if (logs.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Workouts',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface)),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
              ),
              child: Column(
                children: [
                  Icon(CupertinoIcons.sportscourt,
                      size: 48,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  const SizedBox(height: 12),
                  Text('No workouts yet',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text('No workouts yet. Start your first workout!',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Workouts',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface)),
          const SizedBox(height: 14),
          ...List.generate(logs.length, (i) {
            final log = logs[i];
            final isLast = i == logs.length - 1;
            final dateStr = _formatRelativeDate(log.date);
            final durationStr = _formatDuration(log.durationSeconds);
            final caloriesStr = '${log.caloriesBurned} kcal';

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 28,
                    child: Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == 0
                                ? AppColors.accentOrange
                                : AppColors.accentOrange.withAlpha(80),
                            boxShadow: i == 0
                                ? [
                                    BoxShadow(
                                        color: AppColors.accentOrange
                                            .withAlpha(60),
                                        blurRadius: 8)
                                  ]
                                : null,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                                width: 2,
                                color: AppColors.accentOrange.withAlpha(30)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                      child: GestureDetector(
                        onTap: () => onTap(log),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(log.workoutName,
                                        style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface)),
                                  ),
                                  Text(dateStr,
                                      style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color:
                                              isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _chip(CupertinoIcons.timer, durationStr, context),
                                  const SizedBox(width: 10),
                                  _chip(
                                      CupertinoIcons.flame_fill, caloriesStr, context),
                                  const SizedBox(width: 10),
                                  _chip(CupertinoIcons.list_bullet,
                                      '${log.exercisesCompleted} ex', context),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate(delay: Duration(milliseconds: 100 * i))
                .fadeIn(duration: 400.ms)
                .slideX(begin: 0.08, curve: Curves.easeOut);
          }),
        ],
      );
    });
  }

  Widget _chip(IconData icon, String text, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        const SizedBox(width: 4),
        Text(text,
            style: GoogleFonts.inter(
                fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
      ],
    );
  }
}

// ============================================================================
//  MOST TRAINED MUSCLES
// ============================================================================

class _MostTrainedMuscles extends StatelessWidget {
  const _MostTrainedMuscles();

  static const _muscles = [
    _MuscleData('Chest', 0.85, Color(0xFFFF6B35)),
    _MuscleData('Back', 0.72, Color(0xFFFFB800)),
    _MuscleData('Legs', 0.68, Color(0xFF00E096)),
    _MuscleData('Shoulders', 0.55, Color(0xFF4DA6FF)),
    _MuscleData('Arms', 0.48, Color(0xFFAA7BF7)),
    _MuscleData('Core', 0.40, Color(0xFFFF4D6A)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Muscle Focus',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
          ),
          child: Column(
            children: _muscles.asMap().entries.map((entry) {
              final i = entry.key;
              final m = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                    bottom: i < _muscles.length - 1 ? 14 : 0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 72,
                      child: Text(m.name,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface)),
                    ),
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: m.fill),
                        duration: Duration(milliseconds: 800 + i * 100),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0x10FFFFFF) : const Color(0x15000000),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: FractionallySizedBox(
                              widthFactor: value,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: m.color,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 36,
                      child: Text('${(m.fill * 100).toInt()}%',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: m.color)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MuscleData {
  const _MuscleData(this.name, this.fill, this.color);
  final String name;
  final double fill;
  final Color color;
}

// ============================================================================
//  PROGRESS PHOTOS — with interactions
// ============================================================================

class _ProgressPhotosWidget extends StatelessWidget {
  const _ProgressPhotosWidget({
    required this.photos,
    required this.onAddPhoto,
    required this.onCompare,
    required this.onPhotoTap,
    required this.onLongPressPhoto,
  });

  final List<_ProgressPhoto> photos;
  final VoidCallback onAddPhoto;
  final VoidCallback onCompare;
  final void Function(_ProgressPhoto) onPhotoTap;
  final void Function(_ProgressPhoto) onLongPressPhoto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Progress Photos',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface)),
            GestureDetector(
              onTap: onAddPhoto,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.camera_fill,
                        size: 14, color: AppColors.white),
                    const SizedBox(width: 6),
                    Text('Add Photo',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Compare button
        GestureDetector(
          onTap: onCompare,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.arrow_right_arrow_left,
                    size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                const SizedBox(width: 8),
                Text('Compare',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (photos.isEmpty) _buildEmptyState(context) else ...[
          _buildPhotoGrid(context),
          const SizedBox(height: 12),
          Center(
            child: Text('Long press a photo to delete',
                style: GoogleFonts.inter(
                    fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardTheme.color,
      ),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.accentOrange.withAlpha(60),
          borderRadius: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withAlpha(18),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.camera,
                  color: AppColors.accentOrange, size: 28),
            ),
            const SizedBox(height: 16),
            Text('Add your first progress photo',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface)),
            const SizedBox(height: 6),
            Text('Track your transformation visually',
                style: GoogleFonts.inter(
                    fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onAddPhoto,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentOrange.withAlpha(40),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.plus,
                        size: 16, color: AppColors.white),
                    const SizedBox(width: 6),
                    Text('Take Photo',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: photos.length,
      itemBuilder: (context, i) {
        final photo = photos[i];
        return GestureDetector(
          onTap: () => onPhotoTap(photo),
          onLongPress: () => onLongPressPhoto(photo),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(photo.file, fit: BoxFit.cover),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withAlpha(180),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(16)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(photo.date,
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: AppColors.white)),
                          Text('${photo.weight} kg',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accentOrange)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
//  DASHED BORDER PAINTER
// ============================================================================

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.borderRadius});

  final Color color;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    final dashPath = _createDashedPath(path, 8, 6);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path source, double dashWidth, double dashSpace) {
    final result = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        result.addPath(metric.extractPath(distance, end), Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.borderRadius != borderRadius;
}

