import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date, {String pattern = 'dd/MM/yyyy'}) {
    try {
      return DateFormat(pattern).format(date);
    } catch (_) {
      return date.toIso8601String();
    }
  }

  static String formatDateTime(DateTime dateTime, {String pattern = 'dd/MM/yyyy HH:mm'}) {
    try {
      return DateFormat(pattern).format(dateTime);
    } catch (_) {
      return dateTime.toIso8601String();
    }
  }
}



