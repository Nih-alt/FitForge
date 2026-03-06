import 'package:hive/hive.dart';

part 'diet_log_model.g.dart';

@HiveType(typeId: 2)
class DietLogModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String mealType;

  @HiveField(3)
  String foodName;

  @HiveField(4)
  int calories;

  @HiveField(5)
  double protein;

  @HiveField(6)
  double carbs;

  @HiveField(7)
  double fat;

  @HiveField(8)
  String quantity;

  DietLogModel({
    required this.id,
    required this.date,
    required this.mealType,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.quantity,
  });
}
