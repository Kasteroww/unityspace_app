import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainFormSignInButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool loading;
  final double width;
  final Color colorBackground;
  final Color colorText;
  final String iconAssetName;

  const MainFormSignInButtonWidget({
    required this.onPressed,
    required this.text,
    required this.loading,
    required this.iconAssetName,
    super.key,
    this.width = double.infinity,
    this.colorBackground = Colors.white,
    this.colorText = const Color(0xFF111012),
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      minWidth: width,
      height: 40,
      elevation: 2,
      color: colorBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      onPressed: loading ? null : onPressed,
      child: loading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: colorBackground,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  iconAssetName,
                  width: 20,
                  height: 20,
                  fit: BoxFit.scaleDown,
                ),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: TextStyle(
                    color: colorText,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
    );
  }
}
