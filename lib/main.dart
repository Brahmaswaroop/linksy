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

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );

  // Initialize notifications through the provider to ensure the singleton is ready
  final notificationService = container.read(notificationServiceProvider);
  await notificationService.init();

  // Re-schedule the daily notification on every app start if reminders are on.
  final remindersEnabled = prefs.getBool('daily_reminders_enabled') ?? true;
  if (remindersEnabled) {
    final hour = prefs.getInt('notification_time_hour') ?? 10;
    final minute = prefs.getInt('notification_time_minute') ?? 0;
    await notificationService.scheduleDailyDigest(
      TimeOfDay(hour: hour, minute: minute),
    );
  }

  // Set up background recalculation
  await BackgroundJobService.initialize();

  runApp(
    UncontrolledProviderScope(
      container: container,
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
