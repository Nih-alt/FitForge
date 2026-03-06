import 'package:hive/hive.dart';

part 'water_log_model.g.dart';

@HiveType(typeId: 3)
class WaterLogModel extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  int glassesCount;

  WaterLogModel({
    required this.date,
    required this.glassesCount,
  });
}
