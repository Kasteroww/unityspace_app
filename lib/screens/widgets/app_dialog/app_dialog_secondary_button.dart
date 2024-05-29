import 'package:flutter/material.dart';
import 'package:unityspace/screens/widgets/color_button_widget.dart';

class AppDialogSecondaryButton extends StatelessWidget {
  const AppDialogSecondaryButton({
    required this.onPressed,
    required this.text,
    required this.loading,
    super.key,
  });

  final VoidCallback? onPressed;
  final String text;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ColorButtonWidget(
      width: double.infinity,
      elevation: 1,
      onPressed: () {
        onPressed?.call();
      },
      text: text,
      loading: loading,
      colorBackground: const Color(0xFFF1F1F1),
      colorText: Colors.black,
    );
  }
}
