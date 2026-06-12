import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize timezone database
    tzdata.initializeTimeZones();
    // Use device local timezone
    tz.setLocalLocation(tz.getLocation('Europe/Moscow'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // Request notification permissions on Android 13+
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();
    }
  }

  /// Schedule daily reminders at 09:00 AM, Monday to Friday
  static Future<void> scheduleDailyReminders() async {
    // Cancel any existing notifications first
    await _plugin.cancelAll();

    // Schedule for Monday(1) through Friday(5)
    for (int weekday = 1; weekday <= 5; weekday++) {
      await _plugin.zonedSchedule(
        weekday,
        '📚 English Tracker',
        'Your English lesson is ready!',
        _nextInstanceOfWeekdayTime(weekday, 9, 0),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder',
            'Daily Reminders',
            channelDescription: 'Daily English lesson reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFF00E5FF),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  static tz.TZDateTime _nextInstanceOfWeekdayTime(
      int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Advance to the correct weekday
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    // If it's already passed, schedule for next week
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }

    return scheduled;
  }
}
