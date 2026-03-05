import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/theme_controller.dart';
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
  late final Box _box;
  String _name = 'Athlete';
  String _goal = 'Build Muscle';
  int _age = 25;
  double _weight = 75.0;
  double _height = 175.0;
  String? _avatarPath;

  // Notification toggles
  bool _workoutReminders = true;
  bool _progressUpdates = true;
  bool _dietReminders = false;

  // Settings
  String _units = 'Metric';

  @override
  void initState() {
    super.initState();
    _box = Hive.box('user_profile');
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _name = _box.get('name', defaultValue: 'Athlete') as String;
      _goal = _box.get('goal', defaultValue: 'Build Muscle') as String;
      _age = _box.get('age', defaultValue: 25) as int;
      _weight = (_box.get('weight', defaultValue: 75.0) as num).toDouble();
      _height = (_box.get('height', defaultValue: 175.0) as num).toDouble();
      _avatarPath = _box.get('avatar_path') as String?;
      _workoutReminders = _box.get('notif_workout', defaultValue: true) as bool;
      _progressUpdates = _box.get('notif_progress', defaultValue: true) as bool;
      _dietReminders = _box.get('notif_diet', defaultValue: false) as bool;
      _units = _box.get('units', defaultValue: 'Metric') as String;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
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
                      color: AppColors.white,
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
                      'FitForge v1.0.0',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondaryDark.withAlpha(120),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  PROFILE HERO
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildProfileHero() {
    final initials = _name.isNotEmpty ? _name[0].toUpperCase() : 'A';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorderDark),
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
                        color: AppColors.cardDark,
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
              color: AppColors.white,
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
                color: AppColors.cardBorderDark,
              ),
              _HeroStat(
                value: '${_weight.toStringAsFixed(1)} ${_units == 'Metric' ? 'kg' : 'lbs'}',
                label: 'Weight',
              ),
              Container(
                width: 1,
                height: 32,
                color: AppColors.cardBorderDark,
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
                            setState(() => _goal = g);
                            _box.put('goal', g);
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
          trailing: Text(
            '${_box.get('weekly_target', defaultValue: 4)} days',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondaryDark,
            ),
          ),
          onTap: () => _showWeeklyTargetPicker(),
        ),
      ],
    );
  }

  void _showWeeklyTargetPicker() {
    int selected = _box.get('weekly_target', defaultValue: 4) as int;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        height: 280,
        decoration: const BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
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
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Weekly Target',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
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
                      _box.put('weekly_target', selected);
                      setState(() {});
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
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
            onTap: () => tc.setThemeMode(ThemeMode.system),
          ),
          _ThemeOption(
            icon: CupertinoIcons.sun_max_fill,
            label: 'Light Mode',
            selected: mode == ThemeMode.light,
            onTap: () => tc.setThemeMode(ThemeMode.light),
          ),
          _ThemeOption(
            icon: CupertinoIcons.moon_fill,
            label: 'Dark Mode',
            selected: mode == ThemeMode.dark,
            onTap: () => tc.setThemeMode(ThemeMode.dark),
          ),
        ],
      );
    });
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  NOTIFICATIONS CARD
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildNotificationsCard() {
    return _SettingsCard(
      children: [
        _SwitchRow(
          icon: CupertinoIcons.bell_fill,
          iconColor: AppColors.accentOrange,
          label: 'Workout Reminders',
          value: _workoutReminders,
          onChanged: (v) {
            setState(() => _workoutReminders = v);
            _box.put('notif_workout', v);
          },
        ),
        _SwitchRow(
          icon: CupertinoIcons.chart_bar_fill,
          iconColor: AppColors.success,
          label: 'Progress Updates',
          value: _progressUpdates,
          onChanged: (v) {
            setState(() => _progressUpdates = v);
            _box.put('notif_progress', v);
          },
        ),
        _SwitchRow(
          icon: CupertinoIcons.leaf_arrow_circlepath,
          iconColor: AppColors.accentGold,
          label: 'Diet Reminders',
          value: _dietReminders,
          onChanged: (v) {
            setState(() => _dietReminders = v);
            _box.put('notif_diet', v);
          },
        ),
      ],
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
          trailing: Text(
            _units,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondaryDark,
            ),
          ),
          onTap: () {
            showCupertinoModalPopup<void>(
              context: context,
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
                            setState(() => _units = u);
                            _box.put('units', u);
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
          iconColor: AppColors.textSecondaryDark,
          label: 'About FitForge',
          trailing: const Icon(
            CupertinoIcons.chevron_forward,
            size: 16,
            color: AppColors.textSecondaryDark,
          ),
          onTap: () => _showAbout(),
        ),
      ],
    );
  }

  void _showAbout() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: AppColors.textSecondaryDark.withAlpha(60),
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
                'FitForge',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version 1.0.0',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your premium fitness companion.\nForge your best self, one rep at a time.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondaryDark,
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
          trailing: const Icon(
            CupertinoIcons.chevron_forward,
            size: 16,
            color: AppColors.textSecondaryDark,
          ),
          onTap: () {},
        ),
        _SettingsRow(
          icon: CupertinoIcons.doc_text_fill,
          iconColor: const Color(0xFF4DA6FF),
          label: 'Terms of Service',
          trailing: const Icon(
            CupertinoIcons.chevron_forward,
            size: 16,
            color: AppColors.textSecondaryDark,
          ),
          onTap: () {},
        ),
        _SettingsRow(
          icon: CupertinoIcons.shield_fill,
          iconColor: AppColors.success,
          label: 'Data & Storage',
          trailing: const Icon(
            CupertinoIcons.chevron_forward,
            size: 16,
            color: AppColors.textSecondaryDark,
          ),
          onTap: () {},
        ),
      ],
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
                'FitForge Pro',
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
          Container(
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
              await _box.clear();
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
    final nameCtrl = TextEditingController(text: _name);
    final ageCtrl = TextEditingController(text: '$_age');
    final weightCtrl = TextEditingController(text: _weight.toStringAsFixed(1));
    final heightCtrl = TextEditingController(text: _height.toStringAsFixed(0));

    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondaryDark.withAlpha(60),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Edit Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
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

                      _box.put('name', newName.isNotEmpty ? newName : 'Athlete');
                      _box.put('age', newAge);
                      _box.put('weight', newWeight);
                      _box.put('height', newHeight);

                      _loadProfile();
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
      builder: (_) => CupertinoActionSheet(
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
                setState(() => _avatarPath = picked.path);
                _box.put('avatar_path', picked.path);
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
                setState(() => _avatarPath = picked.path);
                _box.put('avatar_path', picked.path);
              }
            },
            child: const Text('Choose from Gallery'),
          ),
          if (_avatarPath != null)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                setState(() => _avatarPath = null);
                _box.delete('avatar_path');
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
        color: AppColors.white,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondaryDark,
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorderDark),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.iconColor = AppColors.textSecondaryDark,
    this.trailing,
    this.onTap,
    this.labelColor,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? labelColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
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
                    color: iconColor.withAlpha(18),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: iconColor, size: 17),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: labelColor ?? AppColors.white,
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
              color: AppColors.cardBorderDark,
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
    this.iconColor = AppColors.textSecondaryDark,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(18),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
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
                color: (selected ? AppColors.accentOrange : AppColors.textSecondaryDark)
                    .withAlpha(18),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                icon,
                color: selected
                    ? AppColors.accentOrange
                    : AppColors.textSecondaryDark,
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
                  color: AppColors.white,
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
    return CupertinoTextField(
      controller: controller,
      placeholder: label,
      keyboardType: keyboardType,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      style: GoogleFonts.inter(
        fontSize: 15,
        color: AppColors.white,
      ),
      placeholderStyle: GoogleFonts.inter(
        fontSize: 15,
        color: AppColors.textSecondaryDark,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorderDark),
      ),
    );
  }
}
