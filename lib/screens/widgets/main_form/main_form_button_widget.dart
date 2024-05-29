import 'package:flutter/material.dart';
import 'package:unityspace/screens/widgets/color_button_widget.dart';

class MainFormButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool loading;

  const MainFormButtonWidget({
    required this.onPressed,
    required this.text,
    super.key,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ColorButtonWidget(
      width: double.infinity,
      onPressed: onPressed,
      text: text,
      loading: loading,
      colorBackground: Colors.white,
      colorText: const Color(0xFF111012),
    );
  }
}
