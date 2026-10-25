import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';
import '../database/database.dart';
import '../router/app_router.dart';
import '../utils/contact_action_helper.dart';

part 'notification_service.g.dart';

enum NotificationType {
  dailyDigest,
  lowHealthAlert,
  overdueNudge,
  upcomingReminder
}

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  return NotificationService();
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const _batteryChannel = MethodChannel('com.example.linksy/battery_optimization');

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Initialize Timezones
    tz.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    // flutter_timezone v5.0.1+ returns a TimezoneInfo object, we need the identifier
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    // 2. Initialize Native Settings
    // Ensure you have an icon named 'ic_launcher' in your android/app/src/main/res/mipmap folders
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false, // We will request explicitly later
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  // Handle Deep Linking & 1-Tap Notification Actions (Call & Done)
  void _onNotificationTap(NotificationResponse response) async {
    final payload = response.payload;
    if (payload != null) {
      debugPrint('Notification clicked with action: ${response.actionId}, payload: $payload');
      final personId = int.tryParse(payload);
      if (personId != null) {
        if (response.actionId == 'done_action') {
          // Log interaction immediately without opening app
          final db = AppDatabase();
          await db.into(db.interactions).insert(
            InteractionsCompanion.insert(
              personId: personId,
              type: const Value('Call'),
              notes: const Value('Marked done from notification'),
              date: Value(DateTime.now()),
            ),
          );
          await (db.update(db.people)..where((t) => t.id.equals(personId)))
              .write(PeopleCompanion(lastInteractionDate: Value(DateTime.now())));
          await db.close();
          return;
        }

        if (response.actionId == 'call_action') {
          // Look up contact phone and trigger dialer
          final db = AppDatabase();
          final person = await (db.select(db.people)..where((t) => t.id.equals(personId)))
              .getSingleOrNull();
          await db.close();

          if (person?.phoneNumber != null && person!.phoneNumber!.isNotEmpty) {
            await ContactActionHelper.call(person.phoneNumber!);
            return;
          }
        }

        if (rootNavigatorKey.currentContext != null) {
          rootNavigatorKey.currentContext!.push('/people/$personId');
        }
      }
    }
  }

  /// Request permissions dynamically (Call this from a UI Button or Onboarding)
  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  // ==========================================
  // IMMEDIATE NOTIFICATIONS (Workmanager)
  // ==========================================

  Future<void> showHealthAlert({
    required int personId,
    required String personName,
    required int daysOverdue,
  }) async {
    // ID Range: 200-299 as per your architecture
    final int notificationId = 200 + (personId % 100); 

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'linksy_health', // Channel ID
      'Health Alerts', // Channel Name
      channelDescription: 'Urgent nudges for overdue contacts',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'call_action',
          'Call',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'done_action',
          'Mark Done',
          cancelNotification: true,
        ),
      ],
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      id: notificationId,
      title: 'Interaction Overdue!',
      body: 'You are $daysOverdue days overdue to check in with $personName.',
      notificationDetails: platformDetails,
      payload: personId.toString(), // Payload for deep link & action handlers
    );
  }

  // ==========================================
  // SCHEDULED NOTIFICATIONS (Daily Digest)
  // ==========================================

  Future<void> scheduleDailyDigest(TimeOfDay time) async {
    const int notificationId = 1; // ID Range: 1

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'linksy_daily', // Channel ID
      'Daily Digest', // Channel Name
      channelDescription: 'Daily summary of relationship health',
      importance: Importance.high,
      priority: Priority.defaultPriority,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: notificationId,
      title: 'Linksy Daily Digest',
      body: 'Time to check your relationship health summary!',
      scheduledDate: _nextInstanceOfTime(time), // Calculate mathematically correct local time
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeats daily
    );
  }

  Future<void> scheduleBirthdayReminder(int personId, String personName, DateTime birthday) async {
    // ID Range: 300-399 for birthdays
    final int notificationId = 300 + (personId % 100);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'linksy_birthdays', // Channel ID
      'Birthday Reminders', // Channel Name
      channelDescription: 'Yearly reminders for birthdays',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, birthday.month, birthday.day, 9, 0); // 9:00 AM

    if (scheduledDate.isBefore(now)) {
      scheduledDate = tz.TZDateTime(
          tz.local, now.year + 1, birthday.month, birthday.day, 9, 0);
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: notificationId,
      title: 'Birthday Reminder 🎂',
      body: 'Today is $personName\'s birthday! Don\'t forget to wish them well.',
      scheduledDate: scheduledDate,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime, // Match day and month yearly
      payload: personId.toString(),
    );
  }

  // ==========================================
  // UTILS & CANCELLATIONS
  // ==========================================

  Future<void> cancelHealthAlert(int personId) async {
    final int notificationId = 200 + (personId % 100);
    await flutterLocalNotificationsPlugin.cancel(id: notificationId);
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Helper mathematically calculates the next valid Date for a specific TimeOfDay
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // ==========================================
  // UI SETTINGS & DEBUGGING UTILS
  // ==========================================

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'linksy_test', 
      'Test Notifications', 
      channelDescription: 'Used for testing notification functionality',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformDetails,
    );
  }

  Future<bool> isExactAlarmPermissionGranted() async {
    if (!Platform.isAndroid) return true;
    return await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.canScheduleExactNotifications() ?? false;
  }

  Future<void> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  Future<bool> isBatteryOptimizationExempted() async {
    if (!Platform.isAndroid) return true;
    try {
      final bool isExempted = await _batteryChannel.invokeMethod('isIgnoringBatteryOptimizations');
      return isExempted;
    } on PlatformException catch (e) {
      debugPrint("Failed to check battery optimization: '${e.message}'.");
      return true;
    }
  }

  Future<void> requestBatteryOptimizationExemption() async {
    if (!Platform.isAndroid) return;
    try {
      await _batteryChannel.invokeMethod('requestBatteryOptimizationExemption');
    } on PlatformException catch (e) {
      debugPrint("Failed to request battery optimization exemption: '${e.message}'.");
    }
  }
}
