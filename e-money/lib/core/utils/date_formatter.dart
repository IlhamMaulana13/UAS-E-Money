import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);

    final timeStr = DateFormat('HH.mm').format(dt);
    if (date == today) return 'Hari ini, $timeStr';
    if (date == yesterday) return 'Kemarin, $timeStr';
    return '${DateFormat('d MMM', 'id_ID').format(dt)}, $timeStr';
  }

  static String formatShort(DateTime dt) {
    return DateFormat('d MMM yyyy', 'id_ID').format(dt);
  }
}
