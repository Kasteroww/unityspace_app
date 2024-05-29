import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:unityspace/utils/extensions/string_extension.dart';

class DateTimeConverter {
  const DateTimeConverter();

  static DateTime convertStringToDateTime(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      // Обработка ошибок, если строка не может быть разобрана
      throw FormatException('Invalid date format: $dateString');
    }
  }

  /// Отображение в виде формата HHmm, например: 17:43
  static String formatTimeHHmm(DateTime dateTime) {
    final DateFormat formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }

  /// Использует convertToDateTime и конвертирует строку в локализованный
  /// DateTime
  static DateTime stringToLocalDateTime(String date) {
    return DateTimeConverter.convertStringToDateTime(date).toLocal();
  }

  ///Отображение времени в виде формата EEEEdMMMM, например:
  ///
  ///Если сегодня: сегодня, вторник 21 мая
  ///
  ///Если вчера: вчера, понедельник 20 мая
  ///
  ///Если более 2х дней назад: пятница, 17 мая
  static String formatDateEEEEdMMMM({
    required DateTime date,
    required AppLocalizations localization,
    required String locale,
  }) {
    final DateFormat formatter = DateFormat('EEEE d MMMM', locale);
    final String formattedDate = formatter.format(date);
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime dateWithoutTime = DateTime(date.year, date.month, date.day);
    final String formattedDateCapitalized = formattedDate.capitalizeWords();

    if (dateWithoutTime == yesterday) {
      return '${localization.yesterday}, $formattedDateCapitalized';
    } else if (dateWithoutTime == today) {
      return '${localization.today}, $formattedDateCapitalized';
    } else {
      return formattedDateCapitalized;
    }
  }
}
