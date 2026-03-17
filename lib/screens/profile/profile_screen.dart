import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/theme_controller.dart';
import '../../controllers/user_controller.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';
import '../onboarding/onboarding_screen.dart';

// ============================================================================
//  PROFILE SCREEN — User profile, settings, and preferences
// ============================================================================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserController _userCtrl = Get.find<UserController>();

  // Convenience getters from reactive state
  String get _name => _userCtrl.user.value?.name ?? 'Athlete';
  String get _goal => _userCtrl.user.value?.goal ?? 'Build Muscle';
  int get _age => _userCtrl.user.value?.age ?? 25;
  double get _weight => _userCtrl.user.value?.weight ?? 75.0;
  double get _height => _userCtrl.user.value?.height ?? 175.0;
  String? get _avatarPath {
    final path = _userCtrl.user.value?.profilePhotoPath;
    return (path != null && path.isNotEmpty) ? path : null;
  }

  // Settings getters
  bool get _workoutReminders => _userCtrl.settings.value.workoutReminderOn;
  bool get _progressUpdates => _userCtrl.settings.value.progressUpdateOn;
  bool get _dietReminders => _userCtrl.settings.value.mealReminderOn;
  bool get _waterReminders => _userCtrl.settings.value.waterReminderOn;
  String get _units => _userCtrl.settings.value.weightUnit == 'kg' ? 'Metric' : 'Imperial';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(() {
        // Touch reactive values so Obx rebuilds on changes
        _userCtrl.user.value;
        _userCtrl.settings.value;

        return Column(
        children: [
          // App bar
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showEditProfile(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Edit',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // ── Profile Hero ──────────────────────────────────────
                  _buildProfileHero()
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.12, curve: Curves.easeOut),

                  const SizedBox(height: 28),

                  // ── Goals ─────────────────────────────────────────────
                  _buildSectionHeader('Goals'),
                  const SizedBox(height: 10),
                  _buildGoalCard()
                      .animate(delay: 100.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.08, curve: Curves.easeOut),

                  const SizedBox(height: 24),

                  // ── Appearance ────────────────────────────────────────
                  _buildSectionHeader('Appearance'),
                  const SizedBox(height: 10),
                  _buildAppearanceCard()
                      .animate(delay: 150.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.08, curve: Curves.easeOut),

                  const SizedBox(height: 24),

                  // ── Notifications ─────────────────────────────────────
                  _buildSectionHeader('Notifications'),
                  const SizedBox(height: 10),
                  _buildNotificationsCard()
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.08, curve: Curves.easeOut),

                  const SizedBox(height: 24),

                  // ── App Settings ──────────────────────────────────────
                  _buildSectionHeader('App Settings'),
                  const SizedBox(height: 10),
                  _buildAppSettingsCard()
                      .animate(delay: 250.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.08, curve: Curves.easeOut),

                  const SizedBox(height: 24),

                  // ── Privacy & Security ────────────────────────────────
                  _buildSectionHeader('Privacy & Security'),
                  const SizedBox(height: 10),
                  _buildPrivacyCard()
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.08, curve: Curves.easeOut),

                  const SizedBox(height: 24),

                  // ── Premium ───────────────────────────────────────────
                  _buildPremiumCard()
                      .animate(delay: 350.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.08, curve: Curves.easeOut),

                  const SizedBox(height: 24),

                  // ── Reset & Logout ────────────────────────────────────
                  _buildDangerZone()
                      .animate(delay: 400.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.08, curve: Curves.easeOut),

                  const SizedBox(height: 40),

                  // App version
                  Center(
                    child: Text(
                      'Elevate v1.0.0',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withAlpha(120),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      );
      }),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  PROFILE HERO
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildProfileHero() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final initials = _name.isNotEmpty ? _name[0].toUpperCase() : 'A';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
      ),
      child: Column(
        children: [
          // Avatar with camera badge
          GestureDetector(
            onTap: _pickAvatar,
            child: Stack(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: _avatarPath == null
                        ? AppColors.accentGradient
                        : null,
                    shape: BoxShape.circle,
                    image: _avatarPath != null
                        ? DecorationImage(
                            image: FileImage(File(_avatarPath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _avatarPath == null
                      ? Center(
                          child: Text(
                            initials,
                            style: GoogleFonts.poppins(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.cardTheme.color ?? AppColors.cardDark,
                        width: 2.5,
                      ),
                    ),
                    child: const Icon(
                      CupertinoIcons.camera_fill,
                      color: AppColors.white,
                      size: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            _name,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withAlpha(18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.accentOrange.withAlpha(80),
              ),
            ),
            child: Text(
              _goal,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.accentOrange,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _HeroStat(value: '$_age', label: 'Age'),
              Container(
                width: 1,
                height: 32,
                color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
              ),
              _HeroStat(
                value: '${_weight.toStringAsFixed(1)} ${_units == 'Metric' ? 'kg' : 'lbs'}',
                label: 'Weight',
              ),
              Container(
                width: 1,
                height: 32,
                color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
              ),
              _HeroStat(
                value: '${_height.toStringAsFixed(0)} ${_units == 'Metric' ? 'cm' : 'in'}',
                label: 'Height',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  GOALS CARD
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildGoalCard() {
    const goals = [
      'Build Muscle',
      'Lose Weight',
      'Stay Fit',
      'Gain Strength',
      'Improve Endurance',
    ];

    return _SettingsCard(
      children: [
        _SettingsRow(
          icon: CupertinoIcons.flag_fill,
          iconColor: AppColors.accentOrange,
          label: 'Fitness Goal',
          trailing: Text(
            _goal,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.accentOrange,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () {
            showCupertinoModalPopup<void>(
              context: context,
              barrierDismissible: true,
              builder: (_) => CupertinoActionSheet(
                title: Text(
                  'Select Fitness Goal',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                actions: goals
                    .map((g) => CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context);
                            _userCtrl.updateUser(goal: g);
                          },
                          child: Text(
                            g,
                            style: GoogleFonts.inter(
                              color: g == _goal
                                  ? AppColors.accentOrange
                                  : CupertinoColors.systemBlue,
                              fontWeight: g == _goal
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ))
                    .toList(),
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () => Navigator.pop(context),
                  isDestructiveAction: true,
                  child: const Text('Cancel'),
                ),
              ),
            );
          },
        ),
        _SettingsRow(
          icon: CupertinoIcons.chart_bar_alt_fill,
          iconColor: AppColors.accentGold,
          label: 'Weekly Workout Target',
          trailing: Builder(builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Text(
              '${_userCtrl.settings.value.weeklyWorkoutGoal} days',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            );
          }),
          onTap: () => _showWeeklyTargetPicker(),
        ),
      ],
    );
  }

  void _showWeeklyTargetPicker() {
    int selected = _userCtrl.settings.value.weeklyWorkoutGoal;
    showCupertinoModalPopup<void>(
      context: context,
      barrierDismissible: true,
      builder:(_) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return Container(
        height: 310,
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withAlpha(60),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Weekly Target',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      'Save',
                      style: GoogleFonts.inter(
                        color: AppColors.accentOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      _userCtrl.updateSettings(weeklyWorkoutGoal: selected);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                magnification: 1.22,
                squeeze: 1.2,
                useMagnifier: true,
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: selected - 1,
                ),
                onSelectedItemChanged: (i) => selected = i + 1,
                children: List.generate(
                  7,
                  (i) => Center(
                    child: Text(
                      '${i + 1} day${i > 0 ? 's' : ''} / week',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  APPEARANCE CARD (THEME TOGGLE)
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildAppearanceCard() {
    final tc = ThemeController.to;

    return Obx(() {
      final mode = tc.themeMode;
      return _SettingsCard(
        children: [
          _ThemeOption(
            icon: CupertinoIcons.device_phone_portrait,
            label: 'System Default',
            selected: mode == ThemeMode.system,
            onTap: () {
              tc.setThemeMode('system');
              _userCtrl.loadSettings();
            },
          ),
          _ThemeOption(
            icon: CupertinoIcons.sun_max_fill,
            label: 'Light Mode',
            selected: mode == ThemeMode.light,
            onTap: () {
              tc.setThemeMode('light');
              _userCtrl.loadSettings();
            },
          ),
          _ThemeOption(
            icon: CupertinoIcons.moon_fill,
            label: 'Dark Mode',
            selected: mode == ThemeMode.dark,
            onTap: () {
              tc.setThemeMode('dark');
              _userCtrl.loadSettings();
            },
          ),
        ],
      );
    });
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  NOTIFICATIONS CARD
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildNotificationsCard() {
    return Obx(() {
      final permitted = NotificationService.to.hasNotificationPermission.value;
      return _SettingsCard(
        children: [
          if (!permitted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Notifications are disabled. Enable them in system settings.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.error,
                ),
              ),
            ),
          _buildWorkoutReminderRow(enabled: permitted),
          _SwitchRow(
            icon: CupertinoIcons.chart_bar_fill,
            iconColor: AppColors.success,
            label: 'Progress Updates',
            value: permitted && _progressUpdates,
            onChanged: permitted
                ? (v) async {
                    await _userCtrl.updateSettings(progressUpdateOn: v);
                    await NotificationService.to
                        .rescheduleAllNotifications(_userCtrl.settings.value);
                  }
                : (_) {},
          ),
          _SwitchRow(
            icon: CupertinoIcons.leaf_arrow_circlepath,
            iconColor: AppColors.accentGold,
            label: 'Diet Reminders',
            value: permitted && _dietReminders,
            onChanged: permitted
                ? (v) async {
                    await _userCtrl.updateSettings(mealReminderOn: v);
                    await NotificationService.to
                        .rescheduleAllNotifications(_userCtrl.settings.value);
                  }
                : (_) {},
          ),
          _SwitchRow(
            icon: CupertinoIcons.drop_fill,
            iconColor: const Color(0xFF4DA6FF),
            label: 'Water Reminders',
            value: permitted && _waterReminders,
            onChanged: permitted
                ? (v) async {
                    await _userCtrl.updateSettings(waterReminderOn: v);
                    await NotificationService.to
                        .rescheduleAllNotifications(_userCtrl.settings.value);
                  }
                : (_) {},
          ),
        ],
      );
    });
  }

  /// Workout Reminders row with inline time display and tap-to-change.
  Widget _buildWorkoutReminderRow({bool enabled = true}) {
    final theme = Theme.of(context);
    final s = _userCtrl.settings.value;
    final h = s.workoutReminderHour;
    final m = s.workoutReminderMinute;
    final isPm = h >= 12;
    final displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final timeStr =
        '$displayH:${m.toString().padLeft(2, '0')} ${isPm ? 'PM' : 'AM'}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withAlpha(18),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              CupertinoIcons.bell_fill,
              color: AppColors.accentOrange,
              size: 17,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Workout Reminders',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (enabled && _workoutReminders) ...[
            GestureDetector(
              onTap: _showWorkoutTimePicker,
              child: Text(
                timeStr,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentOrange,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          CupertinoSwitch(
            value: enabled && _workoutReminders,
            onChanged: enabled
                ? (v) async {
                    await _userCtrl.updateSettings(workoutReminderOn: v);
                    await NotificationService.to
                        .rescheduleAllNotifications(_userCtrl.settings.value);
                  }
                : (_) {},
            activeTrackColor: AppColors.accentOrange,
          ),
        ],
      ),
    );
  }

  /// Time picker bottom sheet for the workout reminder.
  void _showWorkoutTimePicker() {
    final s = _userCtrl.settings.value;
    int tempHour   = s.workoutReminderHour;
    int tempMinute = s.workoutReminderMinute;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      builder: (_) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return Container(
          height: 320,
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight)
                        .withAlpha(60),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    Text(
                      'Workout Time',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        Navigator.pop(context);
                        await _userCtrl.updateSettings(
                          workoutReminderHour: tempHour,
                          workoutReminderMinute: tempMinute,
                        );
                        await NotificationService.to
                            .rescheduleAllNotifications(
                                _userCtrl.settings.value);
                      },
                      child: Text(
                        'Save',
                        style: GoogleFonts.inter(
                          color: AppColors.accentOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime:
                      DateTime(2000, 1, 1, tempHour, tempMinute),
                  onDateTimeChanged: (dt) {
                    tempHour   = dt.hour;
                    tempMinute = dt.minute;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  APP SETTINGS CARD
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildAppSettingsCard() {
    return _SettingsCard(
      children: [
        _SettingsRow(
          icon: CupertinoIcons.compass,
          iconColor: const Color(0xFF4DA6FF),
          label: 'Units',
          trailing: Builder(builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Text(
              _units,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            );
          }),
          onTap: () {
            showCupertinoModalPopup<void>(
              context: context,
              barrierDismissible: true,
              builder: (_) => CupertinoActionSheet(
                title: Text(
                  'Select Unit System',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                actions: ['Metric', 'Imperial']
                    .map((u) => CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context);
                            _userCtrl.updateSettings(
                              weightUnit: u == 'Metric' ? 'kg' : 'lbs',
                              heightUnit: u == 'Metric' ? 'cm' : 'ft',
                            );
                          },
                          child: Text(
                            u,
                            style: GoogleFonts.inter(
                              color: u == _units
                                  ? AppColors.accentOrange
                                  : CupertinoColors.systemBlue,
                              fontWeight: u == _units
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ))
                    .toList(),
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () => Navigator.pop(context),
                  isDestructiveAction: true,
                  child: const Text('Cancel'),
                ),
              ),
            );
          },
        ),
        _SettingsRow(
          icon: CupertinoIcons.info_circle_fill,
          label: 'About Elevate',
          onTap: () => _showAbout(),
        ),
      ],
    );
  }

  void _showAbout() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    showCupertinoModalPopup<void>(
      context: context,
      barrierDismissible: true,
      builder:(_) => Container(
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
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withAlpha(60),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  CupertinoIcons.flame_fill,
                  color: AppColors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Elevate',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version 1.0.0',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your AI-powered fitness companion.\nElevate your fitness, one rep at a time.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  PRIVACY & SECURITY CARD
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildPrivacyCard() {
    return _SettingsCard(
      children: [
        _SettingsRow(
          icon: CupertinoIcons.lock_fill,
          iconColor: const Color(0xFFAA7BF7),
          label: 'Privacy Policy',
          trailing: Builder(builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Icon(
            CupertinoIcons.chevron_forward,
            size: 16,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          );
          }),
          onTap: _showPrivacyPolicy,
        ),
        _SettingsRow(
          icon: CupertinoIcons.doc_text_fill,
          iconColor: const Color(0xFF4DA6FF),
          label: 'Terms of Service',
          trailing: Builder(builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Icon(
            CupertinoIcons.chevron_forward,
            size: 16,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          );
          }),
          onTap: _showTermsOfService,
        ),
        _SettingsRow(
          icon: CupertinoIcons.shield_fill,
          iconColor: AppColors.success,
          label: 'Data & Storage',
          trailing: Builder(builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Icon(
            CupertinoIcons.chevron_forward,
            size: 16,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          );
          }),
          onTap: _showDataAndStorage,
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  PRIVACY POLICY SHEET
  // ════════════════════════════════════════════════════════════════════════════

  void _showPrivacyPolicy() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => _LegalSheet(
          title: 'Privacy Policy',
          scrollController: scrollController,
          paragraphs: const [
            'Data Collection\n\nElevate collects information you provide directly, such as your name, age, weight, height, fitness goals, and workout logs. We also collect usage data, device information, and performance metrics to improve the app experience. All data collection is transparent and limited to what is necessary to provide our services.',
            'How We Use Your Data\n\nYour data is used solely to power Elevate features — personalised workout recommendations, progress tracking, AI coaching, and dietary guidance. We do not sell, rent, or share your personal information with third-party advertisers. Aggregated, anonymised data may be used for product improvement and research.',
            'Data Storage & Security\n\nYour data is stored locally on your device and, where applicable, in encrypted cloud storage. We apply industry-standard security measures including AES-256 encryption at rest and TLS 1.3 in transit. You can delete your account and all associated data at any time from the app settings.',
            'Your Rights\n\nYou have the right to access, correct, export, or delete any personal data we hold about you. To exercise these rights, use the Data & Storage section in this screen or contact us at privacy@elevateai.fitness. We will respond to all requests within 30 days in accordance with applicable data protection laws.',
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  TERMS OF SERVICE SHEET
  // ════════════════════════════════════════════════════════════════════════════

  void _showTermsOfService() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => _LegalSheet(
          title: 'Terms of Service',
          scrollController: scrollController,
          paragraphs: const [
            'Acceptance of Terms\n\nBy downloading or using Elevate, you agree to be bound by these Terms of Service. If you do not agree with any part of these terms, you may not use the app. We reserve the right to update these terms at any time; continued use of the app constitutes acceptance of the revised terms.',
            'Usage Rules\n\nElevate is intended for personal, non-commercial use only. You agree not to reverse-engineer, modify, distribute, or exploit any part of the app. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
            'Limitations & Disclaimers\n\nElevate provides general fitness and nutrition guidance for informational purposes only. It is not a substitute for professional medical advice, diagnosis, or treatment. Always consult a qualified healthcare provider before starting any new exercise or diet programme. Results may vary and are not guaranteed.',
            'Liability\n\nTo the maximum extent permitted by law, Elevate and its creators shall not be liable for any indirect, incidental, or consequential damages arising from your use of the app. Our total liability for any claim related to the app shall not exceed the amount you paid for Elevate Pro in the 12 months preceding the claim.',
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  DATA & STORAGE SHEET
  // ════════════════════════════════════════════════════════════════════════════

  void _showDataAndStorage() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => _DataStorageSheet(
          parentContext: context,
          scrollController: scrollController,
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  PREMIUM UPSELL CARD
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildPremiumCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              const Icon(
                CupertinoIcons.star_fill,
                color: AppColors.white,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Elevate Pro',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock AI coaching, advanced analytics,\ncustom plans & ad-free experience.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.white.withAlpha(210),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showProComingSoonDialog(),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Upgrade Now',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentOrange,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProComingSoonDialog() {
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Coming Soon! 🚀'),
        content: const Text(
          "Elevate Pro is currently in development. We'll notify you as soon as it's available!",
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it!',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [AppColors.accentOrange, AppColors.accentGold],
                  ).createShader(const Rect.fromLTWH(0, 0, 80, 20)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  DANGER ZONE — Reset & Logout
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildDangerZone() {
    return _SettingsCard(
      children: [
        _SettingsRow(
          icon: CupertinoIcons.arrow_counterclockwise,
          iconColor: AppColors.accentGold,
          label: 'Reset App Data',
          onTap: () => _showResetConfirmation(),
        ),
        _SettingsRow(
          icon: CupertinoIcons.square_arrow_right,
          iconColor: AppColors.error,
          label: 'Log Out',
          labelColor: AppColors.error,
          onTap: () => _showLogoutConfirmation(),
          showDivider: false,
        ),
      ],
    );
  }

  void _showResetConfirmation() {
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Reset App Data'),
        content: const Text(
          'This will clear all your data including workouts, progress, and settings. This action cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _userCtrl.clearAllData();
                final legacyBox = Hive.box('user_profile');
                await legacyBox.clear();
              } catch (_) {}
              if (!mounted) return;
              Get.offAll(() => OnboardingScreen());
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              Get.offAll(() => OnboardingScreen());
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  EDIT PROFILE SHEET
  // ════════════════════════════════════════════════════════════════════════════

  void _showEditProfile() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final nameCtrl = TextEditingController(text: _name);
    final ageCtrl = TextEditingController(text: '$_age');
    final weightCtrl = TextEditingController(text: _weight.toStringAsFixed(1));
    final heightCtrl = TextEditingController(text: _height.toStringAsFixed(0));

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 12, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withAlpha(60),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Edit Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _SheetField(label: 'Name', controller: nameCtrl),
                  const SizedBox(height: 14),
                  _SheetField(
                    label: 'Age',
                    controller: ageCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  _SheetField(
                    label: 'Weight (${_units == 'Metric' ? 'kg' : 'lbs'})',
                    controller: weightCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 14),
                  _SheetField(
                    label: 'Height (${_units == 'Metric' ? 'cm' : 'in'})',
                    controller: heightCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  GestureDetector(
                    onTap: () {
                      final newName = nameCtrl.text.trim();
                      final newAge =
                          int.tryParse(ageCtrl.text.trim()) ?? _age;
                      final newWeight =
                          double.tryParse(weightCtrl.text.trim()) ?? _weight;
                      final newHeight =
                          double.tryParse(heightCtrl.text.trim()) ?? _height;

                      _userCtrl.updateUser(
                        name: newName.isNotEmpty ? newName : 'Athlete',
                        age: newAge,
                        weight: newWeight,
                        height: newHeight,
                      );
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentOrange.withAlpha(40),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Save Changes',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
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

  // ════════════════════════════════════════════════════════════════════════════
  //  AVATAR PICKER
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> _pickAvatar() async {
    showCupertinoModalPopup<void>(
      context: context,
      barrierDismissible: true,
      builder:(_) => CupertinoActionSheet(
        title: Text(
          'Profile Photo',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              final picked = await ImagePicker()
                  .pickImage(source: ImageSource.camera, maxWidth: 512);
              if (picked != null) {
                _userCtrl.updateUser(profilePhotoPath: picked.path);
              }
            },
            child: const Text('Take Photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              final picked = await ImagePicker()
                  .pickImage(source: ImageSource.gallery, maxWidth: 512);
              if (picked != null) {
                _userCtrl.updateUser(profilePhotoPath: picked.path);
              }
            },
            child: const Text('Choose from Gallery'),
          ),
          if (_avatarPath != null)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                _userCtrl.updateUser(profilePhotoPath: '');
              },
              child: const Text('Remove Photo'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  SECTION HEADER
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
//  REUSABLE WIDGETS
// ════════════════════════════════════════════════════════════════════════════════

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.iconColor,
    this.trailing,
    this.onTap,
    this.labelColor,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? labelColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveIconColor = iconColor ?? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: effectiveIconColor.withAlpha(18),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: effectiveIconColor, size: 17),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: labelColor ?? theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 64),
            child: Container(
              height: 0.5,
              color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
            ),
          ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveIconColor = iconColor ?? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: effectiveIconColor.withAlpha(18),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: effectiveIconColor, size: 17),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.accentOrange,
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inactiveColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: (selected ? AppColors.accentOrange : inactiveColor)
                    .withAlpha(18),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                icon,
                color: selected
                    ? AppColors.accentOrange
                    : inactiveColor,
                size: 17,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (selected)
              const Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: AppColors.accentOrange,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CupertinoTextField(
      controller: controller,
      placeholder: label,
      keyboardType: keyboardType,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      style: GoogleFonts.inter(
        fontSize: 15,
        color: theme.colorScheme.onSurface,
      ),
      placeholderStyle: GoogleFonts.inter(
        fontSize: 15,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
//  LEGAL SHEET (Privacy Policy / Terms of Service)
// ════════════════════════════════════════════════════════════════════════════════

class _LegalSheet extends StatelessWidget {
  const _LegalSheet({
    required this.title,
    required this.paragraphs,
    this.scrollController,
  });

  final String title;
  final List<String> paragraphs;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withAlpha(60),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),

            // Header row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
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
            ),

            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: paragraphs
                      .map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            p,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                              height: 1.6,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
//  DATA & STORAGE SHEET
// ════════════════════════════════════════════════════════════════════════════════

class _DataStorageSheet extends StatelessWidget {
  const _DataStorageSheet({required this.parentContext, this.scrollController});

  final BuildContext parentContext;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withAlpha(60),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Header row
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Data & Storage',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
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
                ),

                // Storage stats card
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
                  ),
                  child: Column(
                    children: [
                      _StorageRow(
                        icon: CupertinoIcons.app_fill,
                        label: 'App Data',
                        size: '2.4 MB',
                        sizeColor: AppColors.accentOrange,
                        showDivider: true,
                      ),
                      _StorageRow(
                        icon: CupertinoIcons.clear_circled_solid,
                        label: 'Cache',
                        size: '0.8 MB',
                        sizeColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        showDivider: true,
                      ),
                      _StorageRow(
                        icon: CupertinoIcons.photo_fill,
                        label: 'Progress Photos',
                        size: '12.6 MB',
                        sizeColor: AppColors.accentOrange,
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Total
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Total Storage Used: 15.8 MB',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Clear Cache button
                GestureDetector(
                  onTap: () => _confirmClearCache(context),
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accentOrange),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Clear Cache',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Export My Data button
                GestureDetector(
                  onTap: () => _confirmExport(context),
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Export My Data',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentOrange,
                      ),
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

  void _confirmClearCache(BuildContext context) {
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Clear Cache?'),
        content: const Text('App data will not be affected.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close sheet
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(
                  content: Text(
                    'Cache cleared successfully',
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  backgroundColor: Theme.of(parentContext).cardTheme.color,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _confirmExport(BuildContext context) {
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Export My Data'),
        content: const Text(
            'Export feature coming soon in next update!'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _StorageRow extends StatelessWidget {
  const _StorageRow({
    required this.icon,
    required this.label,
    required this.size,
    required this.sizeColor,
    required this.showDivider,
  });

  final IconData icon;
  final String label;
  final String size;
  final Color sizeColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                size,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: sizeColor,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Container(height: 0.5, color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
          ),
      ],
    );
  }
}
