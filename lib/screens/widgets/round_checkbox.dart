import 'package:flutter/material.dart';

class RoundCheckbox extends StatelessWidget {
  final double size;
  final bool isChecked;
  const RoundCheckbox({
    required this.size,
    required this.isChecked,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isChecked ? Colors.green : const Color.fromARGB(255, 230, 230, 230),
      ),
      width: size,
      height: size,
      child: isChecked
          ? const Icon(
              Icons.check,
              color: Colors.black,
              size: 24,
            )
          : null,
    );
  }
}
