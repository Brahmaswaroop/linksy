import 'dart:io';
import 'package:call_log/call_log.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../database/database.dart';
import '../engine/health_score_engine.dart';
import 'call_log_sync_service.dart';
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

      // 3. Background Call Log Sync on Android
      if (Platform.isAndroid) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final lastSyncMillis = prefs.getInt('last_call_log_sync_timestamp') ??
              DateTime.now()
                  .subtract(const Duration(days: 7))
                  .millisecondsSinceEpoch;

          final entries = await CallLog.query(dateFrom: lastSyncMillis);
          final peopleWithPhones = people
              .where((p) => p.phoneNumber != null && p.phoneNumber!.trim().isNotEmpty)
              .toList();

          if (entries.isNotEmpty && peopleWithPhones.isNotEmpty) {
            for (final entry in entries) {
              final entryNumber = entry.number;
              final timestamp = entry.timestamp;
              final duration = entry.duration ?? 0;
              final callType = entry.callType;

              if (entryNumber == null || timestamp == null) continue;

              final isMeaningful = (callType == CallType.outgoing && duration > 0) ||
                  (callType == CallType.incoming && duration >= 10);
              if (!isMeaningful) continue;

              final callDate = DateTime.fromMillisecondsSinceEpoch(timestamp);

              for (final person in peopleWithPhones) {
                if (CallLogSyncService.numbersMatch(person.phoneNumber!, entryNumber)) {
                  final lastDate = person.lastInteractionDate;
                  if (lastDate == null || callDate.isAfter(lastDate)) {
                    await db.into(db.interactions).insert(
                      InteractionsCompanion.insert(
                        personId: person.id,
                        type: const Value('Call'),
                        notes: Value('Background call sync: ${callType?.name ?? 'call'} (${duration}s)'),
                        date: Value(callDate),
                      ),
                    );
                    await (db.update(db.people)..where((t) => t.id.equals(person.id)))
                        .write(PeopleCompanion(lastInteractionDate: Value(callDate)));
                  }
                  break;
                }
              }
            }
            await prefs.setInt(
              'last_call_log_sync_timestamp',
              DateTime.now().millisecondsSinceEpoch,
            );
          }
        } catch (_) {
          // ignore background call log sync error
        }
      }

      // 4. Health Score iteration
      final engine = HealthScoreEngine();
      final List<Map<String, dynamic>> overduePeople = [];

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

        if (healthStatus.statusEmoji == '🔴' ||
            healthStatus.daysOverdue >= -2) {
          overduePeople.add({
            'person': person,
            'daysOverdue': healthStatus.daysOverdue,
          });
        }
      }

      await db.close();

      // 4. Notify if anyone is overdue
      if (overduePeople.isNotEmpty) {
        final notificationPlugin = NotificationService();
        await notificationPlugin.init();
        
        // Let's show a health alert for each overdue person
        for (final item in overduePeople) {
          final person = item['person'] as Person;
          final daysOverdue = item['daysOverdue'] as int;
          
          await notificationPlugin.showHealthAlert(
            personId: person.id,
            personName: person.name,
            daysOverdue: daysOverdue > 0 ? daysOverdue : 0,
          );
        }
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
