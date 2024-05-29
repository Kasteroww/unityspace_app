import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

Logger logger = Logger(
  printer: PrettyPrinter(printTime: true),
);

void debugLog(Object? o) {
  assert(() {
    if (kDebugMode) print(o);
    return true;
  }());
}
