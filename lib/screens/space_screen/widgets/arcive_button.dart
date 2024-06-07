import 'package:flutter/material.dart';

class ArchiveButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const ArchiveButton({
    required this.text,
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.only(top: 4, right: 20),
        child: InkWell(
          onTap: onTap,
          child: Text(
            text,
          ),
        ),
      ),
    );
  }
}
