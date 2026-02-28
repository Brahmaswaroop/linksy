import 'package:drift/drift.dart';
import 'package:workmanager/workmanager.dart';

import '../database/database.dart';
import '../engine/health_score_engine.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // 1. Initialize DB in isolate
      final db = AppDatabase();

      // 2. Fetch all people
      final people = await db.select(db.people).get();
      if (people.isEmpty) return Future.value(true);

      // 3. Health Score iteration
      final engine = HealthScoreEngine();
      int overdueCount = 0;

      for (final person in people) {
        // Fetch last interaction
        final recentInteractions =
            await (db.select(db.interactions)
                  ..where((t) => t.personId.equals(person.id))
                  ..orderBy([
                    (t) => OrderingTerm(
                      expression: t.date,
                      mode: OrderingMode.desc,
                    ),
                  ])
                  ..limit(1))
                .get();

        final lastInteractionDate = recentInteractions.isNotEmpty
            ? recentInteractions.first.date
            : null;

        final healthStatus = engine.calculateHealth(
          targetFrequencyDays: person.targetFrequencyDays,
          lastInteractionDate: lastInteractionDate,
          priorityLevel: person.priorityLevel,
          averageGapDays: person.averageGapDays,
          createdAt: person.createdAt,
        );

        if (healthStatus.daysOverdue > 0) {
          overdueCount++;
        }
      }

      await db.close();

      // 4. Notify if anyone is overdue
      if (overdueCount > 0) {
        final notificationPlugin = NotificationService();
        await notificationPlugin.initialize();

        final title = overdueCount == 1
            ? '1 Connection Needs Attention'
            : '$overdueCount Connections Need Attention';
        final body = 'Check your Dashboard to see who you should reach out to!';

        await notificationPlugin.showNotification(
          id: 1, // Fixed ID so it updates the same notification slot
          title: title,
          body: body,
        );
      }

      return Future.value(true);
    } catch (err) {
      return Future.value(false);
    }
  });
}

class BackgroundJobService {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  static void scheduleDailyHealthCheck() {
    Workmanager().registerPeriodicTask(
      'daily_health_check',
      'health_check_task',
      frequency: const Duration(hours: 24),
      initialDelay: const Duration(
        minutes: 15,
      ), // Small delay for testing/first run
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }
}
