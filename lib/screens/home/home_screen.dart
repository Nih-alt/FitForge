import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/user_controller.dart';
import '../../theme/app_colors.dart';
import '../diet/diet_screen.dart';
import '../profile/profile_screen.dart';
import '../progress/progress_screen.dart';
import '../workout/workout_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
//  HOME SCREEN — Main dashboard with bottom navigation
// ════════════════════════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentTab,
        children: const [
          _HomeDashboard(),
          WorkoutScreen(),
          DietScreen(),
          ProgressScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: CupertinoTabBar(
          currentIndex: _currentTab,
          onTap: (i) => setState(() => _currentTab = i),
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          activeColor: AppColors.accentOrange,
          inactiveColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          iconSize: 24,
          height: 56,
          border: const Border(),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.house_fill),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.flame_fill),
              label: 'Workout',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.leaf_arrow_circlepath),
              label: 'Diet',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chart_bar_fill),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person_fill),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  HOME DASHBOARD — Main scrollable content
// ════════════════════════════════════════════════════════════════════════════

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard();

  @override
  Widget build(BuildContext context) {
    final userCtrl = Get.find<UserController>();

    return Obx(() {
    final name = userCtrl.user.value?.name ?? 'Athlete';
    final firstName = name.split(' ').first;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── App Bar ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: _AppBarRow(name: firstName),
            ),
          ),
        ),

        // ── Body ─────────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 20),

              // Daily Score Ring
              const _DailyScoreCard(score: 72, calories: 486, steps: 8249, activeMin: 42)
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.15, curve: Curves.easeOut),

              const SizedBox(height: 20),

              // Today's Workout
              const _TodaysWorkoutCard()
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.15, curve: Curves.easeOut),

              const SizedBox(height: 20),

              // Quick Stats
              const _QuickStatsRow()
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.15, curve: Curves.easeOut),

              const SizedBox(height: 24),

              // Weekly Progress
              const _WeeklyProgress()
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.15, curve: Curves.easeOut),

              const SizedBox(height: 24),

              // Motivational Banner
              const _MotivationalBanner()
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.15, curve: Curves.easeOut),

              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
    });
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  APP BAR ROW — Greeting + avatar
// ════════════════════════════════════════════════════════════════════════════

class _AppBarRow extends StatelessWidget {
  const _AppBarRow({required this.name});

  final String name;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get _todayFormatted {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'A';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting, $name 👋',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _todayFormatted,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),

        // Notification bell
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
          ),
          child: Icon(
            CupertinoIcons.bell,
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
        ),

        const SizedBox(width: 10),

        // Profile avatar
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              initials,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  DAILY SCORE CARD — Animated ring + stats
// ════════════════════════════════════════════════════════════════════════════

class _DailyScoreCard extends StatelessWidget {
  const _DailyScoreCard({
    required this.score,
    required this.calories,
    required this.steps,
    required this.activeMin,
  });

  final int score;
  final int calories;
  final int steps;
  final int activeMin;

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
        boxShadow: [
          BoxShadow(
            color: AppColors.accentOrange.withAlpha(15),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Ring ───────────────────────────────────────────────────────
          SizedBox(
            width: 180,
            height: 180,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: score / 100),
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return CustomPaint(
                  painter: _RingPainter(progress: value, isDark: isDark),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          (value * 100).toInt().toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Daily Score',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // ── Mini stats row ─────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MiniStat(
                icon: CupertinoIcons.flame_fill,
                value: '$calories',
                label: 'kcal',
                color: AppColors.accentOrange,
              ),
              Container(width: 1, height: 36, color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
              _MiniStat(
                icon: CupertinoIcons.arrow_right_arrow_left,
                value: _formatSteps(steps),
                label: 'steps',
                color: AppColors.accentGold,
              ),
              Container(width: 1, height: 36, color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
              _MiniStat(
                icon: CupertinoIcons.timer,
                value: '$activeMin',
                label: 'min',
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatSteps(int steps) {
    if (steps >= 1000) return '${(steps / 1000).toStringAsFixed(1)}k';
    return '$steps';
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

// ── Ring Painter ────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.isDark});

  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 10;
    const strokeWidth = 12.0;

    // Track
    final trackPaint = Paint()
      ..color = isDark ? const Color(0x10FFFFFF) : const Color(0x15000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: const [AppColors.accentOrange, AppColors.accentGold],
      );
      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
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
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isDark != isDark;
}

// ════════════════════════════════════════════════════════════════════════════
//  TODAY'S WORKOUT CARD
// ════════════════════════════════════════════════════════════════════════════

class _TodaysWorkoutCard extends StatelessWidget {
  const _TodaysWorkoutCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Workout",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
          ),
          child: Row(
            children: [
              // Left content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upper Body Blast',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '6 exercises  •  35 min',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Difficulty badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.accentOrange.withAlpha(120),
                        ),
                        color: AppColors.accentOrange.withAlpha(18),
                      ),
                      child: Text(
                        'Intermediate',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.accentOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Play button
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentOrange.withAlpha(50),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.play_fill,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  QUICK STATS ROW — Water, Sleep, BMI
// ════════════════════════════════════════════════════════════════════════════

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickStatCard(
            icon: CupertinoIcons.drop_fill,
            value: '2.4L',
            label: 'Water',
            accentColor: const Color(0xFF4DA6FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickStatCard(
            icon: CupertinoIcons.moon_fill,
            value: '7.5h',
            label: 'Sleep',
            accentColor: const Color(0xFFAA7BF7),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickStatCard(
            icon: CupertinoIcons.heart_fill,
            value: '22.1',
            label: 'BMI',
            accentColor: AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accentColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  WEEKLY PROGRESS — 7-day bar chart
// ════════════════════════════════════════════════════════════════════════════

class _WeeklyProgress extends StatelessWidget {
  const _WeeklyProgress();

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _dayValues = [0.6, 0.85, 0.45, 0.9, 0.7, 0.3, 0.0];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final today = DateTime.now().weekday - 1; // 0 = Monday

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Week',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final isToday = i == today;
              return _DayPill(
                label: _dayLabels[i],
                fill: _dayValues[i],
                isToday: isToday,
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.label,
    required this.fill,
    required this.isToday,
  });

  final String label;
  final double fill;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Activity bar
        Container(
          width: 30,
          height: 56,
          decoration: BoxDecoration(
            color: isDark ? const Color(0x10FFFFFF) : const Color(0x15000000),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fill),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Container(
                  width: 30,
                  height: 56 * value,
                  decoration: BoxDecoration(
                    gradient: isToday ? AppColors.accentGradientVertical : null,
                    color: isToday ? null : AppColors.accentOrange.withAlpha(80),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Day label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: isToday ? AppColors.accentGradient : null,
            color: isToday ? null : AppColors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
              color: isToday
                  ? AppColors.white
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  MOTIVATIONAL BANNER
// ════════════════════════════════════════════════════════════════════════════

class _MotivationalBanner extends StatelessWidget {
  const _MotivationalBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentOrange.withAlpha(40),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Every rep brings you closer.',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Keep forging ahead.',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.white.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }
}
