import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PopupMenuItemChild extends StatelessWidget {
  final String? iconPath;
  final String text;
  final Color? color;
  const PopupMenuItemChild({
    required this.text,
    this.iconPath,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (iconPath != null)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              height: 16,
              width: 16,
              child: SvgPicture.asset(iconPath!),
            ),
          ),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 16.41 / 14,
            color: color ?? const Color.fromRGBO(77, 77, 77, 1),
          ),
        ),
      ],
    );
  }
}
