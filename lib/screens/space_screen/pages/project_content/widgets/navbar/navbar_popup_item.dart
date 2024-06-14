import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/resources/theme/theme.dart';

class NavbarPopupItem extends StatelessWidget {
  const NavbarPopupItem({
    required this.text,
    super.key,
    this.icon,
    this.color = ColorConstants.grey03,
  });

  final String text;
  final Color? color;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          if (icon != null) ...[
            SvgPicture.asset(
              width: 24,
              height: 24,
              fit: BoxFit.scaleDown,
              icon!,
            ),
            const SizedBox(width: 12),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 16.41 / 14,
            ),
          ),
        ],
      ),
    );
  }
}
