import 'package:intl/intl.dart';
import 'package:unityspace/utils/helpers.dart';

class TasksListDateTimeHelper {
  static String getFormattedEndDate({
    required DateTime endDate,
    required String locale,
  }) {
    return DateFormat('d MMM', locale).format(endDate);
  }

  static bool isPastDeadline(DateTime endDate) {
    final deadline = dateFromDateTime(endDate);
    final today = DateTime.now();
    return deadline.isBefore(today) || deadline.isAtSameMomentAs(today);
  }
}
