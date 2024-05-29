import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({
    super.key,
    this.height = double.infinity,
    this.width = double.infinity,
    this.radius = 6,
    this.color = Colors.white,
    this.borderColor = Colors.greenAccent,
    this.hasBorder = false,
    this.child,
    this.paddingTop = 12,
    this.paddingLeft = 12,
    this.paddingRight = 12,
    this.paddingBottom = 12,
  });

  final double height;
  final double width;
  final double paddingTop;
  final double paddingLeft;
  final double paddingRight;
  final double paddingBottom;
  final double radius;
  final Color color;
  final Color borderColor;
  final bool hasBorder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.only(
        top: paddingTop,
        left: paddingLeft,
        right: paddingRight,
        bottom: paddingBottom,
      ),
      decoration: BoxDecoration(
        color: color,
        border: hasBorder
            ? Border.all(
                color: borderColor,
              )
            : null,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      child: child,
    );
  }
}
