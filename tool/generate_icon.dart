// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Generates FitForge app icons matching the onboarding orange gradient circle
/// with dumbbell. Run via: flutter test tool/generate_icon.dart
void main() {
  test('generate app icons', () async {
    // ── Full icon (gradient background) ─────────────────────────────────
    final icon = await _renderIcon(withBackground: true);
    File('assets/icon/app_icon.png').writeAsBytesSync(icon);
    print('✓ assets/icon/app_icon.png');

    // ── Foreground only (transparent bg for adaptive icon) ──────────────
    final fg = await _renderIcon(withBackground: false);
    File('assets/icon/app_icon_fg.png').writeAsBytesSync(fg);
    print('✓ assets/icon/app_icon_fg.png');
  });
}

Future<List<int>> _renderIcon({required bool withBackground}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const size = Size(1024, 1024);
  final rect = Rect.fromLTWH(0, 0, size.width, size.height);

  if (withBackground) {
    // Full-bleed radial gradient: warm gold center → orange edges
    // Matches onboarding's RadialGradient with accentOrange/accentGold
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.3),
        radius: 0.9,
        colors: [Color(0xFFFFB800), Color(0xFFFF6B35)],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Subtle inner glow for depth
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.6,
        colors: [Colors.white.withAlpha(38), Colors.transparent],
      ).createShader(rect);
    canvas.drawRect(rect, glowPaint);
  }

  // ── Draw dumbbell (centered, matching onboarding fitness_center icon) ──
  final p = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  // Left plate
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(180, 420, 130, 184),
      const Radius.circular(28),
    ),
    p,
  );

  // Left collar
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(308, 452, 60, 120),
      const Radius.circular(14),
    ),
    p,
  );

  // Bar
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(366, 472, 292, 80),
      const Radius.circular(40),
    ),
    p,
  );

  // Right collar
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(656, 452, 60, 120),
      const Radius.circular(14),
    ),
    p,
  );

  // Right plate
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(714, 420, 130, 184),
      const Radius.circular(28),
    ),
    p,
  );

  // ── Encode to PNG ──────────────────────────────────────────────────────
  final picture = recorder.endRecording();
  final img = await picture.toImage(1024, 1024);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
