// FitForge Diet & Nutrition Screen — Premium nutrition tracking UI.
// Cupertino-first design with dark theme, gradient accents, animated rings.

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import 'barcode_scanner_screen.dart';
import 'ai_food_scanner_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  COLORS
// ═══════════════════════════════════════════════════════════════════════════

const Color _kProteinBlue = Color(0xFF4DA8FF);
const Color _kCarbsGreen = Color(0xFF00E096);
const Color _kFatPurple = Color(0xFFB44DFF);
const Color _kWaterBlue = Color(0xFF4DA8FF);

// ═══════════════════════════════════════════════════════════════════════════
//  DATA MODELS
// ═══════════════════════════════════════════════════════════════════════════

class FoodItem {
  final String name;
  final String quantity;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const FoodItem({
    required this.name,
    required this.quantity,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class MealSection {
  final String name;
  final String icon;
  final int goalKcal;
  final RxList<FoodItem> items;
  final RxBool expanded;

  MealSection({
    required this.name,
    required this.icon,
    required this.goalKcal,
    required List<FoodItem> items,
  })  : items = items.obs,
        expanded = true.obs;

  int get totalCalories => items.fold(0, (s, i) => s + i.calories);
  int get totalProtein => items.fold(0, (s, i) => s + i.protein);
  int get totalCarbs => items.fold(0, (s, i) => s + i.carbs);
  int get totalFat => items.fold(0, (s, i) => s + i.fat);
}

// ═══════════════════════════════════════════════════════════════════════════
//  SEARCHABLE FOOD DATABASE
// ═══════════════════════════════════════════════════════════════════════════

const List<FoodItem> _kFoodDatabase = [
  // ── Breakfast ──
  FoodItem(name: 'Idli', quantity: 'per 1 piece', calories: 39, protein: 1, carbs: 8, fat: 0),
  FoodItem(name: 'Dosa (Plain)', quantity: 'per 1 piece', calories: 133, protein: 4, carbs: 18, fat: 5),
  FoodItem(name: 'Masala Dosa', quantity: 'per 1 piece', calories: 210, protein: 5, carbs: 28, fat: 9),
  FoodItem(name: 'Poha', quantity: 'per 1 plate • 150g', calories: 195, protein: 4, carbs: 35, fat: 5),
  FoodItem(name: 'Upma', quantity: 'per 1 bowl • 150g', calories: 190, protein: 5, carbs: 30, fat: 6),
  FoodItem(name: 'Aloo Paratha', quantity: 'per 1 piece', calories: 210, protein: 5, carbs: 30, fat: 8),
  FoodItem(name: 'Bread Toast', quantity: 'per 2 slices', calories: 130, protein: 4, carbs: 24, fat: 2),
  FoodItem(name: 'Oatmeal', quantity: 'per 1 bowl • 150g', calories: 150, protein: 5, carbs: 27, fat: 3),
  FoodItem(name: 'Egg (Boiled)', quantity: 'per 1 large', calories: 78, protein: 6, carbs: 1, fat: 5),
  FoodItem(name: 'Egg Omelette', quantity: 'per 2 eggs', calories: 190, protein: 13, carbs: 2, fat: 14),
  FoodItem(name: 'Banana', quantity: 'per 1 medium', calories: 105, protein: 1, carbs: 27, fat: 0),
  FoodItem(name: 'Milk (Toned)', quantity: 'per 200ml', calories: 120, protein: 6, carbs: 10, fat: 6),
  FoodItem(name: 'Cornflakes with Milk', quantity: 'per 1 bowl', calories: 200, protein: 6, carbs: 38, fat: 3),
  // ── Lunch ──
  FoodItem(name: 'Dal (Masoor)', quantity: 'per 1 bowl • 150g', calories: 174, protein: 14, carbs: 30, fat: 1),
  FoodItem(name: 'Dal Tadka', quantity: 'per 1 bowl • 150g', calories: 195, protein: 12, carbs: 28, fat: 5),
  FoodItem(name: 'Dal Makhani', quantity: 'per 1 bowl • 150g', calories: 230, protein: 10, carbs: 26, fat: 10),
  FoodItem(name: 'Basmati Rice', quantity: 'per 1 cup • 150g', calories: 195, protein: 4, carbs: 42, fat: 0),
  FoodItem(name: 'Brown Rice', quantity: 'per 1 cup • 150g', calories: 168, protein: 4, carbs: 36, fat: 1),
  FoodItem(name: 'Roti (Wheat)', quantity: 'per 1 piece', calories: 120, protein: 4, carbs: 20, fat: 3),
  FoodItem(name: 'Chapati', quantity: 'per 1 piece', calories: 104, protein: 3, carbs: 18, fat: 2),
  FoodItem(name: 'Aloo Sabzi', quantity: 'per 1 bowl • 150g', calories: 140, protein: 3, carbs: 24, fat: 5),
  FoodItem(name: 'Mixed Veg Sabzi', quantity: 'per 1 bowl • 150g', calories: 120, protein: 4, carbs: 16, fat: 5),
  FoodItem(name: 'Paneer Butter Masala', quantity: 'per 1 bowl • 150g', calories: 320, protein: 14, carbs: 10, fat: 26),
  FoodItem(name: 'Paneer Bhurji', quantity: 'per 100g', calories: 265, protein: 18, carbs: 4, fat: 20),
  FoodItem(name: 'Rajma', quantity: 'per 1 bowl • 150g', calories: 190, protein: 13, carbs: 35, fat: 1),
  FoodItem(name: 'Chole', quantity: 'per 1 bowl • 150g', calories: 245, protein: 13, carbs: 40, fat: 4),
  FoodItem(name: 'Chicken Biryani', quantity: 'per 1 plate • 250g', calories: 400, protein: 22, carbs: 50, fat: 14),
  FoodItem(name: 'Veg Biryani', quantity: 'per 1 plate • 250g', calories: 340, protein: 8, carbs: 52, fat: 11),
  FoodItem(name: 'Dahi (Curd)', quantity: 'per 1 bowl • 100g', calories: 60, protein: 3, carbs: 5, fat: 3),
  FoodItem(name: 'Raita', quantity: 'per 1 bowl • 100g', calories: 75, protein: 4, carbs: 6, fat: 4),
  FoodItem(name: 'Green Salad', quantity: 'per 1 bowl • 100g', calories: 25, protein: 1, carbs: 5, fat: 0),
  FoodItem(name: 'Palak Paneer', quantity: 'per 1 bowl • 150g', calories: 255, protein: 15, carbs: 9, fat: 18),
  // ── Dinner ──
  FoodItem(name: 'Grilled Chicken', quantity: 'per 1 serving • 200g', calories: 330, protein: 62, carbs: 0, fat: 8),
  FoodItem(name: 'Chicken Breast', quantity: 'per 100g', calories: 165, protein: 31, carbs: 0, fat: 4),
  FoodItem(name: 'Fish Curry', quantity: 'per 1 bowl • 150g', calories: 220, protein: 24, carbs: 8, fat: 10),
  FoodItem(name: 'Khichdi', quantity: 'per 1 bowl • 200g', calories: 210, protein: 8, carbs: 38, fat: 3),
  FoodItem(name: 'Tomato Soup', quantity: 'per 1 bowl • 200ml', calories: 90, protein: 2, carbs: 16, fat: 2),
  FoodItem(name: 'Veg Soup', quantity: 'per 1 bowl • 200ml', calories: 80, protein: 3, carbs: 14, fat: 1),
  // ── Snacks ──
  FoodItem(name: 'Mixed Nuts', quantity: 'per 30g', calories: 173, protein: 5, carbs: 6, fat: 15),
  FoodItem(name: 'Almonds', quantity: 'per 20 pieces • 25g', calories: 143, protein: 5, carbs: 3, fat: 12),
  FoodItem(name: 'Apple', quantity: 'per 1 medium', calories: 95, protein: 0, carbs: 25, fat: 0),
  FoodItem(name: 'Orange', quantity: 'per 1 medium', calories: 62, protein: 1, carbs: 15, fat: 0),
  FoodItem(name: 'Protein Bar', quantity: 'per 1 bar • 60g', calories: 220, protein: 20, carbs: 22, fat: 7),
  FoodItem(name: 'Chai (Milk Tea)', quantity: 'per 1 cup', calories: 80, protein: 3, carbs: 10, fat: 3),
  FoodItem(name: 'Black Coffee', quantity: 'per 1 cup', calories: 2, protein: 0, carbs: 0, fat: 0),
  FoodItem(name: 'Green Tea', quantity: 'per 1 cup', calories: 2, protein: 0, carbs: 0, fat: 0),
  FoodItem(name: 'Biscuits (Digestive)', quantity: 'per 3 pieces', calories: 150, protein: 2, carbs: 22, fat: 6),
  FoodItem(name: 'Sprouts Salad', quantity: 'per 1 bowl • 100g', calories: 100, protein: 7, carbs: 14, fat: 1),
  FoodItem(name: 'Makhana (Fox Nuts)', quantity: 'per 30g', calories: 110, protein: 3, carbs: 20, fat: 1),
  FoodItem(name: 'Greek Yogurt', quantity: 'per 1 cup • 150g', calories: 145, protein: 14, carbs: 6, fat: 8),
  FoodItem(name: 'Whey Protein', quantity: 'per 1 scoop • 30g', calories: 120, protein: 24, carbs: 3, fat: 1),
  FoodItem(name: 'Peanut Butter Toast', quantity: 'per 1 slice', calories: 190, protein: 7, carbs: 18, fat: 10),
];

// ═══════════════════════════════════════════════════════════════════════════
//  CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

class DietController extends GetxController {
  final selectedDate = DateTime.now().obs;
  final waterGlasses = 6.obs;
  static const int waterGoal = 8;
  static const int calorieGoal = 2200;
  static const int proteinGoal = 160;
  static const int carbsGoal = 220;
  static const int fatGoal = 60;

  late final List<MealSection> meals;

  @override
  void onInit() {
    super.onInit();
    meals = [
      MealSection(
        name: 'Breakfast',
        icon: '🌅',
        goalKcal: 600,
        items: [
          const FoodItem(name: 'Oatmeal with Banana', quantity: '1 cup • 200g', calories: 280, protein: 8, carbs: 48, fat: 6),
          const FoodItem(name: 'Black Coffee', quantity: '1 cup • 240ml', calories: 2, protein: 0, carbs: 0, fat: 0),
        ],
      ),
      MealSection(
        name: 'Lunch',
        icon: '☀️',
        goalKcal: 700,
        items: [
          const FoodItem(name: 'Dal Chawal', quantity: '1 plate • 350g', calories: 420, protein: 16, carbs: 68, fat: 8),
          const FoodItem(name: 'Curd', quantity: '1 bowl • 100g', calories: 60, protein: 3, carbs: 5, fat: 3),
        ],
      ),
      MealSection(
        name: 'Dinner',
        icon: '🌙',
        goalKcal: 650,
        items: [
          const FoodItem(name: 'Grilled Chicken', quantity: '1 serving • 200g', calories: 330, protein: 62, carbs: 0, fat: 8),
        ],
      ),
      MealSection(
        name: 'Snacks',
        icon: '🍎',
        goalKcal: 250,
        items: [
          const FoodItem(name: 'Mixed Nuts', quantity: '1 handful • 30g', calories: 173, protein: 5, carbs: 6, fat: 15),
        ],
      ),
    ];
  }

  int get totalCalories => meals.fold(0, (s, m) => s + m.totalCalories);
  int get totalProtein => meals.fold(0, (s, m) => s + m.totalProtein);
  int get totalCarbs => meals.fold(0, (s, m) => s + m.totalCarbs);
  int get totalFat => meals.fold(0, (s, m) => s + m.totalFat);
  int get remainingCalories => (calorieGoal - totalCalories).clamp(0, calorieGoal);

  String get dateLabel {
    final now = DateTime.now();
    final d = selectedDate.value;
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (d.year == yesterday.year && d.month == yesterday.month && d.day == yesterday.day) {
      return 'Yesterday';
    }
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }

  void previousDay() => selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
  void nextDay() => selectedDate.value = selectedDate.value.add(const Duration(days: 1));

  void toggleWaterGlass(int index) {
    HapticFeedback.lightImpact();
    if (index < waterGlasses.value) {
      waterGlasses.value = index;
    } else {
      waterGlasses.value = index + 1;
    }
  }

  void addWater() {
    if (waterGlasses.value < waterGoal) {
      HapticFeedback.lightImpact();
      waterGlasses.value++;
    }
  }

  void addFoodToMeal(int mealIndex, FoodItem food) {
    HapticFeedback.mediumImpact();
    meals[mealIndex].items.add(food);
  }

  void removeFoodFromMeal(int mealIndex, int foodIndex) {
    HapticFeedback.lightImpact();
    meals[mealIndex].items.removeAt(foodIndex);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  DIET SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  late final DietController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(DietController(), permanent: true);
  }

  // ─── Scanner Options ──────────────────────────────────────────────
  void _showScannerOptions(BuildContext ctx) {
    showModalBottomSheet<void>(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ScannerOptionsSheet(
        onAiScan: () {
          Navigator.pop(ctx);
          _showMealPickerThenNavigate(ctx);
        },
        onBarcode: () {
          Navigator.pop(ctx);
          _openBarcodeScanner(ctx);
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  void _openBarcodeScanner(BuildContext ctx) {
    Navigator.of(ctx).push(
      CupertinoPageRoute<void>(
        builder: (_) => BarcodeScannerScreen(
          onFoodScanned: (food, mealIndex) {
            _ctrl.addFoodToMeal(mealIndex, food);
          },
        ),
      ),
    );
  }

  void _showMealPickerThenNavigate(BuildContext ctx) {
    final mealNames = _ctrl.meals.map((m) => m.name).toList();
    final mealIcons = ['🌅', '☀️', '🌙', '🍎'];
    showCupertinoModalPopup<void>(
      context: ctx,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Add to which meal?'),
        actions: List.generate(mealNames.length, (i) {
          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _openAiFoodScanner(ctx, mealNames[i], i);
            },
            child: Text('${mealIcons[i]}  ${mealNames[i]}'),
          );
        }),
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _openAiFoodScanner(BuildContext ctx, String mealName, int mealIndex) {
    Navigator.of(ctx).push<List<FoodItem>>(
      CupertinoPageRoute(
        builder: (_) => AiFoodScannerScreen(
          mealName: mealName,
          mealIndex: mealIndex,
        ),
      ),
    ).then((items) {
      if (items != null && items.isNotEmpty) {
        for (final food in items) {
          _ctrl.addFoodToMeal(mealIndex, food);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Obx(() {
        // Touch all reactive values so Obx rebuilds
        _ctrl.selectedDate.value;
        _ctrl.waterGlasses.value;
        for (final m in _ctrl.meals) {
          m.items.length;
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  _CalorieHeroCard(ctrl: _ctrl)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 12),
                  _WaterTrackerCard(ctrl: _ctrl)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 100.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 16),
                  ...List.generate(_ctrl.meals.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MealSectionCard(
                        ctrl: _ctrl,
                        mealIndex: i,
                      ).animate()
                          .fadeIn(duration: 500.ms, delay: (200 + i * 80).ms)
                          .slideY(begin: 0.1, end: 0),
                    );
                  }),
                  const SizedBox(height: 8),
                  _DailySummary(ctrl: _ctrl)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 550.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundDark,
      pinned: true,
      expandedHeight: 100,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 12, right: 16),
        title: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nutrition',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  // Date nav row
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _ctrl.previousDay,
                        child: const Icon(CupertinoIcons.chevron_left, size: 12, color: AppColors.textSecondaryDark),
                      ),
                      const SizedBox(width: 4),
                      Obx(() => Text(
                            _ctrl.dateLabel,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondaryDark,
                              decoration: TextDecoration.none,
                            ),
                          )),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: _ctrl.nextDay,
                        child: const Icon(CupertinoIcons.chevron_right, size: 12, color: AppColors.textSecondaryDark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showScannerOptions(context),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(CupertinoIcons.barcode_viewfinder, size: 16, color: AppColors.accentOrange),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _ctrl.addWater,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(CupertinoIcons.drop_fill, size: 16, color: _kWaterBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  CALORIE HERO CARD
// ═══════════════════════════════════════════════════════════════════════════

class _CalorieHeroCard extends StatelessWidget {
  final DietController ctrl;
  const _CalorieHeroCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final consumed = ctrl.totalCalories;
    final remaining = ctrl.remainingCalories;
    final progress = (consumed / DietController.calorieGoal).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.accentOrange, AppColors.accentGold],
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            // Daily goal row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Goal',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondaryDark,
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  '${DietController.calorieGoal} kcal',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentOrange,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 8,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      color: AppColors.backgroundDark,
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => FractionallySizedBox(
                        widthFactor: value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Consumed / remaining
            Text(
              '$consumed consumed  •  $remaining remaining',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondaryDark,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 18),

            // Macro rings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MacroRing(
                  label: 'Protein',
                  current: ctrl.totalProtein,
                  goal: DietController.proteinGoal,
                  color: _kProteinBlue,
                  unit: 'g',
                ),
                _MacroRing(
                  label: 'Carbs',
                  current: ctrl.totalCarbs,
                  goal: DietController.carbsGoal,
                  color: _kCarbsGreen,
                  unit: 'g',
                ),
                _MacroRing(
                  label: 'Fat',
                  current: ctrl.totalFat,
                  goal: DietController.fatGoal,
                  color: _kFatPurple,
                  unit: 'g',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  MACRO RING
// ═══════════════════════════════════════════════════════════════════════════

class _MacroRing extends StatelessWidget {
  final String label;
  final int current;
  final int goal;
  final Color color;
  final String unit;

  const _MacroRing({
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / goal).clamp(0.0, 1.0);
    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => CustomPaint(
              painter: _RingPainter(progress: value, color: color),
              child: child,
            ),
            child: Center(
              child: Text(
                '$current',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryDark,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          '$current$unit / $goal$unit',
          style: GoogleFonts.inter(
            fontSize: 9,
            color: color.withAlpha(180),
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 5.0;

    // Background ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = color.withAlpha(30),
    );

    // Progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ═══════════════════════════════════════════════════════════════════════════
//  WATER TRACKER CARD
// ═══════════════════════════════════════════════════════════════════════════

class _WaterTrackerCard extends StatelessWidget {
  final DietController ctrl;
  const _WaterTrackerCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final filled = ctrl.waterGlasses.value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorderDark),
      ),
      child: Row(
        children: [
          // Water icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kWaterBlue.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(CupertinoIcons.drop_fill, size: 18, color: _kWaterBlue),
          ),
          const SizedBox(width: 12),

          // Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Water Intake',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  '$filled / ${DietController.waterGoal} glasses',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondaryDark,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),

          // Glass icons
          Row(
            children: List.generate(DietController.waterGoal, (i) {
              final isFilled = i < filled;
              return GestureDetector(
                onTap: () => ctrl.toggleWaterGlass(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(left: 3),
                  width: 18,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isFilled ? _kWaterBlue.withAlpha(30) : AppColors.backgroundDark,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isFilled ? _kWaterBlue : AppColors.textSecondaryDark.withAlpha(50),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    CupertinoIcons.drop_fill,
                    size: 10,
                    color: isFilled ? _kWaterBlue : AppColors.textSecondaryDark.withAlpha(60),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 6),

          // Quick add button
          GestureDetector(
            onTap: ctrl.addWater,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _kWaterBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(CupertinoIcons.plus, size: 14, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  MEAL SECTION CARD
// ═══════════════════════════════════════════════════════════════════════════

class _MealSectionCard extends StatelessWidget {
  final DietController ctrl;
  final int mealIndex;

  const _MealSectionCard({required this.ctrl, required this.mealIndex});

  @override
  Widget build(BuildContext context) {
    final meal = ctrl.meals[mealIndex];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorderDark),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => meal.expanded.toggle(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Obx(() => Row(
                    children: [
                      Text(meal.icon, style: const TextStyle(fontSize: 20, decoration: TextDecoration.none)),
                      const SizedBox(width: 10),
                      Text(
                        meal.name,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${meal.totalCalories} / ${meal.goalKcal} kcal',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.accentOrange,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _showAddFoodSheet(context),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(CupertinoIcons.plus, size: 14, color: AppColors.white),
                        ),
                      ),
                    ],
                  )),
            ),
          ),

          // Expandable items
          Obx(() {
            if (!meal.expanded.value || meal.items.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                const Divider(color: AppColors.cardBorderDark, height: 1),
                ...List.generate(meal.items.length, (i) {
                  return _FoodItemTile(
                    item: meal.items[i],
                    onDelete: () => ctrl.removeFoodFromMeal(mealIndex, i),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _showAddFoodSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Material(
        color: Colors.transparent,
        child: _AddFoodBottomSheet(
          mealName: ctrl.meals[mealIndex].name,
          onAdd: (food) => ctrl.addFoodToMeal(mealIndex, food),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  FOOD ITEM TILE (with swipe to delete)
// ═══════════════════════════════════════════════════════════════════════════

class _FoodItemTile extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onDelete;

  const _FoodItemTile({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error.withAlpha(30),
        child: const Icon(CupertinoIcons.delete, color: AppColors.error, size: 20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.quantity,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondaryDark,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            // Macro pills
            _MacroPill('P: ${item.protein}g', _kProteinBlue),
            const SizedBox(width: 4),
            _MacroPill('C: ${item.carbs}g', _kCarbsGreen),
            const SizedBox(width: 4),
            _MacroPill('F: ${item.fat}g', _kFatPurple),
            const SizedBox(width: 10),
            // Calories
            Text(
              '${item.calories}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.accentOrange,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              ' kcal',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.textSecondaryDark,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  final String text;
  final Color color;
  const _MacroPill(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: color,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  ADD FOOD BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════

class _AddFoodBottomSheet extends StatefulWidget {
  final String mealName;
  final ValueChanged<FoodItem> onAdd;

  const _AddFoodBottomSheet({required this.mealName, required this.onAdd});

  @override
  State<_AddFoodBottomSheet> createState() => _AddFoodBottomSheetState();
}

class _AddFoodBottomSheetState extends State<_AddFoodBottomSheet> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<FoodItem> _results = _kFoodDatabase;

  static const List<String> _recentFoods = [
    'Oatmeal', 'Dal', 'Rice', 'Paneer', 'Chicken', 'Roti', 'Egg', 'Curd',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _results = _kFoodDatabase;
      } else {
        _results = _kFoodDatabase
            .where((f) => f.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondaryDark.withAlpha(50),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
            child: Row(
              children: [
                Text(
                  'Add to ${widget.mealName}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                const Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.textSecondaryDark, size: 24),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _onSearch,
              cursorColor: AppColors.accentOrange,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF0A0A0F),
                hintText: 'Search foods...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF8888AA),
                  decoration: TextDecoration.none,
                ),
                prefixIcon: const Icon(CupertinoIcons.search, size: 18, color: Color(0xFF8888AA)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.accentOrange, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0x15FFFFFF), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.accentOrange, width: 2),
                ),
              ),
            ),
          ),

          // Recent foods chips
          if (_searchController.text.isEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _recentFoods.length,
                separatorBuilder: (c, idx) => const SizedBox(width: 8),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () {
                    _searchController.text = _recentFoods[i];
                    _onSearch(_recentFoods[i]);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorderDark),
                    ),
                    child: Text(
                      _recentFoods[i],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondaryDark,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _searchController.text.isEmpty ? 'All Foods' : '${_results.length} results',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryDark,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Results list
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          Icon(CupertinoIcons.search, size: 40, color: AppColors.textSecondaryDark.withAlpha(80)),
                          const SizedBox(height: 12),
                          Text(
                            'No results found',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondaryDark,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try a different search term',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondaryDark.withAlpha(120),
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _results.length,
                    itemBuilder: (_, i) {
                      final food = _results[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorderDark),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      food.name,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.white,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${food.quantity}  •  ${food.calories} kcal',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppColors.textSecondaryDark,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  widget.onAdd(food);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.accentGradient,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(CupertinoIcons.plus, size: 16, color: AppColors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  DAILY SUMMARY
// ═══════════════════════════════════════════════════════════════════════════

class _DailySummary extends StatelessWidget {
  final DietController ctrl;
  const _DailySummary({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Summary",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 12),

        // 2x2 stat grid
        Row(
          children: [
            Expanded(
              child: _SummaryStatCard(
                icon: CupertinoIcons.flame_fill,
                iconColor: AppColors.accentOrange,
                value: '${ctrl.totalCalories}',
                label: 'Calories',
                progress: (ctrl.totalCalories / DietController.calorieGoal).clamp(0.0, 1.0),
                barColor: AppColors.accentOrange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryStatCard(
                icon: CupertinoIcons.bolt_fill,
                iconColor: _kProteinBlue,
                value: '${ctrl.totalProtein}g',
                label: 'Protein',
                progress: (ctrl.totalProtein / DietController.proteinGoal).clamp(0.0, 1.0),
                barColor: _kProteinBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SummaryStatCard(
                icon: CupertinoIcons.leaf_arrow_circlepath,
                iconColor: _kCarbsGreen,
                value: '${ctrl.totalCarbs}g',
                label: 'Net Carbs',
                progress: (ctrl.totalCarbs / DietController.carbsGoal).clamp(0.0, 1.0),
                barColor: _kCarbsGreen,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryStatCard(
                icon: CupertinoIcons.drop_fill,
                iconColor: _kFatPurple,
                value: '${ctrl.totalFat}g',
                label: 'Total Fat',
                progress: (ctrl.totalFat / DietController.fatGoal).clamp(0.0, 1.0),
                barColor: _kFatPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Micronutrients
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorderDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Micronutrients',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 10),
              _MicroRow(label: 'Fiber', value: '18g', goal: '25g', progress: 0.72, color: _kCarbsGreen),
              _MicroRow(label: 'Sugar', value: '32g', goal: '50g', progress: 0.64, color: AppColors.accentGold),
              _MicroRow(label: 'Sodium', value: '1,800mg', goal: '2,300mg', progress: 0.78, color: AppColors.accentOrange),
              _MicroRow(label: 'Cholesterol', value: '210mg', goal: '300mg', progress: 0.70, color: _kFatPurple),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final double progress;
  final Color barColor;

  const _SummaryStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.progress,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondaryDark,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 4,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, val, _) => Stack(
                  children: [
                    Container(width: double.infinity, color: barColor.withAlpha(25)),
                    FractionallySizedBox(
                      widthFactor: val,
                      child: Container(
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
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

class _MicroRow extends StatelessWidget {
  final String label;
  final String value;
  final String goal;
  final double progress;
  final Color color;

  const _MicroRow({
    required this.label,
    required this.value,
    required this.goal,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondaryDark,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                height: 4,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, val, _) => Stack(
                    children: [
                      Container(width: double.infinity, color: color.withAlpha(20)),
                      FractionallySizedBox(
                        widthFactor: val,
                        child: Container(color: color),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$value / $goal',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textSecondaryDark,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  SCANNER OPTIONS BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════

class _ScannerOptionsSheet extends StatelessWidget {
  final VoidCallback onAiScan;
  final VoidCallback onBarcode;
  final VoidCallback onCancel;

  const _ScannerOptionsSheet({
    required this.onAiScan,
    required this.onBarcode,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0x20FFFFFF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E1230), AppColors.cardDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentOrange.withValues(alpha: 0.08),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.accentGradient,
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                ),
                const SizedBox(height: 12),
                Text(
                  'Food Scanner',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose how to track your food',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF8888AA),
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // AI Scan card
          _ScanOptionCard(
            onTap: onAiScan,
            iconGradient: AppColors.accentGradient,
            icon: Icons.camera_enhance_rounded,
            title: 'Scan Food with AI',
            subtitle: 'Point camera at any dish — AI detects nutrition instantly',
            borderColor: const Color(0x30FF6B35),
            chevronColor: AppColors.accentOrange,
          ),
          const SizedBox(height: 12),

          // Barcode card
          _ScanOptionCard(
            onTap: onBarcode,
            iconGradient: const LinearGradient(
              colors: [Color(0xFF4DA8FF), Color(0xFF7B61FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            icon: CupertinoIcons.barcode_viewfinder,
            title: 'Scan Barcode',
            subtitle: 'Scan product barcode for exact nutrition info',
            borderColor: const Color(0x10FFFFFF),
            chevronColor: const Color(0xFF8888AA),
          ),
          const SizedBox(height: 16),

          // Cancel button
          GestureDetector(
            onTap: onCancel,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0F),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOptionCard extends StatefulWidget {
  final VoidCallback onTap;
  final LinearGradient iconGradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color borderColor;
  final Color chevronColor;

  const _ScanOptionCard({
    required this.onTap,
    required this.iconGradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.borderColor,
    required this.chevronColor,
  });

  @override
  State<_ScanOptionCard> createState() => _ScanOptionCardState();
}

class _ScanOptionCardState extends State<_ScanOptionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.borderColor),
          ),
          child: Row(
            children: [
              // Icon square with gradient
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: widget.iconGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),

              // Text block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF8888AA),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Chevron
              Icon(CupertinoIcons.chevron_right, color: widget.chevronColor, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
