import 'package:hive/hive.dart';

part 'workout_log_model.g.dart';

@HiveType(typeId: 1)
class WorkoutLogModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String workoutName;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  int durationSeconds;

  @HiveField(4)
  int caloriesBurned;

  @HiveField(5)
  int exercisesCompleted;

  @HiveField(6)
  List<String> exercises;

  WorkoutLogModel({
    required this.id,
    required this.workoutName,
    required this.date,
    required this.durationSeconds,
    required this.caloriesBurned,
    required this.exercisesCompleted,
    required this.exercises,
  });
}
