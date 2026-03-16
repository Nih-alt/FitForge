import 'package:flutter_test/flutter_test.dart';
import 'package:elevate_ai_fitness/models/diet_log_model.dart';

void main() {
  group('DietLogModel', () {
    test('creates with valid data', () {
      final log = DietLogModel(
        id: 'diet_001',
        date: DateTime(2026, 3, 16),
        mealType: 'Breakfast',
        foodName: 'Oatmeal with Berries',
        calories: 350,
        protein: 12.0,
        carbs: 55.0,
        fat: 8.0,
        quantity: '1 bowl',
      );

      expect(log.id, 'diet_001');
      expect(log.mealType, 'Breakfast');
      expect(log.foodName, 'Oatmeal with Berries');
      expect(log.calories, 350);
      expect(log.protein, 12.0);
      expect(log.carbs, 55.0);
      expect(log.fat, 8.0);
      expect(log.quantity, '1 bowl');
    });

    test('calorie sum across multiple logs', () {
      final logs = [
        DietLogModel(
          id: '1',
          date: DateTime(2026, 3, 16),
          mealType: 'Breakfast',
          foodName: 'Eggs',
          calories: 200,
          protein: 14.0,
          carbs: 2.0,
          fat: 15.0,
          quantity: '2 eggs',
        ),
        DietLogModel(
          id: '2',
          date: DateTime(2026, 3, 16),
          mealType: 'Lunch',
          foodName: 'Chicken Rice',
          calories: 550,
          protein: 35.0,
          carbs: 60.0,
          fat: 12.0,
          quantity: '1 plate',
        ),
        DietLogModel(
          id: '3',
          date: DateTime(2026, 3, 16),
          mealType: 'Dinner',
          foodName: 'Salmon Salad',
          calories: 400,
          protein: 30.0,
          carbs: 15.0,
          fat: 22.0,
          quantity: '1 bowl',
        ),
      ];

      final totalCalories = logs.fold<int>(0, (sum, l) => sum + l.calories);
      expect(totalCalories, 1150);
    });

    test('macro totals calculation', () {
      final logs = [
        DietLogModel(
          id: '1',
          date: DateTime(2026, 3, 16),
          mealType: 'Breakfast',
          foodName: 'Yogurt',
          calories: 150,
          protein: 10.0,
          carbs: 20.0,
          fat: 3.0,
          quantity: '1 cup',
        ),
        DietLogModel(
          id: '2',
          date: DateTime(2026, 3, 16),
          mealType: 'Lunch',
          foodName: 'Pasta',
          calories: 600,
          protein: 20.0,
          carbs: 80.0,
          fat: 18.0,
          quantity: '1 plate',
        ),
      ];

      final totalProtein = logs.fold<double>(0, (s, l) => s + l.protein);
      final totalCarbs = logs.fold<double>(0, (s, l) => s + l.carbs);
      final totalFat = logs.fold<double>(0, (s, l) => s + l.fat);

      expect(totalProtein, 30.0);
      expect(totalCarbs, 100.0);
      expect(totalFat, 21.0);
    });

    test('filters by meal type', () {
      final logs = [
        DietLogModel(id: '1', date: DateTime(2026, 3, 16), mealType: 'Breakfast', foodName: 'Toast', calories: 200, protein: 5.0, carbs: 30.0, fat: 5.0, quantity: '2 slices'),
        DietLogModel(id: '2', date: DateTime(2026, 3, 16), mealType: 'Lunch', foodName: 'Rice', calories: 400, protein: 10.0, carbs: 80.0, fat: 2.0, quantity: '1 bowl'),
        DietLogModel(id: '3', date: DateTime(2026, 3, 16), mealType: 'Breakfast', foodName: 'Egg', calories: 80, protein: 6.0, carbs: 1.0, fat: 5.0, quantity: '1'),
      ];

      final breakfastLogs = logs.where((l) => l.mealType == 'Breakfast').toList();
      expect(breakfastLogs.length, 2);

      final breakfastCalories = breakfastLogs.fold<int>(0, (s, l) => s + l.calories);
      expect(breakfastCalories, 280);
    });

    test('stores date correctly', () {
      final date = DateTime(2026, 3, 16, 8, 30);
      final log = DietLogModel(
        id: 'test',
        date: date,
        mealType: 'Snacks',
        foodName: 'Apple',
        calories: 95,
        protein: 0.5,
        carbs: 25.0,
        fat: 0.3,
        quantity: '1 medium',
      );
      expect(log.date.year, 2026);
      expect(log.date.month, 3);
      expect(log.date.day, 16);
    });
  });
}
