import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';

class DailyRemindersNotifier extends Notifier<bool> {
  static const _remindersKey = 'daily_reminders_enabled';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_remindersKey) ?? true;
  }

  Future<void> toggle() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final newValue = !state;
    await prefs.setBool(_remindersKey, newValue);
    state = newValue;
  }
}

final dailyRemindersNotifierProvider =
    NotifierProvider<DailyRemindersNotifier, bool>(DailyRemindersNotifier.new);
