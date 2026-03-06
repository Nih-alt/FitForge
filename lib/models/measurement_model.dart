import 'package:hive/hive.dart';

part 'measurement_model.g.dart';

@HiveType(typeId: 5)
class MeasurementModel extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  double chest;

  @HiveField(2)
  double waist;

  @HiveField(3)
  double hips;

  @HiveField(4)
  double biceps;

  @HiveField(5)
  double thighs;

  MeasurementModel({
    required this.date,
    required this.chest,
    required this.waist,
    required this.hips,
    required this.biceps,
    required this.thighs,
  });
}
