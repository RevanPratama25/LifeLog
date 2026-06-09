/// Centralized date formatting utilities used across modules.
///
/// Replaces duplicated formatting methods that existed in
/// `reflections_view`, `timeline_view`, and `home_view`.
class DateFormatters {
  DateFormatters._();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Formats a date as "24 Apr 2026".
  ///
  /// Used by Reflections for quote card timestamps.
  static String formatShortDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  /// Formats a date into a section header: "TODAY", "YESTERDAY", or "24 Apr 2026".
  ///
  /// Used by Timeline for date group headers.
  static String formatDateHeader(DateTime? date) {
    if (date == null) return 'Unknown';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) return 'TODAY';
    if (targetDate == yesterday) return 'YESTERDAY';

    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  /// Formats a deadline relative to today: "Today", "Tomorrow", or "24 Apr".
  ///
  /// Used by Home for upcoming deadline cards.
  static String formatDeadline(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDate = DateTime(date.year, date.month, date.day);
    final difference = deadlineDate.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';

    return '${date.day} ${_months[date.month - 1]}';
  }

  /// Returns `true` if two dates fall on the same calendar day.
  ///
  /// Used by Timeline for date grouping logic.
  static bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
