import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/database/repositories/people_repository.dart';
import '../../core/engine/health_score_engine.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peopleAsync = ref.watch(allPeopleProvider);
    final engine = ref.watch(healthScoreEngineProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Insights', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      ),
      body: peopleAsync.when(
        data: (people) {
          if (people.isEmpty) {
            return Center(
              child: Text('No contacts tracked yet.', style: tt.bodyLarge?.copyWith(color: cs.onSurface.withValues(alpha: 0.5))),
            );
          }

          int onTrackCount = 0;
          int dueSoonCount = 0;
          int overdueCount = 0;
          int totalHealth = 0;

          for (final person in people) {
            final status = engine.calculateHealth(
              targetFrequencyDays: person.targetFrequencyDays,
              lastInteractionDate: person.lastInteractionDate,
              priorityLevel: person.priorityLevel,
              averageGapDays: person.averageGapDays,
              createdAt: person.createdAt,
            );
            totalHealth += status.baseScore;
            if (status.statusEmoji == '🟢') {
              onTrackCount++;
            } else if (status.statusEmoji == '🟡') {
              dueSoonCount++;
            } else {
              overdueCount++;
            }
          }
          final averageHealth = totalHealth / people.length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatCard(title: 'Total Tracked Contacts', value: '${people.length}', icon: LucideIcons.users),
              _StatCard(title: 'Average Reminder Health', value: '${averageHealth.toStringAsFixed(1)}%', icon: LucideIcons.activity),
              _StatCard(title: 'Overdue Contacts', value: '$overdueCount', color: Colors.red, icon: LucideIcons.clock),
              const SizedBox(height: 24),
              Text('Reminder Status Overview', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sections: [
                      if (onTrackCount > 0)
                        PieChartSectionData(
                          value: onTrackCount.toDouble(),
                          title: 'On Track ($onTrackCount)',
                          color: Colors.green,
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      if (dueSoonCount > 0)
                        PieChartSectionData(
                          value: dueSoonCount.toDouble(),
                          title: 'Due Soon ($dueSoonCount)',
                          color: Colors.amber.shade700,
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      if (overdueCount > 0)
                        PieChartSectionData(
                          value: overdueCount.toDouble(),
                          title: 'Overdue ($overdueCount)',
                          color: Colors.redAccent,
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                    ],
                    sectionsSpace: 3,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? color;
  final IconData icon;

  const _StatCard({required this.title, required this.value, this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: cs.primary),
              const SizedBox(width: 12),
              Text(title, style: tt.titleSmall),
            ],
          ),
          Text(value, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
