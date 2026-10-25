import 'package:flutter_test/flutter_test.dart';
import 'package:linksy/core/services/call_log_sync_service.dart';

void main() {
  group('CallLogSyncService.numbersMatch', () {
    test('matches identical formatted numbers', () {
      expect(
        CallLogSyncService.numbersMatch('+1 555-123-4567', '+1 555-123-4567'),
        isTrue,
      );
    });

    test('matches international and local number formats', () {
      // Local US: (555) 123-4567 vs International: +1 555-123-4567
      expect(
        CallLogSyncService.numbersMatch('(555) 123-4567', '+15551234567'),
        isTrue,
      );
      // Clean digits vs dashed
      expect(
        CallLogSyncService.numbersMatch('9876543210', '+91 98765-43210'),
        isTrue,
      );
    });

    test('does not match different phone numbers', () {
      expect(
        CallLogSyncService.numbersMatch('555-123-4567', '555-987-6543'),
        isFalse,
      );
    });

    test('returns false for empty or non-numeric strings', () {
      expect(CallLogSyncService.numbersMatch('', '12345678'), isFalse);
      expect(CallLogSyncService.numbersMatch('abc', 'def'), isFalse);
    });
  });
}
