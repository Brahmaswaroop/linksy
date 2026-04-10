import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/notification_service.dart';

class DailyRemindersNotifier extends Notifier<bool> {
  static const _remindersKey = 'daily_reminders_enabled';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_remindersKey) ?? true;
  }

  Future<void> setEnabled(bool isEnabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_remindersKey, isEnabled);
    state = isEnabled;

    // Auto-schedule or cancel
    final time = ref.read(notificationTimeNotifierProvider);
    final notificationService = ref.read(notificationServiceProvider);

    if (isEnabled) {
      await notificationService.scheduleDailyDigest(time);
    } else {
      await notificationService.cancelNotification(1);
    }
  }
}

final dailyRemindersNotifierProvider =
    NotifierProvider<DailyRemindersNotifier, bool>(DailyRemindersNotifier.new);

class NotificationTimeNotifier extends Notifier<TimeOfDay> {
  static const _hourKey = 'notification_time_hour';
  static const _minuteKey = 'notification_time_minute';

  @override
  TimeOfDay build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final hour = prefs.getInt(_hourKey) ?? 10;
    final minute = prefs.getInt(_minuteKey) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> setTime(TimeOfDay newTime) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_hourKey, newTime.hour);
    await prefs.setInt(_minuteKey, newTime.minute);
    state = newTime;

    // Reschedule if enabled
    final isEnabled = ref.read(dailyRemindersNotifierProvider);
    if (isEnabled) {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.scheduleDailyDigest(newTime);
    }
  }
}

final notificationTimeNotifierProvider =
    NotifierProvider<NotificationTimeNotifier, TimeOfDay>(
      NotificationTimeNotifier.new,
    );
