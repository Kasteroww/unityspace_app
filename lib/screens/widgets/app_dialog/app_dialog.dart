import 'package:flutter/material.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final List<Widget> buttons;

  const AppDialog({
    required this.title,
    required this.children,
    required this.buttons,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: Color(0xFF212022), width: 2),
      ),
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...children,
          if (buttons.isNotEmpty) const SizedBox(height: 24),
          ...buttons,
        ],
      ),
    );
  }
}
