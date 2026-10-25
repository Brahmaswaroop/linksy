import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/core/engine/health_score_engine.dart';

void main() {
  group('HealthScoreEngine', () {
    late HealthScoreEngine engine;

    setUp(() {
      engine = HealthScoreEngine();
    });

    test('calculateHealth returns 0% when overdue >= 2 * targetFrequencyDays', () {
      final now = DateTime.now();
      
      // Target frequency is 30 days
      final targetFrequencyDays = 30;
      
      // Last interaction was 60 days ago (2 * targetFrequencyDays)
      final lastInteractionDate = now.subtract(const Duration(days: 60));
      
      final status = engine.calculateHealth(
        targetFrequencyDays: targetFrequencyDays,
        lastInteractionDate: lastInteractionDate,
        priorityLevel: 2,
        averageGapDays: 15.0,
        createdAt: now.subtract(const Duration(days: 100)),
      );

      expect(status.baseScore, 0);
      expect(status.statusEmoji, '🔴');
    });
    
    test('calculateHealth applies decay to consistency score', () {
      final now = DateTime.now();
      
      final targetFrequencyDays = 30;
      
      // Last interaction was 45 days ago (1.5 * targetFrequencyDays)
      final lastInteractionDate = now.subtract(const Duration(days: 45));
      
      final status = engine.calculateHealth(
        targetFrequencyDays: targetFrequencyDays,
        lastInteractionDate: lastInteractionDate,
        priorityLevel: 2,
        averageGapDays: 15.0,
        createdAt: now.subtract(const Duration(days: 100)),
      );

      // We expect the score to be:
      // frequency = 100 * (1 - 15/30) = 50. Weighted: 25.
      // consistency = 100 * (1 - 15/30) = 50. Weighted: 15.
      // priority = 100 - (15 * 4) = 40. Weighted: 8.
      // Total = 25 + 15 + 8 = 48
      expect(status.baseScore, 48);
    });

    test('calculateHealth returns perfect score when not overdue and good consistency', () {
      final now = DateTime.now();
      
      final targetFrequencyDays = 30;
      
      final lastInteractionDate = now;
      
      final status = engine.calculateHealth(
        targetFrequencyDays: targetFrequencyDays,
        lastInteractionDate: lastInteractionDate,
        priorityLevel: 2,
        averageGapDays: 20.0,
        createdAt: now.subtract(const Duration(days: 100)),
      );

      expect(status.baseScore, 100);
      expect(status.statusEmoji, '🟢');
    });
  });
}
