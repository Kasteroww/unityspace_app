import 'package:unityspace/utils/helpers.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

/// Миксин, который позволяет избежать дублирования кода при копировании
/// определенных данных пользователем в буфер обмена
mixin CopyToClipboardMixin on WStore {
  String get message;

  set message(String value);

  void copy({
    required String text,
    required String successMessage,
    required String errorMessage,
  }) {
    listenFuture(
      copyToClipboard(text),
      id: 1,
      onData: (_) {
        setStore(() {
          message = successMessage;
        });
      },
      onError: (error, stack) {
        logger.e('copyToClipboard error', error: error, stackTrace: stack);
        setStore(() {
          message = errorMessage;
        });
      },
    );
  }
}
