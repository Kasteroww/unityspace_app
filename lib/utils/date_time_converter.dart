import 'package:intl/intl.dart';
import 'package:unityspace/resources/l10n/app_localizations.dart';
import 'package:unityspace/utils/helpers.dart';

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

  ///Отображение времени в виде формата dMMMMHHmm, например:
  ///
  ///Если сегодня: сегодня 11:04
  ///
  ///Если вчера: вчера 12:32
  ///
  ///Если более 2х дней назад: 6 июня 6:42
  static String formatDateDMMMMHHmm({
    required DateTime date,
    required AppLocalizations localization,
  }) {
    final DateFormat formatter =
        DateFormat('d MMMM HH:mm', localization.localeName);
    final String formattedDate = formatter.format(date);
    final DateTime today = dateFromDateTime(DateTime.now());
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime dateWithoutTime = dateFromDateTime(date);
    final String formattedDateCapitalized = formattedDate.capitalizeWords();

    if (dateWithoutTime == yesterday) {
      return '${localization.yesterday} ${formatTimeHHmm(date)}';
    } else if (dateWithoutTime == today) {
      return '${localization.today} ${formatTimeHHmm(date)}';
    } else {
      return formattedDateCapitalized;
    }
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
