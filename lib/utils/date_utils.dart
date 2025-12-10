import 'package:intl/intl.dart';

/// Utility class for date formatting throughout the app
class AppDateUtils {
  /// Format date to display format based on locale
  /// Example: "15 tháng 11, 2025" (Vietnamese) or "November 15, 2025" (English)
  static String formatDate(String? isoDate, {String locale = 'vi'}) {
    if (isoDate == null || isoDate.isEmpty) {
      return '';
    }

    try {
      final DateTime dateTime = DateTime.parse(isoDate);
      final DateFormat formatter = DateFormat.yMMMMd(locale);
      return formatter.format(dateTime);
    } catch (e) {
      // If parsing fails, return original string
      return isoDate;
    }
  }

  /// Format date with time
  /// Example: "15 tháng 11, 2025 lúc 14:30"
  static String formatDateTime(String? isoDate, {String locale = 'vi'}) {
    if (isoDate == null || isoDate.isEmpty) {
      return '';
    }

    try {
      final DateTime dateTime = DateTime.parse(isoDate);
      final DateFormat dateFormatter = DateFormat.yMMMMd(locale);
      final DateFormat timeFormatter = DateFormat.Hm(locale);

      if (locale == 'vi') {
        return '${dateFormatter.format(dateTime)} lúc ${timeFormatter.format(dateTime)}';
      } else {
        return '${dateFormatter.format(dateTime)} at ${timeFormatter.format(dateTime)}';
      }
    } catch (e) {
      return isoDate;
    }
  }

  /// Format date in short format
  /// Example: "15/11/2025"
  static String formatDateShort(String? isoDate, {String locale = 'vi'}) {
    if (isoDate == null || isoDate.isEmpty) {
      return '';
    }

    try {
      final DateTime dateTime = DateTime.parse(isoDate);
      final DateFormat formatter = DateFormat.yMd(locale);
      return formatter.format(dateTime);
    } catch (e) {
      return isoDate;
    }
  }

  /// Format relative time (e.g., "2 giờ trước", "3 ngày trước")
  static String formatRelativeTime(String? isoDate, {String locale = 'vi'}) {
    if (isoDate == null || isoDate.isEmpty) {
      return '';
    }

    try {
      final DateTime dateTime = DateTime.parse(isoDate);
      final Duration difference = DateTime.now().difference(dateTime);

      if (difference.inMinutes < 1) {
        return locale == 'vi' ? 'Vừa xong' : 'Just now';
      } else if (difference.inMinutes < 60) {
        return locale == 'vi'
            ? '${difference.inMinutes} phút trước'
            : '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return locale == 'vi'
            ? '${difference.inHours} giờ trước'
            : '${difference.inHours} hours ago';
      } else if (difference.inDays < 7) {
        return locale == 'vi'
            ? '${difference.inDays} ngày trước'
            : '${difference.inDays} days ago';
      } else {
        // Fall back to regular date format for older dates
        return formatDate(isoDate, locale: locale);
      }
    } catch (e) {
      return isoDate;
    }
  }

  /// Get locale string from app locale
  static String getLocaleString(String? languageCode) {
    if (languageCode == 'vi') {
      return 'vi';
    } else if (languageCode == 'ja') {
      return 'ja';
    } else {
      return 'en';
    }
  }
}
