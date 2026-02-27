import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_score_engine.g.dart';

class RelationshipTargetStatus {
  final int baseScore; // 0 to 100
  final int totalScoreWithPriority; // Affects sorting weight
  final int priorityLevel; // 1-3
  final int daysOverdue; // Positive means overdue, negative means safe
  final String statusEmoji; // 🟢, 🟡, 🔴
  final double progressPercent; // 0.0 to 1.0 (1.0 = perfect health)

  RelationshipTargetStatus({
    required this.baseScore,
    required this.totalScoreWithPriority,
    required this.priorityLevel,
    required this.daysOverdue,
    required this.statusEmoji,
    required this.progressPercent,
  });
}

@riverpod
HealthScoreEngine healthScoreEngine(Ref ref) {
  return HealthScoreEngine();
}

class HealthScoreEngine {
  /// Analyzes a relationship based on frequency logic
  RelationshipTargetStatus calculateHealth({
    required int targetFrequencyDays,
    required DateTime? lastInteractionDate,
    required int priorityLevel,
    required double? averageGapDays,
  }) {
    if (lastInteractionDate == null) {
      return RelationshipTargetStatus(
        baseScore: 0,
        totalScoreWithPriority: 0,
        priorityLevel: priorityLevel,
        daysOverdue: targetFrequencyDays,
        statusEmoji: '🔴',
        progressPercent: 0.0,
      );
    }

    final now = DateTime.now();
    final difference = now.difference(lastInteractionDate).inDays;
    final daysOverdue = difference - targetFrequencyDays;

    // 1. Frequency Score (50%)
    double fRatio = 1.0;
    if (daysOverdue > 0) {
      fRatio = 1.0 - (daysOverdue / targetFrequencyDays);
      if (fRatio < 0.0) fRatio = 0.0;
    }
    final frequencyScore = fRatio * 100.0;

    // 2. Consistency Score (30%)
    double consistencyScore = 50.0; // Default if < 2 interactions
    if (averageGapDays != null) {
      if (averageGapDays <= targetFrequencyDays) {
        consistencyScore = 100.0;
      } else {
        final excessGap = averageGapDays - targetFrequencyDays;
        final cRatio = 1.0 - (excessGap / targetFrequencyDays);
        consistencyScore = cRatio * 100.0;
        if (consistencyScore < 0.0) consistencyScore = 0.0;
      }
    }

    // 3. Priority Weight Score (20%)
    // Drops by specific % per overdue day based on priority (1=2%, 2=4%, 3=6%)
    double priorityScore = 100.0;
    if (daysOverdue > 0) {
      final dropPerDay = priorityLevel * 2.0; // 1->2, 2->4, 3->6
      priorityScore = 100.0 - (daysOverdue * dropPerDay);
      if (priorityScore < 0.0) priorityScore = 0.0;
    }

    // Combine precise formula
    final rawBaseScore =
        (0.5 * frequencyScore) +
        (0.3 * consistencyScore) +
        (0.2 * priorityScore);

    int baseScore = rawBaseScore.toInt();
    if (baseScore > 100) baseScore = 100;
    if (baseScore < 0) baseScore = 0;

    // Keep totalScoreWithPriority for sorting identicals
    int totalScoreWithPriority = baseScore + (priorityLevel * 10);

    String statusEmoji = '🟢';
    if (baseScore < 40) {
      statusEmoji = '🔴';
    } else if (baseScore <= 69) {
      statusEmoji = '🟡';
    }

    return RelationshipTargetStatus(
      baseScore: baseScore,
      totalScoreWithPriority: totalScoreWithPriority,
      priorityLevel: priorityLevel,
      daysOverdue: daysOverdue > 0 ? daysOverdue : 0,
      statusEmoji: statusEmoji,
      progressPercent: baseScore / 100.0,
    );
  }
}
