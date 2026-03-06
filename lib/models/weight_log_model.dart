import 'package:hive/hive.dart';

part 'weight_log_model.g.dart';

@HiveType(typeId: 4)
class WeightLogModel extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  double weight;

  WeightLogModel({
    required this.date,
    required this.weight,
  });
}
