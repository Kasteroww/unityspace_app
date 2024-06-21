import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SvgIcon extends StatelessWidget {
  const SvgIcon({
    required this.icon,
    this.width,
    this.height,
    this.color,
    super.key,
  });

  final String icon;
  final double? width;
  final double? height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon,
      width: width,
      height: height,
      fit: BoxFit.scaleDown,
      colorFilter: color != null
          ? ColorFilter.mode(
              color!,
              BlendMode.srcIn,
            )
          : null,
    );
  }
}
