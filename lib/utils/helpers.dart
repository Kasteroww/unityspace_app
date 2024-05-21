import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:string_validator/string_validator.dart';
import 'package:unityspace/utils/errors.dart';
import 'package:unityspace/utils/http_plugin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unityspace/utils/logger_plugin.dart';

String? makeAvatarUrl(final String? avatar) {
  return avatar != null
      ? '${HttpPlugin.baseURL}/v2/files/avatar/$avatar'
      : null;
}

String? getNullStringIfEmpty(final String? str) {
  return str == null || str.isEmpty ? null : str;
}

double makeOrderFromInt(final int order) {
  return order / 1000000.0;
}

int makeIntFromOrder(final double order) {
  return (order * 1000000).toInt();
}

bool isLinkValid(final String url) {
  return isURL(url, {
    'protocols': ['http', 'https'],
    'require_protocol': true
  });
}

Duration getDifference(DateTime dateTime) {
  return DateTime.now().difference(dateTime);
}

String timeAgo({
  required String date,
  required AppLocalizations localizations,
}) {
  DateTime dateTime = dateFromDateString(date);
  Duration diff = getDifference(dateTime);

  if (diff.inDays >= 365) {
    final years = (diff.inDays / 365).floor();
    return localizations.yearsAgo(years, years);
  } else if (diff.inDays >= 30) {
    final months = (diff.inDays / 30).floor();
    return localizations.monthsAgo(months, months);
  } else if (diff.inDays >= 7) {
    final weeks = (diff.inDays / 7).floor();
    return localizations.weeksAgo(weeks, weeks);
  } else if (diff.inDays >= 2) {
    final days = diff.inDays.toInt();
    return localizations.daysAgo(days, days);
  } else if (diff.inDays >= 1) {
    return localizations.yesterday;
  } else {
    return localizations.today;
  }
}

DateTime dateFromDateString(String date) {
  final dateString = date.split('T')[0];
  final dateList = dateString.split('-');
  return DateTime(
    int.parse(dateList[0]),
    int.parse(dateList[1]),
    int.parse(dateList[2]),
  );
}

String timeFromDateString(String date) {
  final timeString = date.split('T')[1];
  final timeList = timeString.split(':');
  return '${timeList[0].padLeft(2, '0')}:${timeList[1].padRight(2, '0')}';
}

String formatDateEEEEdMMMM(
    {required String dateString, required String locale}) {
  DateTime date = DateTime.parse(dateString);
  DateFormat formatter = DateFormat('EEEE, d MMMM', locale);
  String formattedDate = formatter.format(date);
  Duration diff = getDifference(date);
  String formattedDateCapitalized = formattedDate.capitalizeWords();
  if (diff.inDays == 1) {
    return 'Вчера, $formattedDateCapitalized';
  } else if (diff.inDays == 0) {
    return 'Сегодня, $formattedDateCapitalized';
  } else {
    return formattedDateCapitalized;
  }
}

String formatDateddMMyyyy(
    {required String dateString, required String locale}) {
  DateTime date = DateTime.parse(dateString);
  return DateFormat('dd.MM.yyyy', locale).format(date);
}

extension StringExtension on String {
  String capitalizeWords() {
    List<String> words = split(' ');

    return words
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color? fromHex(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } on Exception catch (e) {
      if (e is FormatException) {
        logger.e(FormatErrors.incorrectColorFormat);
        logger.e('string: $hexString');
        throw FormatErrors.incorrectColorFormat;
      }
      return null;
    }
  }

  /// Prefixes a hash sign if [hasLeadingHash] is set to `true` (default is `true`).
  String toHex({bool hasLeadingHash = true}) => '${hasLeadingHash ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
