import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  // ── Display ──────────────────────────────────────────────────────────

  static TextStyle displayLarge({bool isDark = true}) => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        height: 1.25,
        letterSpacing: -0.5,
        decoration: TextDecoration.none,
      );

  static TextStyle displayMedium({bool isDark = true}) => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        height: 1.33,
        letterSpacing: -0.3,
        decoration: TextDecoration.none,
      );

  // ── Heading ──────────────────────────────────────────────────────────

  static TextStyle headingMedium({bool isDark = true}) => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        height: 1.4,
        decoration: TextDecoration.none,
      );

  // ── Body ─────────────────────────────────────────────────────────────

  static TextStyle bodyLarge({bool isDark = true}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        height: 1.5,
        decoration: TextDecoration.none,
      );

  static TextStyle bodyMedium({bool isDark = true}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        height: 1.57,
        decoration: TextDecoration.none,
      );

  // ── Label ────────────────────────────────────────────────────────────

  static TextStyle labelSmall({bool isDark = true}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        height: 1.33,
        letterSpacing: 0.2,
        decoration: TextDecoration.none,
      );

  // ── Button ───────────────────────────────────────────────────────────

  static TextStyle button() => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        height: 1.25,
        letterSpacing: 0.3,
        decoration: TextDecoration.none,
      );
}
