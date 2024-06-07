import 'package:flutter/material.dart';

class ContextMenuItem extends StatelessWidget {
  const ContextMenuItem({
    required this.text,
    super.key,
    this.color = const Color.fromRGBO(77, 77, 77, 1),
  });

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 16.41 / 14,
        color: color,
      ),
    );
  }
}
