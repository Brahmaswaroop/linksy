import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

  // Handle Deep Linking payload
  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      debugPrint('Notification payload clicked: ${response.payload}');
      // TODO: Route to Person Details screen using GoRouter/Navigator
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
      payload: personId.toString(), // Payload for deep link
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
