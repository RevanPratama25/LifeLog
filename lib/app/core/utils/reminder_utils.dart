/// Calculates the scheduled reminder time based on a deadline and an offset key.
///
/// This was previously duplicated in both [NotificationService] and
/// [BaseController]. Now centralized here for DRY compliance.
DateTime calculateReminderTime(DateTime deadline, String offset) {
  switch (offset) {
    case 'at_deadline':
      return deadline;
    case '30_min':
      return deadline.subtract(const Duration(minutes: 30));
    case '1_hour':
      return deadline.subtract(const Duration(hours: 1));
    case '3_hours':
      return deadline.subtract(const Duration(hours: 3));
    case '5_hours':
      return deadline.subtract(const Duration(hours: 5));
    case '12_hours':
      return deadline.subtract(const Duration(hours: 12));
    case '1_day':
      return deadline.subtract(const Duration(days: 1));
    case '3_days':
      return deadline.subtract(const Duration(days: 3));
    case '7_days':
      return deadline.subtract(const Duration(days: 7));
    default:
      return deadline;
  }
}
