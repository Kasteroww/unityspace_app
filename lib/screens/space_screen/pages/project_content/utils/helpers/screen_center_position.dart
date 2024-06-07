import 'package:flutter/material.dart';

RelativeRect getCenterScreenPosition(Size size) {
  final center = Offset(size.width / 2, size.height / 2);
  final position = RelativeRect.fromSize(
    Rect.fromCenter(center: center, width: 100, height: 100),
    size,
  );
  return position;
}
