import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Backgrounds ──────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0A0A0F);
  static const Color backgroundLight = Color(0xFFF5F5FA);

  // ── Surfaces ─────────────────────────────────────────────────────────
  static const Color surfaceDark = Color(0xFF12121A);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // ── Cards ────────────────────────────────────────────────────────────
  static const Color cardDark = Color(0xFF1A1A27);
  static const Color cardLight = Color(0xFFF0F0F8);

  // ── Accents ──────────────────────────────────────────────────────────
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentGold = Color(0xFFFFB800);

  // ── Semantic ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF00E096);
  static const Color error = Color(0xFFFF4D6A);

  // ── Text ─────────────────────────────────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0A0A0F);
  static const Color textSecondaryDark = Color(0xFF8888AA);
  static const Color textSecondaryLight = Color(0xFF666680);

  // ── Utility ──────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // ── Gradients ────────────────────────────────────────────────────────
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentOrange, accentGold],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient accentGradientVertical = LinearGradient(
    colors: [accentOrange, accentGold],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Card Borders ─────────────────────────────────────────────────────
  static const Color cardBorderDark = Color(0x0FFFFFFF); // rgba(255,255,255,0.06)
  static const Color cardBorderLight = Color(0x0A000000); // rgba(0,0,0,0.04)
}
