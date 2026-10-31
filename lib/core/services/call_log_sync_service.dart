import 'dart:io';
import 'package:call_log/call_log.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/repositories/interactions_repository.dart';
import '../database/repositories/people_repository.dart';

class CallLogSyncResult {
  final int syncedInteractionsCount;
  final List<String> updatedContactNames;

  CallLogSyncResult({
    required this.syncedInteractionsCount,
    required this.updatedContactNames,
  });
}

class CallLogSyncService {
  final PeopleRepository _peopleRepo;
  final InteractionsRepository _interactionsRepo;

  CallLogSyncService(this._peopleRepo, this._interactionsRepo);

  /// Extract only digits for number matching
  static String normalize(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  /// Match phone numbers accounting for country codes / formatting
  static bool numbersMatch(String a, String b) {
    final cleanA = normalize(a);
    final cleanB = normalize(b);
    if (cleanA.isEmpty || cleanB.isEmpty) return false;
    if (cleanA == cleanB) return true;

    // Compare last 8 or 9 digits if lengths differ due to country codes (e.g. +1, +44, +91)
    const minLen = 8;
    if (cleanA.length >= minLen && cleanB.length >= minLen) {
      final suffixA = cleanA.substring(cleanA.length - minLen);
      final suffixB = cleanB.substring(cleanB.length - minLen);
      return suffixA == suffixB;
    }
    return false;
  }

  /// Automatically scan system call log on Android and log interactions for contacts
  Future<CallLogSyncResult> syncCallLogs({int lookbackDays = 30}) async {
    // Call log reading is only supported on Android
    if (!Platform.isAndroid) {
      return CallLogSyncResult(
        syncedInteractionsCount: 0,
        updatedContactNames: const [],
      );
    }

    try {
      final queryDateFrom = DateTime.now()
          .subtract(Duration(days: lookbackDays))
          .millisecondsSinceEpoch;

      final entries = await CallLog.query(dateFrom: queryDateFrom);
      final people = await _peopleRepo.getAllPeople();
      final peopleWithPhones = people
          .where((p) => p.phoneNumber != null && p.phoneNumber!.trim().isNotEmpty)
          .toList();

      if (peopleWithPhones.isEmpty || entries.isEmpty) {
        return CallLogSyncResult(
          syncedInteractionsCount: 0,
          updatedContactNames: const [],
        );
      }

      int syncedCount = 0;
      final updatedNames = <String>[];

      // Sort entries ascending by timestamp to preserve chronological order
      final sortedEntries = entries.toList()
        ..sort((a, b) => (a.timestamp ?? 0).compareTo(b.timestamp ?? 0));

      for (final entry in sortedEntries) {
        final entryNumber = entry.number;
        final timestamp = entry.timestamp;
        final duration = entry.duration ?? 0;
        final callType = entry.callType;

        if (entryNumber == null || timestamp == null) continue;

        // Any outgoing call (placed outreach by user) or answered incoming call (> 0s)
        final isOutgoing = callType == CallType.outgoing ||
            callType == CallType.wifiOutgoing;
        final isIncoming = callType == CallType.incoming ||
            callType == CallType.wifiIncoming;

        final isMeaningful = isOutgoing || (isIncoming && duration > 0);
        if (!isMeaningful) continue;

        final callDate = DateTime.fromMillisecondsSinceEpoch(timestamp);

        // Find matching contact in the database
        for (final person in peopleWithPhones) {
          if (numbersMatch(person.phoneNumber!, entryNumber)) {
            final alreadyLogged = await _interactionsRepo.hasInteractionNearDate(
              person.id,
              callDate,
            );

            if (!alreadyLogged) {
              await _interactionsRepo.logInteraction(
                InteractionsCompanion.insert(
                  personId: person.id,
                  type: const Value('Call'),
                  notes: Value(
                    'Auto call log: ${callType?.name ?? 'call'} (${duration}s)',
                  ),
                  date: Value(callDate),
                ),
              );
              syncedCount++;
              if (!updatedNames.contains(person.name)) {
                updatedNames.add(person.name);
              }
            }
            break;
          }
        }
      }

      return CallLogSyncResult(
        syncedInteractionsCount: syncedCount,
        updatedContactNames: updatedNames,
      );
    } catch (e) {
      return CallLogSyncResult(
        syncedInteractionsCount: 0,
        updatedContactNames: const [],
      );
    }
  }
}

final callLogSyncServiceProvider = Provider<CallLogSyncService>((ref) {
  return CallLogSyncService(
    ref.watch(peopleRepositoryProvider),
    ref.watch(interactionsRepositoryProvider),
  );
});
