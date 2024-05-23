import 'package:flutter/material.dart';

class PopupProjectsItem extends StatelessWidget {
  const PopupProjectsItem({super.key, required this.text});

  final String text;

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
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 16.41 / 14,
              color: Color.fromRGBO(77, 77, 77, 1)),
        ),
      ],
    );
  }
}
