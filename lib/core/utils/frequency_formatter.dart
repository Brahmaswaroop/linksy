String formatTargetFrequency(int days) {
  if (days == 1) return 'Daily';
  if (days == 7) return 'Weekly';
  if (days == 14) return 'Bi-weekly';
  if (days == 30 || days == 31) return 'Monthly';
  if (days == 90 || days == 91 || days == 92) return 'Quarterly';
  if (days == 365 || days == 366) return 'Yearly';

  if (days % 30 == 0) {
    return 'Every ${days ~/ 30} months';
  }
  if (days % 7 == 0) {
    return 'Every ${days ~/ 7} weeks';
  }
  return 'Every $days days';
}
