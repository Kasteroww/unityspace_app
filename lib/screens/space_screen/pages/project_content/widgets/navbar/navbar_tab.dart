import 'package:flutter/material.dart';
import 'package:unityspace/screens/widgets/tabs_list/tab_button.dart';

class NavbarTab extends StatelessWidget {
  const NavbarTab({
    required this.onPressed,
    required this.title,
    required this.selected,
    this.onLongPress,
    super.key,
  });

  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final String title;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TabButton(
        title: title,
        onPressed: onPressed,
        onLongPress: onLongPress,
        selected: selected,
      ),
    );
  }
}

enum PopupItemActionTypes { edit, copyLink, delete, hide }
