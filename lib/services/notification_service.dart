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

  /// Whether the user has granted notification permission (Android 13+).
  final hasNotificationPermission = false.obs;

  /// Whether exact alarms are available (Android 14+ can revoke).
  bool _exactAlarmsGranted = true;

  /// Whether we've already shown the inexact-alarm fallback snackbar.
  bool _shownInexactSnackbar = false;

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
    if (android == null) return;

    // POST_NOTIFICATIONS — required on Android 13+
    final notifGranted =
        await android.requestNotificationsPermission() ?? false;
    hasNotificationPermission.value = notifGranted;

    // SCHEDULE_EXACT_ALARM — can be revoked on Android 14+
    final exactGranted =
        await android.requestExactAlarmsPermission() ?? false;
    _exactAlarmsGranted = exactGranted;
  }

  /// Re-check permission state (call before scheduling if user may have
  /// toggled permissions in system settings).
  Future<bool> checkNotificationPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true; // non-Android platforms
    final granted = await android.areNotificationsEnabled() ?? false;
    hasNotificationPermission.value = granted;
    return granted;
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

  // ── Safe schedule wrapper ─────────────────────────────────────────────────
  /// Wraps [_plugin.zonedSchedule] with exact-alarm fallback.
  /// If exact alarms are denied, retries with [AndroidScheduleMode.inexact]
  /// and shows a one-time snackbar to the user.
  Future<void> _safeZonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails details,
    required UILocalNotificationDateInterpretation interpretation,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: _exactAlarmsGranted
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: interpretation,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    } catch (_) {
      // Exact alarm permission was revoked at runtime — fall back to inexact.
      _exactAlarmsGranted = false;
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: interpretation,
        matchDateTimeComponents: matchDateTimeComponents,
      );
      _showInexactFallbackSnackbar();
    }
  }

  void _showInexactFallbackSnackbar() {
    if (_shownInexactSnackbar) return;
    _shownInexactSnackbar = true;
    if (Get.context != null) {
      Get.snackbar(
        'Notification Timing',
        'Notifications may be slightly delayed because exact alarm permission is not granted.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // ── Schedule methods ──────────────────────────────────────────────────────

  /// Daily notification at the user's chosen time.
  Future<void> scheduleWorkoutReminder(int hour, int minute) =>
      _safeZonedSchedule(
        id: kWorkoutReminder,
        title: '💪 Time to Workout!',
        body: "Your daily workout is waiting. Let's elevate!",
        scheduledDate: _nextTime(hour, minute),
        details: _kDetails,
        interpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

  /// Daily at 8:00 AM.
  Future<void> scheduleBreakfastReminder() => _safeZonedSchedule(
        id: kBreakfastReminder,
        title: '🌅 Breakfast Time!',
        body: 'Log your breakfast to track your nutrition goals',
        scheduledDate: _nextTime(8, 0),
        details: _kDetails,
        interpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

  /// Daily at 1:00 PM.
  Future<void> scheduleLunchReminder() => _safeZonedSchedule(
        id: kLunchReminder,
        title: '☀️ Lunch Time!',
        body: "Don't forget to log your lunch!",
        scheduledDate: _nextTime(13, 0),
        details: _kDetails,
        interpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

  /// Daily at 8:00 PM.
  Future<void> scheduleDinnerReminder() => _safeZonedSchedule(
        id: kDinnerReminder,
        title: '🌙 Dinner Time!',
        body: "Log your dinner to complete today's nutrition tracking",
        scheduledDate: _nextTime(20, 0),
        details: _kDetails,
        interpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

  /// Every 2 hours from 8 AM to 10 PM (8 notifications, IDs 5–12).
  Future<void> scheduleWaterReminders() async {
    const waterHours = [8, 10, 12, 14, 16, 18, 20, 22];
    for (int i = 0; i < waterHours.length; i++) {
      await _safeZonedSchedule(
        id: 5 + i,
        title: '💧 Hydration Check!',
        body: 'Time to drink a glass of water. Stay hydrated!',
        scheduledDate: _nextTime(waterHours[i], 0),
        details: _kDetails,
        interpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  /// Every Sunday at 9:00 AM.
  Future<void> scheduleWeeklyProgress() => _safeZonedSchedule(
        id: kWeeklyProgress,
        title: '📊 Weekly Progress Report',
        body: 'Check out how you did this week. Keep elevating!',
        scheduledDate: _nextSunday(9, 0),
        details: _kDetails,
        interpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );

  // ── Cancel ────────────────────────────────────────────────────────────────
  Future<void> cancelNotification(int id) => _plugin.cancel(id);
  Future<void> cancelAllNotifications() => _plugin.cancelAll();

  // ── Reschedule all ────────────────────────────────────────────────────────
  Future<void> rescheduleAllNotifications(AppSettingsModel settings) async {
    // Gate on notification permission — if denied, cancel everything.
    final permitted = await checkNotificationPermission();
    await cancelAllNotifications();
    if (!permitted) return;

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
