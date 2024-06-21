import 'package:flutter/material.dart';

class DefaultPopUpButton<T> extends StatelessWidget {
  final void Function(T)? onSelected;
  final Widget? child;
  final List<PopupMenuEntry<T>> Function(BuildContext) itemBuilder;

  const DefaultPopUpButton({
    required this.itemBuilder,
    this.onSelected,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      onSelected: onSelected,
      itemBuilder: itemBuilder,
      child: child,
    );
  }
}
