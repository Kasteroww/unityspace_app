import 'package:flutter/material.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/utils/logger_plugin.dart';

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
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
