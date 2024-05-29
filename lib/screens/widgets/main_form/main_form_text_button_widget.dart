import 'package:flutter/material.dart';

class MainFormTextButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const MainFormTextButtonWidget({
    required this.onPressed,
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(40, 40)),
        overlayColor: WidgetStateProperty.all<Color>(Colors.white10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }
}
