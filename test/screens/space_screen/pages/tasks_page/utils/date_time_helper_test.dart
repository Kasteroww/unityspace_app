import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/utils/date_time_helper.dart';

void main() {
  group('isPastDeadline', () {
    test('should return true if the endDate is earlier than today', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final todayAtMidnight = DateTime(today.year, today.month, today.day);
      expect(TasksListDateTimeHelper.isPastDeadline(yesterday), isTrue);
      expect(TasksListDateTimeHelper.isPastDeadline(todayAtMidnight), isTrue);
    });

    test('should return false if the endDate is tomorrow or later', () {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      final dayAfterTomorrow = today.add(const Duration(days: 2));

      expect(TasksListDateTimeHelper.isPastDeadline(tomorrow), isFalse);
      expect(TasksListDateTimeHelper.isPastDeadline(dayAfterTomorrow), isFalse);
    });

    test('should return true if the endDate is at the same moment as today',
        () {
      final today = DateTime.now();
      expect(TasksListDateTimeHelper.isPastDeadline(today), isTrue);
    });

    test('should return true if the endDate is one second before today', () {
      final today = DateTime.now();
      final oneSecondBeforeToday = today.subtract(const Duration(seconds: 1));
      expect(
        TasksListDateTimeHelper.isPastDeadline(oneSecondBeforeToday),
        isTrue,
      );
    });
  });

  group('getFormattedEndDate', () {
    test('returns formatted end date for ru locale', () {
      initializeDateFormatting('ru');
      final endDate = DateTime(2024, 6, 4);
      final formattedEndDate = TasksListDateTimeHelper.getFormattedEndDate(
        endDate: endDate,
        locale: 'ru',
      );
      expect(formattedEndDate, '4 июн.');
    });

    test('returns formatted end date for en_US locale', () {
      initializeDateFormatting('en_US');
      final endDate = DateTime(2024, 6, 4);
      final formattedEndDate = TasksListDateTimeHelper.getFormattedEndDate(
        endDate: endDate,
        locale: 'en_US',
      );
      expect(formattedEndDate, '4 Jun');
    });
  });
}
