import 'package:flutter/widgets.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog.dart';
import 'package:unityspace/utils/localization_helper.dart';

class UnknownErrorDialog extends StatelessWidget {
  const UnknownErrorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return AppDialog(
      title: localization.unknown_error_try_later,
      buttons: const [],
      children: const [],
    );
  }
}
