import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/background_job_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // Set up notifications using the shared instance
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  // Re-schedule the daily notification on every app start if reminders are on.
  // This ensures the alarm survives device reboots and reinstalls without the
  // user needing to visit Settings.
  final remindersEnabled = prefs.getBool('daily_reminders_enabled') ?? true;
  if (remindersEnabled) {
    final hour = prefs.getInt('notification_time_hour') ?? 10;
    final minute = prefs.getInt('notification_time_minute') ?? 0;
    await notificationService.scheduleDailyNotification(
      id: 1,
      title: 'Check your bonds!',
      body: 'Take a look at your Dashboard to see who needs attention today.',
      time: TimeOfDay(hour: hour, minute: minute),
    );
  }

  // Set up background recalculation (Workmanager — used for future background DB tasks)
  await BackgroundJobService.initialize();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyBondsApp(),
    ),
  );
}

class MyBondsApp extends ConsumerWidget {
  const MyBondsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);

    ThemeMode flutterThemeMode;
    switch (themeMode) {
      case AppThemeMode.system:
        flutterThemeMode = ThemeMode.system;
        break;
      case AppThemeMode.light:
        flutterThemeMode = ThemeMode.light;
        break;
      case AppThemeMode.dark:
        flutterThemeMode = ThemeMode.dark;
        break;
    }

    return MaterialApp.router(
      title: 'Linksy',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: flutterThemeMode,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
