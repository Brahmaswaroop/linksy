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

  // Set up notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  // Set up background recalculation
  await BackgroundJobService.initialize();
  BackgroundJobService.scheduleDailyHealthCheck();

  final prefs = await SharedPreferences.getInstance();

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
