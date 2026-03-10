// FitForge Barcode Scanner — Scans product barcodes and shows nutrition info.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../theme/app_colors.dart';
import 'diet_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  COLORS (redefined — originals are private to diet_screen)
// ═══════════════════════════════════════════════════════════════════════════

const Color _kProteinBlue = Color(0xFF4DA8FF);
const Color _kCarbsGreen = Color(0xFF00E096);
const Color _kFatPurple = Color(0xFFB44DFF);

// ═══════════════════════════════════════════════════════════════════════════
//  BARCODE SCANNER SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class BarcodeScannerScreen extends StatefulWidget {
  final void Function(FoodItem food, int mealIndex) onFoodScanned;

  const BarcodeScannerScreen({super.key, required this.onFoodScanned});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    final code = barcode.rawValue!;
    _showProductSheet(code);
  }

  void _showProductSheet(String barcode) {
    // Mock product data — in production this would call an API like Open Food Facts
    final product = _MockProduct(
      name: 'Organic Granola Bar',
      brand: 'Nature Valley',
      barcode: barcode,
      calories: 190,
      protein: 4,
      carbs: 29,
      fat: 7,
      quantity: '1 bar • 42g',
    );

    showCupertinoModalPopup<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _ProductResultSheet(
        product: product,
        onMealSelected: (mealIndex) {
          final food = FoodItem(
            name: '${product.brand} ${product.name}',
            quantity: product.quantity,
            calories: product.calories,
            protein: product.protein,
            carbs: product.carbs,
            fat: product.fat,
          );
          widget.onFoodScanned(food, mealIndex);
          Navigator.of(context)
            ..pop() // close sheet
            ..pop(); // close scanner
        },
      ),
    ).then((_) {
      // Allow rescanning if sheet dismissed without selection
      if (mounted) setState(() => _isProcessing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera feed
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Scan overlay
          const _ScanOverlay(),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(CupertinoIcons.back, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Scan Barcode',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  SCAN OVERLAY
// ═══════════════════════════════════════════════════════════════════════════

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark overlay with cutout
        CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _ScanOverlayPainter(),
        ),
        // Hint text
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.25,
          left: 0,
          right: 0,
          child: Text(
            'Point camera at barcode',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cutoutWidth = size.width * 0.72;
    final cutoutHeight = cutoutWidth * 0.55;
    final cutoutRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.42),
        width: cutoutWidth,
        height: cutoutHeight,
      ),
      const Radius.circular(16),
    );

    // Semi-transparent fill
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(cutoutRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, bgPaint);

    // Orange border around cutout
    final borderPaint = Paint()
      ..color = AppColors.accentOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(cutoutRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════════════
//  PRODUCT RESULT SHEET
// ═══════════════════════════════════════════════════════════════════════════

class _MockProduct {
  final String name;
  final String brand;
  final String barcode;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String quantity;

  const _MockProduct({
    required this.name,
    required this.brand,
    required this.barcode,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.quantity,
  });
}

class _ProductResultSheet extends StatelessWidget {
  final _MockProduct product;
  final void Function(int mealIndex) onMealSelected;

  const _ProductResultSheet({
    required this.product,
    required this.onMealSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withAlpha(38),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            product.name,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${product.brand}  •  ${product.barcode}',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MacroPill(label: '${product.calories} kcal', color: AppColors.accentOrange),
              const SizedBox(width: 8),
              _MacroPill(label: '${product.protein}g P', color: _kProteinBlue),
              const SizedBox(width: 8),
              _MacroPill(label: '${product.carbs}g C', color: _kCarbsGreen),
              const SizedBox(width: 8),
              _MacroPill(label: '${product.fat}g F', color: _kFatPurple),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'Add to meal',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),

          _MealRow(icon: '🌅', label: 'Breakfast', onTap: () => onMealSelected(0)),
          _MealRow(icon: '☀️', label: 'Lunch', onTap: () => onMealSelected(1)),
          _MealRow(icon: '🌙', label: 'Dinner', onTap: () => onMealSelected(2)),
          _MealRow(icon: '🍎', label: 'Snacks', onTap: () => onMealSelected(3)),
        ],
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  final String label;
  final Color color;

  const _MacroPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _MealRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
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
            const Icon(CupertinoIcons.add_circled, color: AppColors.accentOrange, size: 22),
          ],
        ),
      ),
    );
  }
}
