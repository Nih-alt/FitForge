import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'onboarding_controller.dart';

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({super.key});

  final controller = Get.put(OnboardingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(controller: controller),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => controller.currentPage.value = i,
                children: [
                  _WelcomePage(),
                  _PersonalInfoPage(controller: controller),
                  _BodyStatsPage(controller: controller),
                  _GoalPage(controller: controller),
                ],
              ),
            ),
            _BottomButton(controller: controller),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  TOP BAR — Progress indicator + Skip
// ════════════════════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SmoothPageIndicator(
            controller: controller.pageController,
            count: OnboardingController.totalPages,
            effect: ExpandingDotsEffect(
              activeDotColor: AppColors.accentOrange,
              dotColor: Theme.of(context).cardTheme.color ?? AppColors.cardDark,
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 3,
              spacing: 6,
            ),
          ),
          Obx(() {
            if (controller.currentPage.value == 0) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return GestureDetector(
                onTap: controller.skipToLast,
                child: Text(
                  'Skip',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              );
            }
            return const SizedBox(width: 40);
          }),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  BOTTOM BUTTON — Continue / Let's Forge!
// ════════════════════════════════════════════════════════════════════════════

class _BottomButton extends StatelessWidget {
  const _BottomButton({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Obx(() {
        final isLast =
            controller.currentPage.value == OnboardingController.totalPages - 1;
        return GradientButton(
          onPressed: controller.nextPage,
          child: Text(
            isLast ? "Let's Forge!" : 'Continue',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  PAGE 1 — Welcome
// ════════════════════════════════════════════════════════════════════════════

class _WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // ── Animated icon ────────────────────────────────────────────
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentOrange.withAlpha(30),
                      AppColors.transparent,
                    ],
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1.15, 1.15),
                    duration: 2500.ms,
                    curve: Curves.easeInOut,
                  ),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentOrange.withAlpha(75),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  size: 52,
                  color: AppColors.white,
                ),
              )
                  .animate()
                  .fadeIn(duration: 700.ms)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    curve: Curves.elasticOut,
                    duration: 1000.ms,
                  ),
            ],
          ),

          const SizedBox(height: 48),

          Text(
            'Welcome to\nFitForge',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          )
              .animate(delay: 300.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.3, curve: Curves.easeOut),

          const SizedBox(height: 16),

          Text(
            'Your personal fitness companion.\nBuilt to push limits and break barriers.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              height: 1.6,
            ),
          )
              .animate(delay: 500.ms)
              .fadeIn(duration: 600.ms),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  PAGE 2 — Personal Info
// ════════════════════════════════════════════════════════════════════════════

