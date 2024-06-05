import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:string_validator/string_validator.dart';
import 'package:unityspace/models/model_interfaces.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/utils/http_plugin.dart';
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
    'require_protocol': true,
  });
}

Duration getDifference(DateTime dateTime) {
  return DateTime.now().difference(dateTime);
}

DateTime dateFromDateTime(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String timeFromDateString(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padRight(2, '0')}';
}

String formatDateddMMyyyy({required DateTime date, required String locale}) {
  return DateFormat('dd.MM.yyyy', locale).format(date);
}

extension StringExtension on String {
  String capitalizeWords() {
    final List<String> words = split(' ');

    return words
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}

/// Дженерик для конвертации Identifiable в мапу
/// Map <int, Identifiable>, где int - это id каждого элемента
Map<int, T> createMapById<T extends Identifiable>(List<T>? list) {
  if (list == null || list.isEmpty) {
    return {};
  }
  return list.fold<Map<int, T>>({}, (acc, item) {
    acc[item.id] = item;
    return acc;
  });
}

/// дженерик для получения значения enum по параметру
/// можно использовать если enum имплеменирует интерфейс
/// [EnumWithValue]
/// принимает value (параметр) и список значений enum
/// значения можно получть по EnumName.values
/// если подходящее значение не найдено,
/// возвращает первое из списка enumValues и пишет
/// ошибку в лог
T getEnumValue<T extends EnumWithValue>(
  Object value, {
  required List<T> enumValues,
}) {
  return enumValues.firstWhere(
    (e) => e.value == value,
    orElse: () {
      logger.e('Invalid enum value: $value');
      return enumValues.first;
    },
  );
}

Future<void> copyToClipboard(final String text) async {
  if (text.isEmpty) throw TextErrors.textIsEmpty;
  final data = ClipboardData(text: text);
  await Clipboard.setData(data);
}
