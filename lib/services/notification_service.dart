import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/app_settings_model.dart';

// ============================================================================
//  NOTIFICATION SERVICE — Schedules and manages all local notifications
// ============================================================================

class NotificationService extends GetxService {
  static NotificationService get to => Get.find<NotificationService>();

  final _plugin = FlutterLocalNotificationsPlugin();

  // ── Notification IDs ──────────────────────────────────────────────────────
  static const int kWorkoutReminder   = 1;
  static const int kBreakfastReminder = 2;
  static const int kLunchReminder     = 3;
  static const int kDinnerReminder    = 4;
  // Water reminders: IDs 5–12 (one per 2-hour block: 8AM→10PM)
  static const int kWeeklyProgress    = 13;

  static const _kChannelId   = 'elevate_channel';
  static const _kChannelName = 'Elevate Notifications';

  // ── Initialization ────────────────────────────────────────────────────────
  Future<NotificationService> init() async {
    // 1. Timezone setup
    tz.initializeTimeZones();
    final String localTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz));

    // 2. Plugin initialization
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    // 3. Create Android notification channel
    const channel = AndroidNotificationChannel(
      _kChannelId,
      _kChannelName,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Request permissions (system dialog on Android 13+)
    await _requestPermissions();

    return this;
  }

  Future<void> _requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  // ── Shared notification details ───────────────────────────────────────────
  static const _kAndroidDetails = AndroidNotificationDetails(
    _kChannelId,
    _kChannelName,
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
  );
  static const _kDetails = NotificationDetails(android: _kAndroidDetails);

  // ── Helpers ───────────────────────────────────────────────────────────────
  tz.TZDateTime _nextTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!t.isAfter(now)) t = t.add(const Duration(days: 1));
    return t;
  }

  tz.TZDateTime _nextSunday(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    // weekday: Mon=1 … Sun=7
    final daysToSunday = (DateTime.sunday - t.weekday + 7) % 7;
    t = t.add(Duration(days: daysToSunday));
    if (!t.isAfter(now)) t = t.add(const Duration(days: 7));
    return t;
  }

  // ── Schedule methods ──────────────────────────────────────────────────────

  /// Daily notification at the user's chosen time.
  Future<void> scheduleWorkoutReminder(int hour, int minute) =>
      _plugin.zonedSchedule(
        kWorkoutReminder,
        '💪 Time to Workout!',
        "Your daily workout is waiting. Let's elevate!",
        _nextTime(hour, minute),
        _kDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

  /// Daily at 8:00 AM.
  Future<void> scheduleBreakfastReminder() => _plugin.zonedSchedule(
        kBreakfastReminder,
        '🌅 Breakfast Time!',
        'Log your breakfast to track your nutrition goals',
        _nextTime(8, 0),
        _kDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

  /// Daily at 1:00 PM.
  Future<void> scheduleLunchReminder() => _plugin.zonedSchedule(
        kLunchReminder,
        '☀️ Lunch Time!',
        "Don't forget to log your lunch!",
        _nextTime(13, 0),
        _kDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

  /// Daily at 8:00 PM.
  Future<void> scheduleDinnerReminder() => _plugin.zonedSchedule(
        kDinnerReminder,
        '🌙 Dinner Time!',
        "Log your dinner to complete today's nutrition tracking",
        _nextTime(20, 0),
        _kDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

  /// Every 2 hours from 8 AM to 10 PM (8 notifications, IDs 5–12).
  Future<void> scheduleWaterReminders() async {
    const waterHours = [8, 10, 12, 14, 16, 18, 20, 22];
    for (int i = 0; i < waterHours.length; i++) {
      await _plugin.zonedSchedule(
        5 + i,
        '💧 Hydration Check!',
        'Time to drink a glass of water. Stay hydrated!',
        _nextTime(waterHours[i], 0),
        _kDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  /// Every Sunday at 9:00 AM.
  Future<void> scheduleWeeklyProgress() => _plugin.zonedSchedule(
        kWeeklyProgress,
        '📊 Weekly Progress Report',
        'Check out how you did this week. Keep elevating!',
        _nextSunday(9, 0),
        _kDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );

  // ── Cancel ────────────────────────────────────────────────────────────────
  Future<void> cancelNotification(int id) => _plugin.cancel(id);
  Future<void> cancelAllNotifications() => _plugin.cancelAll();

  // ── Reschedule all ────────────────────────────────────────────────────────
  Future<void> rescheduleAllNotifications(AppSettingsModel settings) async {
    await cancelAllNotifications();
    if (settings.workoutReminderOn) {
      await scheduleWorkoutReminder(
          settings.workoutReminderHour, settings.workoutReminderMinute);
    }
    if (settings.mealReminderOn) {
      await scheduleBreakfastReminder();
      await scheduleLunchReminder();
      await scheduleDinnerReminder();
    }
    if (settings.waterReminderOn) {
      await scheduleWaterReminders();
    }
    if (settings.progressUpdateOn) {
      await scheduleWeeklyProgress();
    }
  }
}
