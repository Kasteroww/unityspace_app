import 'package:flutter/material.dart';

class ColorButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool loading;
  final double width;
  final Color colorBackground;
  final Color colorText;
  final double elevation;

  const ColorButtonWidget({
    required this.onPressed,
    required this.text,
    required this.loading,
    required this.width,
    required this.colorBackground,
    required this.colorText,
    super.key,
    this.elevation = 2,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      minWidth: width,
      height: 40,
      elevation: elevation,
      color: colorBackground,
      disabledColor: loading ? null : colorBackground.withOpacity(0.5),
      onPressed: loading ? null : onPressed,
      child: loading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: colorBackground,
              ),
            )
          : Text(
              text,
              style: TextStyle(
                color: colorText,
                fontSize: 16,
              ),
            ),
    );
  }
}
