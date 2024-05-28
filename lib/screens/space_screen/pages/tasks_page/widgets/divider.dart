import 'package:flutter/material.dart';

class DividerWithoutPadding extends StatelessWidget {
  const DividerWithoutPadding({
    super.key,
    this.color = Colors.black,
    this.thickness = 1,
    this.isHorisontal = true,
  });

  final Color color;
  final double thickness;
  final bool isHorisontal;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isHorisontal ? 0 : double.infinity,
      width: isHorisontal ? double.infinity : 0,
      decoration: BoxDecoration(
          border: Border(
              left: isHorisontal
                  ? BorderSide.none
                  : BorderSide(
                      color: color,
                      width: thickness,
                    ),
              top: isHorisontal
                  ? BorderSide(color: color, width: thickness)
                  : BorderSide.none)),
    );
  }
}
