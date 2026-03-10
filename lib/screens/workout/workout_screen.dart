import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import 'workout_detail_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
//  DATA MODEL
// ════════════════════════════════════════════════════════════════════════════

class WorkoutData {
  const WorkoutData({
    required this.name,
    required this.exercises,
    required this.minutes,
    required this.calories,
    required this.difficulty,
    required this.category,
  });

  final String name;
  final int exercises;
  final int minutes;
  final int calories;
  final String difficulty;
  final String category;

  Color get categoryColor {
    switch (category) {
      case 'Strength':
        return AppColors.accentOrange;
      case 'Cardio':
        return const Color(0xFF4DA6FF);
      case 'Flexibility':
        return const Color(0xFFAA7BF7);
      case 'HIIT':
        return const Color(0xFFFF4D6A);
      case 'Recovery':
        return AppColors.success;
      default:
        return AppColors.accentOrange;
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case 'Strength':
        return CupertinoIcons.flame_fill;
      case 'Cardio':
        return CupertinoIcons.heart_fill;
      case 'Flexibility':
        return CupertinoIcons.person_2_fill;
      case 'HIIT':
        return CupertinoIcons.bolt_fill;
      case 'Recovery':
        return CupertinoIcons.leaf_arrow_circlepath;
      default:
        return CupertinoIcons.flame_fill;
    }
  }

  Color get difficultyColor {
    switch (difficulty) {
      case 'Beginner':
        return AppColors.success;
      case 'Intermediate':
        return AppColors.accentGold;
      case 'Advanced':
        return const Color(0xFFFF4D6A);
      default:
        return AppColors.textSecondaryDark;
    }
  }
}

// ── Workout catalogue ────────────────────────────────────────────────────

const List<WorkoutData> allWorkouts = [
  WorkoutData(
    name: 'Upper Body Blast',
    exercises: 6,
    minutes: 35,
    calories: 280,
    difficulty: 'Intermediate',
    category: 'Strength',
  ),
  WorkoutData(
    name: 'Morning Cardio Rush',
    exercises: 8,
    minutes: 25,
    calories: 320,
    difficulty: 'Beginner',
    category: 'Cardio',
  ),
  WorkoutData(
    name: 'Core & Abs Shred',
    exercises: 7,
    minutes: 30,
    calories: 260,
    difficulty: 'Intermediate',
    category: 'Strength',
  ),
  WorkoutData(
    name: 'Full Body HIIT',
    exercises: 10,
    minutes: 40,
    calories: 400,
    difficulty: 'Advanced',
    category: 'HIIT',
  ),
  WorkoutData(
    name: 'Flexibility Flow',
    exercises: 8,
    minutes: 20,
    calories: 150,
    difficulty: 'Beginner',
    category: 'Flexibility',
  ),
  WorkoutData(
    name: 'Active Recovery',
    exercises: 6,
    minutes: 25,
    calories: 120,
    difficulty: 'Beginner',
    category: 'Recovery',
  ),
];

const WorkoutData featuredWorkout = WorkoutData(
  name: 'Full Body Burn',
  exercises: 6,
  minutes: 45,
  calories: 320,
  difficulty: 'Advanced',
  category: 'HIIT',
);

const List<String> workoutCategories = [
  'All',
  'Strength',
  'Cardio',
  'Flexibility',
  'HIIT',
  'Recovery',
];

// ════════════════════════════════════════════════════════════════════════════
//  GETX CONTROLLER — Reactive filter state
// ════════════════════════════════════════════════════════════════════════════

class _WorkoutBrowseController extends GetxController {
  final selectedCategory = 'All'.obs;

  // Advanced filter state (applied via bottom sheet)
  final appliedDurations = <String>{}.obs;
  final appliedDifficulties = <String>{}.obs;
  final appliedCalories = <String>{}.obs;

