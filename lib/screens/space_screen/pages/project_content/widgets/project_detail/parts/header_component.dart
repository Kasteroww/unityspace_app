import 'package:flutter/material.dart';

class HeaderComponent extends StatelessWidget {
  final void Function()? onCopyButtonTap;
  const HeaderComponent({
    required this.taskText,
    super.key,
    this.onCopyButtonTap,
  });

  final String taskText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black54,
            ),
            child: const Icon(
              Icons.close,
              color: Colors.white,
            ),
          ),
        ),
        Row(
          children: [
            InkWell(
              onTap: onCopyButtonTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    Text(
                      taskText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.copy,
                      size: 15,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.more_vert_rounded,
            ),
          ],
        ),
      ],
    );
  }
}
