import 'package:hive/hive.dart';

part 'personal_record_model.g.dart';

@HiveType(typeId: 7)
class PersonalRecordModel extends HiveObject {
  @HiveField(0)
  String exerciseName;

  @HiveField(1)
  double value;

  @HiveField(2)
  String unit;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  List<Map> history;

  PersonalRecordModel({
    required this.exerciseName,
    required this.value,
    required this.unit,
    required this.date,
    required this.history,
  });
}