class _PersonalInfoPage extends StatelessWidget {
  const _PersonalInfoPage({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            "What's your\nname?",
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.2,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideX(begin: -0.1, curve: Curves.easeOut),

          const SizedBox(height: 8),
          Text(
            "Let's personalize your experience",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 40),

          // ── Name Field ───────────────────────────────────────────────
          _OnboardingTextField(
            controller: controller.nameController,
            hint: 'Your name',
            icon: Icons.person_outline_rounded,
            textCapitalization: TextCapitalization.words,
          ).animate(delay: 300.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),

          const SizedBox(height: 20),

          // ── Date of Birth Picker ─────────────────────────────────────
          _DobPickerField(controller: controller)
              .animate(delay: 450.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.2),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  PAGE 3 — Body Stats
// ════════════════════════════════════════════════════════════════════════════

class _BodyStatsPage extends StatelessWidget {
  const _BodyStatsPage({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(28, 0, 28, keyboardHeight + 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Your body\nstats',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.2,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideX(begin: -0.1, curve: Curves.easeOut),

          const SizedBox(height: 8),
          Text(
            "We'll use this to tailor your plan",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 48),

          // ── Weight Stepper ───────────────────────────────────────────
          Obx(() => _StatStepper(
                label: 'Weight',
                value: controller.weight.value,
                unit: 'kg',
                onDecrement: controller.decrementWeight,
                onIncrement: controller.incrementWeight,
                onManualInput: controller.setWeightManual,
                allowDecimal: true,
                minValue: 20,
                maxValue: 300,
              ))
              .animate(delay: 300.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.15),

          const SizedBox(height: 28),

          // ── Height Stepper ───────────────────────────────────────────
          Obx(() => _StatStepper(
                label: 'Height',
                value: controller.height.value,
                unit: 'cm',
                onDecrement: controller.decrementHeight,
                onIncrement: controller.incrementHeight,
                onManualInput: controller.setHeightManual,
                minValue: 50,
                maxValue: 250,
              ))
              .animate(delay: 450.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.15),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  PAGE 4 — Goal Selection
// ════════════════════════════════════════════════════════════════════════════

class _GoalPage extends StatelessWidget {
  const _GoalPage({required this.controller});

  final OnboardingController controller;

  static const _goals = [
    _GoalOption('Weight Loss', Icons.trending_down_rounded),
    _GoalOption('Muscle Gain', Icons.fitness_center_rounded),
    _GoalOption('Stay Fit', Icons.self_improvement_rounded),
    _GoalOption('Improve Stamina', Icons.directions_run_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            "What's your\ngoal?",
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.2,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideX(begin: -0.1, curve: Curves.easeOut),

          const SizedBox(height: 8),
          Text(
            "Choose what drives you",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 36),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.05,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(_goals.length, (i) {
                final goal = _goals[i];
                return Obx(() => _GoalCard(
                      label: goal.label,
                      icon: goal.icon,
                      isSelected: controller.selectedGoal.value == goal.label,
                      onTap: () => controller.selectGoal(goal.label),
                    ))
                    .animate(delay: (300 + i * 100).ms)
                    .fadeIn(duration: 500.ms)
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      curve: Curves.easeOutBack,
                    );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SHARED COMPONENTS
// ════════════════════════════════════════════════════════════════════════════

/// Dark-themed input field for the onboarding flow.
class _OnboardingTextField extends StatelessWidget {
  const _OnboardingTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight;

    return TextField(
      controller: controller,
      textCapitalization: textCapitalization,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: theme.colorScheme.onSurface,
      ),
      cursorColor: AppColors.accentOrange,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 16,
          color: textSecondary,
        ),
        prefixIcon: Icon(icon, color: textSecondary, size: 22),
        filled: true,
        fillColor: theme.cardTheme.color,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.accentOrange, width: 1.5),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
//  Date of Birth Picker Field — Cupertino scroll-wheel bottom sheet
// ────────────────────────────────────────────────────────────────────────────

class _DobPickerField extends StatelessWidget {
  const _DobPickerField({required this.controller});

  final OnboardingController controller;

  void _showPicker(BuildContext context) {
    DateTime tempDate = controller.selectedDob.value ?? DateTime(2000, 1, 1);
    final now = DateTime.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withAlpha(38),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date of Birth',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          controller.selectedDob.value = tempDate;
                          Navigator.of(ctx).pop();
                        },
                        child: Text(
                          'Done',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(color: (isDark ? Colors.white : Colors.black).withAlpha(21), height: 1),

                SizedBox(
                  height: 250,
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      brightness: isDark ? Brightness.dark : Brightness.light,
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 21,
                        ),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      dateOrder: DatePickerDateOrder.dmy,
                      initialDateTime: tempDate,
                      maximumDate: now,
                      minimumDate: DateTime(now.year - 100),
                      backgroundColor: theme.cardTheme.color ?? (isDark ? AppColors.cardDark : AppColors.cardLight),
                      onDateTimeChanged: (date) {
                        tempDate = date;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final dob = controller.selectedDob.value;
      final age = controller.calculatedAge;
      final hasValue = dob != null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              _showPicker(context);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasValue
                      ? AppColors.accentOrange
                      : (isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
                  width: hasValue ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hasValue
                          ? '${dob.day.toString().padLeft(2, '0')} / ${dob.month.toString().padLeft(2, '0')} / ${dob.year}'
                          : 'DD / MM / YYYY',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: hasValue
                            ? theme.colorScheme.onSurface
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.accentOrange,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (age != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'You are $age years old',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accentOrange,
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}

// ────────────────────────────────────────────────────────────────────────────
//  Stat Stepper — +/- buttons with tappable center for manual input
// ────────────────────────────────────────────────────────────────────────────

class _StatStepper extends StatefulWidget {
  const _StatStepper({
    required this.label,
    required this.value,
    required this.unit,
    required this.onDecrement,
    required this.onIncrement,
    required this.onManualInput,
    this.allowDecimal = false,
    this.minValue = 0,
    this.maxValue = 999,
  });

  final String label;
  final double value;
  final String unit;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool Function(String) onManualInput;
  final bool allowDecimal;
  final double minValue;
  final double maxValue;

  @override
  State<_StatStepper> createState() => _StatStepperState();
}

class _StatStepperState extends State<_StatStepper> {
  bool _isEditing = false;
  String? _errorText;
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      _submitValue();
    }
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _errorText = null;
      _textController.text = widget.allowDecimal
          ? widget.value.toStringAsFixed(1)
          : widget.value.toInt().toString();
      _textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _textController.text.length,
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isEditing) {
        _focusNode.requestFocus();
      }
    });
  }

  /// Exits edit mode without submitting the typed value.
  /// Used when +/- is pressed during editing.
  void _cancelEditing() {
    // Set _isEditing = false BEFORE unfocus so the _onFocusChange
    // listener sees it as false and skips _submitValue().
    setState(() {
      _isEditing = false;
    });
    _focusNode.unfocus();
  }

  void _submitValue() {
    if (!_isEditing) return;
    final text = _textController.text.trim();
    final valid = widget.onManualInput(text);
    setState(() {
      _isEditing = false;
      if (!valid) {
        _errorText =
            'Enter ${widget.minValue.toInt()}–${widget.maxValue.toInt()} ${widget.unit}';
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _errorText = null);
        });
      } else {
        _errorText = null;
      }
    });
  }

  String get _displayValue => widget.allowDecimal
      ? widget.value.toStringAsFixed(1)
      : widget.value.toInt().toString();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
          ),
          child: Column(
            children: [
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StepperButton(
                    icon: Icons.remove_rounded,
                    onTap: () {
                      if (_isEditing) _cancelEditing();
                      widget.onDecrement();
                    },
                  ),
                  const SizedBox(width: 24),

                  // ── Tappable center value ────────────────────────────
                  GestureDetector(
                    onTap: _isEditing ? null : _startEditing,
                    child: SizedBox(
                      width: 140,
                      child: _isEditing ? _buildEditField() : _buildDisplay(),
                    ),
                  ),

                  const SizedBox(width: 24),
                  _StepperButton(
                    icon: Icons.add_rounded,
                    onTap: () {
                      if (_isEditing) _cancelEditing();
                      widget.onIncrement();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Error text ─────────────────────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: _errorText != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _errorText!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accentOrange,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          _displayValue,
          style: GoogleFonts.poppins(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          widget.unit,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.accentOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildEditField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            keyboardType: TextInputType.numberWithOptions(
              decimal: widget.allowDecimal,
            ),
            inputFormatters: [
              if (widget.allowDecimal)
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
              else
                FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(5),
            ],
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            cursorColor: AppColors.accentOrange,
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onSubmitted: (_) => _submitValue(),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          widget.unit,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.accentOrange,
          ),
        ),
      ],
    );
  }
}

/// Circular +/- button used by [_StatStepper].
class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.cardTheme.color,
          border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
        ),
        child: Icon(icon, color: AppColors.accentOrange, size: 24),
      ),
    );
  }
}

/// Glassmorphism goal card.
class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.accentOrange
                : borderColor,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accentOrange.withAlpha(35),
                    blurRadius: 24,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.accentOrange.withAlpha(25)
                    : theme.cardTheme.color,
              ),
              child: Icon(
                icon,
                size: 26,
                color: isSelected
                    ? AppColors.accentOrange
                    : textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color:
                    isSelected ? theme.colorScheme.onSurface : textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data class for goal options.
class _GoalOption {
  const _GoalOption(this.label, this.icon);
  final String label;
  final IconData icon;
}
