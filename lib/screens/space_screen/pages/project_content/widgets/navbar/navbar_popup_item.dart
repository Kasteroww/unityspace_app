import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavbarPopupItem extends StatelessWidget {
  const NavbarPopupItem({
    required this.text,
    super.key,
    this.icon,
  });

  final String text;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null && icon!.isNotEmpty)
          SvgPicture.asset(
            width: 32,
            height: 32,
            fit: BoxFit.scaleDown,
            icon!,
          ),
        const SizedBox(
          height: 16,
          width: 16,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 16.41 / 14,
          ),
        ),
      ],
    );
  }
}
