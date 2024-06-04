import 'package:flutter/material.dart';
import 'package:unityspace/resources/theme/theme.dart';

class SmallCloseIcon extends StatelessWidget {
  const SmallCloseIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.close,
      size: 12,
      color: ColorConstants.grey04,
    );
  }
}
