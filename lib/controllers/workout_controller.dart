import 'package:get/get.dart';

import '../models/workout_log_model.dart';
import '../services/hive_service.dart';

class WorkoutController extends GetxController {
  static WorkoutController get to => Get.find();

  final HiveService _hive = Get.find<HiveService>();

  final RxList<WorkoutLogModel> workoutLogs = RxList();
  final Rx<WorkoutLogModel?> todaysWorkout = Rx(null);
  final RxInt currentStreak = RxInt(0);
  final RxInt weeklyWorkoutsCompleted = RxInt(0);
  final RxInt totalCaloriesBurned = RxInt(0);
  final RxString totalActiveTime = RxString('0h');

  final RxInt todayCaloriesBurned = RxInt(0);
  final RxInt todayActiveMinutes = RxInt(0);

  @override
  void onInit() {
    super.onInit();
    loadWorkoutLogs();
  }

  void loadWorkoutLogs() {
    try {
      final logs = _hive.getWorkoutLogs();
      logs.sort((a, b) => b.date.compareTo(a.date));
      workoutLogs.assignAll(logs);
    } catch (_) {
      workoutLogs.clear();
    }

    _findTodaysWorkout();
    _calculateTodayStats();
    calculateStreak();
    calculateWeeklyStats();
  }

  void _findTodaysWorkout() {
    final now = _dateOnly(DateTime.now());
    final todayLogs = workoutLogs.where((log) =>
        _dateOnly(log.date) == now);
    todaysWorkout.value = todayLogs.isNotEmpty ? todayLogs.first : null;
  }

  void _calculateTodayStats() {
    final now = _dateOnly(DateTime.now());
    final todayLogs = workoutLogs.where((log) =>
        _dateOnly(log.date) == now);

    int cal = 0;
    int sec = 0;
    for (final log in todayLogs) {
      cal += log.caloriesBurned;
      sec += log.durationSeconds;
    }
    todayCaloriesBurned.value = cal;
    todayActiveMinutes.value = (sec / 60).round();
  }

  void calculateStreak() {
    if (workoutLogs.isEmpty) {
      currentStreak.value = 0;
      return;
    }

    final dates = _uniqueWorkoutDatesDesc();
    final today = _dateOnly(DateTime.now());

    int streak = 0;
    DateTime checkDate = today;

    if (dates.isNotEmpty && dates.first.difference(today).inDays == -1) {
      checkDate = today.subtract(const Duration(days: 1));
    }

    for (final date in dates) {
      if (date == checkDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (date.isBefore(checkDate)) {
        break;
      }
    }
    currentStreak.value = streak;
  }

  void calculateWeeklyStats() {
    final now = _dateOnly(DateTime.now());
    final weekStart = now
        .subtract(Duration(days: now.weekday - 1));

    final thisWeekLogs = workoutLogs.where((log) {
      final logDate = _dateOnly(log.date);
      return !logDate.isBefore(weekStart);
    });

    int calories = 0;
    int totalSeconds = 0;
    final uniqueDays = <DateTime>{};
    for (final log in thisWeekLogs) {
      uniqueDays.add(_dateOnly(log.date));
      calories += log.caloriesBurned;
      totalSeconds += log.durationSeconds;
    }

    weeklyWorkoutsCompleted.value = uniqueDays.length;
    totalCaloriesBurned.value = calories;

    final hours = totalSeconds / 3600;
    if (hours >= 1) {
      totalActiveTime.value = '${hours.toStringAsFixed(1)}h';
    } else {
      totalActiveTime.value = '${(totalSeconds / 60).round()}m';
    }
  }

  Future<void> saveWorkoutLog(WorkoutLogModel log) async {
    try {
      await _hive.saveWorkoutLog(log);
      loadWorkoutLogs();
    } catch (_) {
      // No-op: keeping UI responsive even if write fails.
    }
  }

  int calculateLongestStreak() {
    final dates = _uniqueWorkoutDatesDesc().reversed.toList();
    if (dates.isEmpty) return 0;

    int longest = 1;
    int running = 1;
    for (int i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        running++;
        if (running > longest) {
          longest = running;
        }
      } else {
        running = 1;
      }
    }
    return longest;
  }

  int caloriesOnDate(DateTime date) {
    final target = _dateOnly(date);
    return workoutLogs
        .where((log) => _dateOnly(log.date) == target)
        .fold(0, (sum, log) => sum + log.caloriesBurned);
  }

  int activeMinutesOnDate(DateTime date) {
    final target = _dateOnly(date);
    final totalSeconds = workoutLogs
        .where((log) => _dateOnly(log.date) == target)
        .fold(0, (sum, log) => sum + log.durationSeconds);
    return (totalSeconds / 60).round();
  }

  bool hasWorkoutOnDate(DateTime date) {
    final target = _dateOnly(date);
    return workoutLogs.any((log) => _dateOnly(log.date) == target);
  }

  Map<int, double> weeklyActivityMap() {
    final now = _dateOnly(DateTime.now());
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    final map = <int, double>{};
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final cal = caloriesOnDate(date);
      map[i] = (cal / 500).clamp(0.0, 1.0);
    }
    return map;
  }

  int activityLevel(DateTime date) {
    final cal = caloriesOnDate(date);
    if (cal == 0) return 0;
    if (cal < 150) return 1;
    if (cal <= 300) return 2;
    return 3;
  }

  List<DateTime> _uniqueWorkoutDatesDesc() {
    final dates = workoutLogs.map((l) => _dateOnly(l.date)).toSet().toList();
    dates.sort((a, b) => b.compareTo(a));
    return dates;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