  List<WorkoutData> get filteredWorkouts {
    var workouts = allWorkouts.toList();

    // Category filter
    if (selectedCategory.value != 'All') {
      workouts =
          workouts.where((w) => w.category == selectedCategory.value).toList();
    }

    // Duration filter
    if (appliedDurations.isNotEmpty) {
      workouts = workouts.where((w) {
        for (final d in appliedDurations) {
          if (d == '< 20 min' && w.minutes < 20) return true;
          if (d == '20-30 min' && w.minutes >= 20 && w.minutes <= 30) {
            return true;
          }
          if (d == '30-45 min' && w.minutes > 30 && w.minutes <= 45) {
            return true;
          }
          if (d == '45+ min' && w.minutes > 45) return true;
        }
        return false;
      }).toList();
    }

    // Difficulty filter
    if (appliedDifficulties.isNotEmpty) {
      workouts = workouts
          .where((w) => appliedDifficulties.contains(w.difficulty))
          .toList();
    }

    // Calorie filter
    if (appliedCalories.isNotEmpty) {
      workouts = workouts.where((w) {
        for (final c in appliedCalories) {
          if (c == '< 200 kcal' && w.calories < 200) return true;
          if (c == '200-300 kcal' && w.calories >= 200 && w.calories <= 300) {
            return true;
          }
          if (c == '300+ kcal' && w.calories > 300) return true;
        }
        return false;
      }).toList();
    }

    return workouts;
  }

  void selectCategory(String category) => selectedCategory.value = category;

  void applyFilters(
    Set<String> durations,
    Set<String> difficulties,
    Set<String> calories,
  ) {
    appliedDurations.assignAll(durations);
    appliedDifficulties.assignAll(difficulties);
    appliedCalories.assignAll(calories);
  }

  void resetFilters() {
    appliedDurations.clear();
    appliedDifficulties.clear();
    appliedCalories.clear();
  }

  bool get hasActiveFilters =>
      appliedDurations.isNotEmpty ||
      appliedDifficulties.isNotEmpty ||
      appliedCalories.isNotEmpty;
}

// ════════════════════════════════════════════════════════════════════════════
//  WORKOUT SCREEN — Browse & filter workouts (Nike Training Club style)
// ════════════════════════════════════════════════════════════════════════════

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(_WorkoutBrowseController());

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(() {
        final filtered = c.filteredWorkouts;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── SliverAppBar ──────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 100,
              pinned: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              surfaceTintColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              scrolledUnderElevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workouts',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Choose your battle',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      IconButton(
                        onPressed: () => _showFilterSheet(context, c),
                        icon: const Icon(
                          CupertinoIcons.slider_horizontal_3,
                          color: AppColors.accentOrange,
                          size: 22,
                        ),
                      ),
                      if (c.hasActiveFilters)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accentGold,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Category Filter ───────────────────────────────────────
            SliverToBoxAdapter(
              child: _CategoryFilterRow(
                selected: c.selectedCategory.value,
                onSelected: c.selectCategory,
              ),
            ),

            // ── Featured Banner ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _FeaturedWorkoutBanner(
                  onStartNow: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => const WorkoutDetailScreen(
                          workout: featuredWorkout,
                        ),
                      ),
                    );
                  },
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.12, curve: Curves.easeOut),
              ),
            ),

            // ── Section Title ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                child: Text(
                  'All Workouts',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),

            // ── Workout List ──────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                key: ValueKey(
                  '${c.selectedCategory.value}_'
                  '${c.appliedDurations.join()}_'
                  '${c.appliedDifficulties.join()}_'
                  '${c.appliedCalories.join()}',
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, index) {
                    final workout = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _WorkoutCard(
                        workout: workout,
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (_) => WorkoutDetailScreen(
                                workout: workout,
                              ),
                            ),
                          );
                        },
                      )
                          .animate()
                          .fadeIn(
                            duration: 400.ms,
                            delay: Duration(milliseconds: 100 * index),
                          )
                          .slideX(
                            begin: 0.08,
                            curve: Curves.easeOut,
                            delay: Duration(milliseconds: 100 * index),
                          ),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),

            // ── Bottom Spacer ─────────────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  FILTER BOTTOM SHEET — Premium CupertinoModalPopup
// ════════════════════════════════════════════════════════════════════════════

void _showFilterSheet(BuildContext context, _WorkoutBrowseController c) {
  showCupertinoModalPopup(
    context: context,
    barrierDismissible: true,
    builder: (_) => _FilterBottomSheet(controller: c),
  );
}

