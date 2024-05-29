import 'package:flutter/material.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/utils/localization_helper.dart';

/// Диалог при достижении лимита добавления пространств
///
/// @param showTrialButton - показывать ли кнопку попробовать бесплатно
///
/// Возвращает:
/// 'goto_pay' - если нажали обновить тариф
/// или
/// 'start_trial' - если нажали попробовать бесплатно
Future<String?> showAddSpaceLimitDialog(
  BuildContext context, {
  required final bool showTrialButton,
}) async {
  return showDialog<String?>(
    context: context,
    builder: (context) {
      return AddSpaceLimitDialog(showTrialButton: showTrialButton);
    },
  );
}

class AddSpaceLimitDialog extends StatelessWidget {
  final bool showTrialButton;

  const AddSpaceLimitDialog({
    required this.showTrialButton,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return AppDialogWithButtons(
      title: localization.you_found_a_paid_feature,
      primaryButtonText: localization.update,
      onPrimaryButtonPressed: () {
        Navigator.of(context).pop('goto_pay');
      },
      secondaryButtonText: showTrialButton ? localization.try_free : '',
      onSecondaryButtonPressed: () {
        Navigator.of(context).pop('start_trial');
      },
      children: [
        Text(
          localization.update_your_tariff_plan,
        ),
      ],
    );
  }
}
