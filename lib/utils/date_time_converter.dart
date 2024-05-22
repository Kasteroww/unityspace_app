import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:unityspace/utils/helpers.dart';

class DateTimeConverter {
  const DateTimeConverter();

  static DateTime convertStringToDateTime(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      // Обработка ошибок, если строка не может быть разобрана
      throw FormatException("Invalid date format: $dateString");
    }
  }

  /// Отображение в виде формата HHmm, например: 17:43
  static String formatTimeHHmm(DateTime dateTime) {
    final DateFormat formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }

  ///Отображение времени в виде формата EEEEdMMMM, например:
  ///
  ///Если сегодня: сегодня, вторник, 21 мая
  ///
  ///Если вчера: вчера, понедельник, 20 мая
  ///
  ///Если более 2х дней назад: пятница, 17 мая
  static String formatDateEEEEdMMMM({
    required DateTime date,
    required AppLocalizations localizations,
    required String locale,
  }) {
    DateFormat formatter = DateFormat('EEEE d MMMM', locale);
    String formattedDate = formatter.format(date);
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));
    DateTime dateWithoutTime = DateTime(date.year, date.month, date.day);
    String formattedDateCapitalized = formattedDate.capitalizeWords();

    if (dateWithoutTime == yesterday) {
      return '${localizations.yesterday}, $formattedDateCapitalized';
    } else if (dateWithoutTime == today) {
      return '${localizations.today}, $formattedDateCapitalized';
    } else {
      return formattedDateCapitalized;
    }
  }
}