class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet({required this.controller});
  final _WorkoutBrowseController controller;

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  static const _durationOptions = ['< 20 min', '20-30 min', '30-45 min', '45+ min'];
  static const _difficultyOptions = ['Beginner', 'Intermediate', 'Advanced'];
  static const _calorieOptions = ['< 200 kcal', '200-300 kcal', '300+ kcal'];

  late final Set<String> _durations;
  late final Set<String> _difficulties;
  late final Set<String> _calories;

  @override
  void initState() {
    super.initState();
    _durations = {...widget.controller.appliedDurations};
    _difficulties = {...widget.controller.appliedDifficulties};
    _calories = {...widget.controller.appliedCalories};
  }

  void _toggle(Set<String> set, String value) {
    setState(() {
      if (set.contains(value)) {
        set.remove(value);
      } else {
        set.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.72,
      ),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Drag handle ──────────────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withAlpha(80),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Header ───────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Workouts',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        CupertinoIcons.xmark,
                        color: AppColors.accentOrange,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Duration ─────────────────────────────────────────────
              _filterSectionLabel('Duration'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _durationOptions
                    .map((o) => _FilterPill(
                          label: o,
                          isSelected: _durations.contains(o),
                          onTap: () => _toggle(_durations, o),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 22),

              // ── Difficulty ───────────────────────────────────────────
              _filterSectionLabel('Difficulty'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _difficultyOptions
                    .map((o) => _FilterPill(
                          label: o,
                          isSelected: _difficulties.contains(o),
                          onTap: () => _toggle(_difficulties, o),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 22),

              // ── Calories ─────────────────────────────────────────────
              _filterSectionLabel('Calories Burned'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _calorieOptions
                    .map((o) => _FilterPill(
                          label: o,
                          isSelected: _calories.contains(o),
                          onTap: () => _toggle(_calories, o),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 28),

              // ── Bottom buttons ───────────────────────────────────────
              Row(
                children: [
                  // Reset
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        widget.controller.resetFilters();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accentOrange),
                        ),
                        child: Center(
                          child: Text(
                            'Reset',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Apply Filters
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        widget.controller.applyFilters(
                          _durations,
                          _difficulties,
                          _calories,
                        );
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppColors.accentGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentOrange.withAlpha(60),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Apply Filters',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

// ── Filter pill — selectable chip with gradient highlight ─────────────────

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.accentGradient : null,
          color: isSelected ? null : theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  CATEGORY FILTER ROW — Horizontal scrolling pills
// ════════════════════════════════════════════════════════════════════════════

class _CategoryFilterRow extends StatelessWidget {
  const _CategoryFilterRow({
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: workoutCategories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final cat = workoutCategories[index];
            final isSelected = cat == selected;
            return _CategoryPill(
              label: cat,
              isSelected: isSelected,
              onTap: () => onSelected(cat),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.accentGradient : null,
          color: isSelected ? null : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? AppColors.white
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  FEATURED WORKOUT BANNER — Large hero card
// ════════════════════════════════════════════════════════════════════════════

class _FeaturedWorkoutBanner extends StatelessWidget {
  const _FeaturedWorkoutBanner({required this.onStartNow});

  final VoidCallback onStartNow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardTheme.color,
        border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentOrange.withAlpha(20),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Subtle orange glow at edges ──────────────────────────────
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentOrange.withAlpha(25),
                    AppColors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
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
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top: Featured badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'FEATURED',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                // Middle: Title
                Text(
                  'Full Body Burn',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),

                // Bottom row: Tags + Start button
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '45 min  •  Advanced  •  320 kcal',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    _StartNowButton(onTap: onStartNow),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Start Now button with scale-down press animation ─────────────────────

class _StartNowButton extends StatefulWidget {
  const _StartNowButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_StartNowButton> createState() => _StartNowButtonState();
}

class _StartNowButtonState extends State<_StartNowButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentOrange.withAlpha(60),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            'Start Now',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  WORKOUT CARD — Individual workout list item
// ════════════════════════════════════════════════════════════════════════════

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.workout, required this.onTap});

  final WorkoutData workout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.accentOrange.withAlpha(20),
        highlightColor: AppColors.accentOrange.withAlpha(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
          ),
          child: Row(
            children: [
              // ── Category icon box ─────────────────────────────────────
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: workout.categoryColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  workout.categoryIcon,
                  color: workout.categoryColor,
                  size: 22,
                ),
              ),

              const SizedBox(width: 14),

              // ── Info ──────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${workout.exercises} exercises  •  '
                      '${workout.minutes} min  •  '
                      '${workout.calories} kcal',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // ── Difficulty badge ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: workout.difficultyColor.withAlpha(100),
                  ),
                  color: workout.difficultyColor.withAlpha(18),
                ),
                child: Text(
                  workout.difficulty,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: workout.difficultyColor,
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // ── Chevron ───────────────────────────────────────────────
              Icon(
                CupertinoIcons.chevron_right,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
