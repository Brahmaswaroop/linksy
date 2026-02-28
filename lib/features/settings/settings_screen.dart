import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/theme_provider.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final themeMode = ref.watch(themeModeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader(title: 'Appearance'),
          ListTile(
            leading: const Icon(LucideIcons.palette),
            title: const Text('Theme Mode'),
            trailing: DropdownButton<AppThemeMode>(
              value: themeMode,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(
                  value: AppThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(
                  value: AppThemeMode.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem(value: AppThemeMode.dark, child: Text('Dark')),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(themeModeNotifierProvider.notifier).setMode(mode);
                }
              },
            ),
          ),
          const Divider(height: 32),
          _SectionHeader(title: 'Notifications'),
          Consumer(
            builder: (context, ref, child) {
              final isRemindersEnabled = ref.watch(
                dailyRemindersNotifierProvider,
              );
              return SwitchListTile(
                value: isRemindersEnabled,
                onChanged: (val) {
                  ref.read(dailyRemindersNotifierProvider.notifier).toggle();
                },
                secondary: const Icon(LucideIcons.bell),
                title: const Text('Daily Reminders'),
                subtitle: const Text('Get notified about who to contact today'),
              );
            },
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Linksy v1.0.0',
              style: tt.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(
        title,
        style: TextStyle(
          color: cs.primary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
