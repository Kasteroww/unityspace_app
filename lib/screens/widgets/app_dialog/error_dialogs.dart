import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unityspace/main.dart';
import 'package:unityspace/utils/localization_helper.dart';

void show403ErrorDialog({required BuildContext context}) {
  final localization = LocalizationHelper.getLocalizations(context);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(localization.access_denied),
        content: Text(
          localization.access_denied_please_contact_support,
        ),
        actions: [
          TextButton(
            child: Text(localization.ok_dialog_button),
            onPressed: () {
              Navigator.of(context).pop();
              if (kReleaseMode) exit(1);
            },
          ),
        ],
      );
    },
  );
}

void showErrorDialog({
  required BuildContext context,
  String? title,
  String? message,
  String? closeButtonText,
  Function()? onPressed,
}) {
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (context) {
      return AlertDialog(
        title: Text(title ?? 'Error'),
        content: Text(message ?? 'An error occurred'),
        actions: [
          TextButton(
            onPressed: onPressed ??
                () {
                  Navigator.of(context).pop();
                },
            child: Text(closeButtonText ?? 'OK'),
          ),
        ],
      );
    },
  );
}
