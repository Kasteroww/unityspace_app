import 'package:flutter/material.dart';

class AppBottomSheet {
  static void show(
    BuildContext context, {
    required Widget Function(BuildContext context) builder,
    bool isScrollControlled = true,
    Color barrierColor = Colors.black54,
    Color backgroundColor = Colors.white,
    bool useSafeArea = true,
  }) {
    showModalBottomSheet(
      useSafeArea: useSafeArea,
      isScrollControlled: isScrollControlled,
      barrierColor: barrierColor,
      backgroundColor: backgroundColor,
      context: context,
      builder: builder,
    );
  }
}