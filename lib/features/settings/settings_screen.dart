import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/notification_service.dart';
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
              final notificationTime = ref.watch(
                notificationTimeNotifierProvider,
              );

              return Column(
                children: [
                  SwitchListTile(
                    value: isRemindersEnabled,
                    onChanged: (val) {
                      ref
                          .read(dailyRemindersNotifierProvider.notifier)
                          .setEnabled(val);
                    },
                    secondary: const Icon(LucideIcons.bell),
                    title: const Text('Daily Reminders'),
                    subtitle: const Text(
                      'Get notified about who to contact today',
                    ),
                  ),
                  if (isRemindersEnabled)
                    ListTile(
                      leading: const Icon(LucideIcons.clock),
                      title: const Text('Notification Time'),
                      subtitle: Text(notificationTime.format(context)),
                      trailing: const Icon(LucideIcons.chevronRight, size: 20),
                      onTap: () async {
                        final newTime = await showTimePicker(
                          context: context,
                          initialTime: notificationTime,
                        );
                        if (newTime != null) {
                          ref
                              .read(notificationTimeNotifierProvider.notifier)
                              .setTime(newTime);
                        }
                      },
                    ),
                  const Divider(indent: 72),
                  ListTile(
                    leading: const Icon(LucideIcons.flaskConical),
                    title: const Text('Test Notification'),
                    subtitle: const Text('Send an immediate notification now'),
                    onTap: () async {
                      final service = ref.read(notificationServiceProvider);
                      await service.showImmediateNotification(
                        id: 99,
                        title: 'Test Notification',
                        body: 'If you see this, notifications are working!',
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Test notification sent!')),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.listChecks),
                    title: const Text('Check Scheduled'),
                    subtitle: const Text('Verify if daily reminders are queued'),
                    onTap: () async {
                      final service = ref.read(notificationServiceProvider);
                      final pending = await service.getPendingNotifications();
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Scheduled Notifications'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (pending.isEmpty)
                                  const Text('No notifications scheduled.')
                                else
                                  ...pending.map((p) => ListTile(
                                    title: Text('ID: ${p.id}'),
                                    subtitle: Text(p.title ?? 'No title'),
                                  )),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ],
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
