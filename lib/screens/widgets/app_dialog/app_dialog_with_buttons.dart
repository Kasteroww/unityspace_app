import 'package:flutter/material.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_primary_button.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_secondary_button.dart';

class AppDialogWithButtons extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final String primaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;
  final bool primaryButtonLoading;
  final String secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;
  final bool secondaryButtonLoading;

  const AppDialogWithButtons({
    required this.title,
    required this.children,
    required this.primaryButtonText,
    required this.secondaryButtonText,
    super.key,
    this.onPrimaryButtonPressed,
    this.primaryButtonLoading = false,
    this.onSecondaryButtonPressed,
    this.secondaryButtonLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: title,
      buttons: [
        if (primaryButtonText.isNotEmpty)
          AppDialogPrimaryButton(
            onPressed: onPrimaryButtonPressed,
            text: primaryButtonText,
            loading: primaryButtonLoading,
          ),
        if (secondaryButtonText.isNotEmpty && primaryButtonText.isNotEmpty)
          const SizedBox(height: 8),
        if (secondaryButtonText.isNotEmpty)
          AppDialogSecondaryButton(
            onPressed: onSecondaryButtonPressed,
            text: secondaryButtonText,
            loading: secondaryButtonLoading,
          ),
      ],
      children: children,
    );
  }
}
