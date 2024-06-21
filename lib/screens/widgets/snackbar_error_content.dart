import 'package:flutter/material.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/resources/l10n/app_localizations.dart';
import 'package:unityspace/utils/localization_helper.dart';

class SnackBarErrorContent extends StatelessWidget {
  final void Function()? onTap;
  final LoginErrors errorType;
  final String errorMessage;
  const SnackBarErrorContent({
    required this.errorType,
    required this.errorMessage,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final copyErrorMessage = _getLocalizedErrorMessage(
      errorType: errorType,
      localization: localization,
      errorMessage: errorMessage,
    );
    return Row(
      children: [
        Expanded(
          child: Text(
            '$copyErrorMessage\n',
          ),
        ),
        if (isNeedShowCopyButton(errorType: errorType))
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: InkWell(
              onTap: onTap,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    localization.copy,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool isNeedShowCopyButton({
    required LoginErrors errorType,
  }) {
    switch (errorType) {
      case LoginErrors.invalidEmailOrPassword:
        return false;
      default:
        return true;
    }
  }

  String _getLocalizedErrorMessage({
    required LoginErrors errorType,
    required AppLocalizations localization,
    required String errorMessage,
  }) {
    switch (errorType) {
      // Если какая то ошибка связанная с входом,
      // то выводится и ссобщение и локализованное обозначение проблемы
      case LoginErrors.loginError:
        return '${localization.login_error} \n$errorMessage';
      // Если неправильный логин и пароль,
      // то выводится только локализованное сообщение
      case LoginErrors.invalidEmailOrPassword:
        return localization.invalid_email_or_password;
      default:
        // Если выводится неизвестная ошибка, то выводится только errorMessage
        return errorMessage;
    }
  }
}
