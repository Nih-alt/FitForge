import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  // ══════════════════════════════════════════════════════════════════════
  //  DARK THEME
  // ══════════════════════════════════════════════════════════════════════

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accentOrange,
          secondary: AppColors.accentGold,
          surface: AppColors.surfaceDark,
          error: AppColors.error,
          onPrimary: AppColors.white,
          onSecondary: AppColors.black,
          onSurface: AppColors.textPrimaryDark,
          onError: AppColors.white,
        ),

        // ── App Bar ────────────────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.backgroundDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: AppTextStyles.headingMedium(isDark: true),
          iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        ),

        // ── Card ───────────────────────────────────────────────────────
        cardTheme: CardThemeData(
          color: AppColors.cardDark,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: AppColors.cardBorderDark,
              width: 1,
            ),
          ),
          shadowColor: AppColors.black.withAlpha(40),
        ),

        // ── Elevated Button ────────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 56)),
            maximumSize: const WidgetStatePropertyAll(Size(double.infinity, 56)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            elevation: const WidgetStatePropertyAll(0),
            backgroundColor: const WidgetStatePropertyAll(AppColors.transparent),
            foregroundColor: const WidgetStatePropertyAll(AppColors.white),
            textStyle: WidgetStatePropertyAll(AppTextStyles.button()),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ),

        // ── Outlined Button ────────────────────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 56)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            side: const WidgetStatePropertyAll(
              BorderSide(color: AppColors.accentOrange, width: 1.5),
            ),
            foregroundColor: const WidgetStatePropertyAll(AppColors.accentOrange),
            textStyle: WidgetStatePropertyAll(AppTextStyles.button()),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ),

        // ── Text Button ───────────────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: const WidgetStatePropertyAll(AppColors.accentOrange),
            textStyle: WidgetStatePropertyAll(AppTextStyles.button()),
          ),
        ),

        // ── Input Decoration ───────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceDark,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          hintStyle: AppTextStyles.bodyMedium(isDark: true),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.cardBorderDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.cardBorderDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accentOrange, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
        ),

        // ── Bottom Navigation ──────────────────────────────────────────
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.accentOrange,
          unselectedItemColor: AppColors.textSecondaryDark,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        // ── Navigation Bar (Material 3) ────────────────────────────────
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          indicatorColor: AppColors.accentOrange.withAlpha(30),
          surfaceTintColor: AppColors.transparent,
          elevation: 0,
          labelTextStyle: WidgetStatePropertyAll(
            AppTextStyles.labelSmall(isDark: true),
          ),
        ),

        // ── Bottom Sheet ───────────────────────────────────────────────
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),

        // ── Dialog ─────────────────────────────────────────────────────
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 16,
        ),

        // ── Divider ────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.cardBorderDark,
          thickness: 1,
          space: 1,
        ),

        // ── Icon ───────────────────────────────────────────────────────
        iconTheme: const IconThemeData(
          color: AppColors.textPrimaryDark,
          size: 24,
        ),

        // ── Text Theme ─────────────────────────────────────────────────
        textTheme: TextTheme(
          displayLarge: AppTextStyles.displayLarge(isDark: true),
          displayMedium: AppTextStyles.displayMedium(isDark: true),
          headlineMedium: AppTextStyles.headingMedium(isDark: true),
          bodyLarge: AppTextStyles.bodyLarge(isDark: true),
          bodyMedium: AppTextStyles.bodyMedium(isDark: true),
          labelSmall: AppTextStyles.labelSmall(isDark: true),
        ),

        // ── Snack Bar ──────────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.cardDark,
          contentTextStyle: AppTextStyles.bodyMedium(isDark: true),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),

        // ── Chip ───────────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedColor: AppColors.accentOrange.withAlpha(30),
          side: const BorderSide(color: AppColors.cardBorderDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          labelStyle: AppTextStyles.labelSmall(isDark: true),
        ),

        // ── Switch ─────────────────────────────────────────────────────
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.accentOrange;
            return AppColors.textSecondaryDark;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.accentOrange.withAlpha(60);
            }
            return AppColors.surfaceDark;
          }),
        ),
      );

  // ══════════════════════════════════════════════════════════════════════
  //  LIGHT THEME
  // ══════════════════════════════════════════════════════════════════════

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        colorScheme: const ColorScheme.light(
          primary: AppColors.accentOrange,
          secondary: AppColors.accentGold,
          surface: AppColors.surfaceLight,
          error: AppColors.error,
          onPrimary: AppColors.white,
          onSecondary: AppColors.black,
          onSurface: AppColors.textPrimaryLight,
          onError: AppColors.white,
        ),

        // ── App Bar ────────────────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.backgroundLight,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: AppTextStyles.headingMedium(isDark: false),
          iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        ),

        // ── Card ───────────────────────────────────────────────────────
        cardTheme: CardThemeData(
          color: AppColors.cardLight,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: AppColors.cardBorderLight,
              width: 1,
            ),
          ),
          shadowColor: AppColors.black.withAlpha(15),
        ),

        // ── Elevated Button ────────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 56)),
            maximumSize: const WidgetStatePropertyAll(Size(double.infinity, 56)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            elevation: const WidgetStatePropertyAll(0),
            backgroundColor: const WidgetStatePropertyAll(AppColors.transparent),
            foregroundColor: const WidgetStatePropertyAll(AppColors.white),
            textStyle: WidgetStatePropertyAll(AppTextStyles.button()),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ),

        // ── Outlined Button ────────────────────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 56)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            side: const WidgetStatePropertyAll(
              BorderSide(color: AppColors.accentOrange, width: 1.5),
            ),
            foregroundColor: const WidgetStatePropertyAll(AppColors.accentOrange),
            textStyle: WidgetStatePropertyAll(AppTextStyles.button()),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ),

        // ── Text Button ───────────────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: const WidgetStatePropertyAll(AppColors.accentOrange),
            textStyle: WidgetStatePropertyAll(AppTextStyles.button()),
          ),
        ),

        // ── Input Decoration ───────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceLight,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          hintStyle: AppTextStyles.bodyMedium(isDark: false),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.cardBorderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.cardBorderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accentOrange, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
        ),

        // ── Bottom Navigation ──────────────────────────────────────────
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceLight,
          selectedItemColor: AppColors.accentOrange,
          unselectedItemColor: AppColors.textSecondaryLight,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        // ── Navigation Bar (Material 3) ────────────────────────────────
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surfaceLight,
          indicatorColor: AppColors.accentOrange.withAlpha(30),
          surfaceTintColor: AppColors.transparent,
          elevation: 0,
          labelTextStyle: WidgetStatePropertyAll(
            AppTextStyles.labelSmall(isDark: false),
          ),
        ),

        // ── Bottom Sheet ───────────────────────────────────────────────
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),

        // ── Dialog ─────────────────────────────────────────────────────
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surfaceLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
        ),

        // ── Divider ────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.cardBorderLight,
          thickness: 1,
          space: 1,
        ),

        // ── Icon ───────────────────────────────────────────────────────
        iconTheme: const IconThemeData(
          color: AppColors.textPrimaryLight,
          size: 24,
        ),

        // ── Text Theme ─────────────────────────────────────────────────
        textTheme: TextTheme(
          displayLarge: AppTextStyles.displayLarge(isDark: false),
          displayMedium: AppTextStyles.displayMedium(isDark: false),
          headlineMedium: AppTextStyles.headingMedium(isDark: false),
          bodyLarge: AppTextStyles.bodyLarge(isDark: false),
          bodyMedium: AppTextStyles.bodyMedium(isDark: false),
          labelSmall: AppTextStyles.labelSmall(isDark: false),
        ),

        // ── Snack Bar ──────────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.cardLight,
          contentTextStyle: AppTextStyles.bodyMedium(isDark: false),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),

        // ── Chip ───────────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceLight,
          selectedColor: AppColors.accentOrange.withAlpha(30),
          side: const BorderSide(color: AppColors.cardBorderLight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          labelStyle: AppTextStyles.labelSmall(isDark: false),
        ),

        // ── Switch ─────────────────────────────────────────────────────
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.accentOrange;
            return AppColors.textSecondaryLight;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.accentOrange.withAlpha(60);
            }
            return AppColors.cardBorderLight;
          }),
        ),
      );

  // ══════════════════════════════════════════════════════════════════════
  //  GRADIENT ELEVATED BUTTON
  // ══════════════════════════════════════════════════════════════════════
  //
  // Use this widget directly instead of ElevatedButton to get the
  // signature orange-to-gold gradient CTA.
  //
  //   GradientButton(onPressed: () {}, child: Text('Start'))
  //
  // The ElevatedButtonTheme sets backgroundColor to transparent so
  // the gradient Ink decoration shows through.
  // ══════════════════════════════════════════════════════════════════════
}

/// Signature gradient button used throughout FitForge for primary CTAs.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 56,
    this.borderRadius = 12,
    this.gradient = AppColors.accentGradient,
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  final double borderRadius;
  final LinearGradient gradient;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: enabled ? gradient : null,
        color: enabled ? null : AppColors.textSecondaryDark.withAlpha(60),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.accentOrange.withAlpha(40),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        child: child,
      ),
    );
  }
}

/// Glassmorphism-ready card for the dark theme.
/// Provides a frosted-glass look with subtle border and soft shadow.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 16,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.black.withAlpha(40)
                : AppColors.black.withAlpha(8),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
