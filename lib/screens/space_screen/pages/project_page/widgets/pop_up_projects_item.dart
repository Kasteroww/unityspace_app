import 'package:flutter/material.dart';

class PopupProjectsItem extends StatelessWidget {
  const PopupProjectsItem({
    required this.text,
    super.key,
    this.color = const Color.fromRGBO(77, 77, 77, 1),
  });

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          height: 16,
          width: 16,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 16.41 / 14,
            color: color,
          ),
        ),
      ],
    );
  }
}
