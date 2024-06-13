import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  final String? url;
  const BackgroundImage({required this.url, super.key});

  @override
  Widget build(BuildContext context) {
    if (url != null) {
      return Image.network(
        url!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
