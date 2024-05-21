import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unityspace/screens/widgets/common/paddings.dart';
import 'package:unityspace/utils/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.actions,
    required this.titleText,
  });

  final String titleText;

  final List<Widget>? actions;

  final double _height = 55;

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(_height),
      child: PaddingTop(
        22,
        child: AppBar(
          title: Text(titleText),
          leading: GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: SvgPicture.asset(
              ConstantIcons.menu,
              width: 20,
              height: 20,
              theme: const SvgTheme(currentColor: Color(0xFF4D4D4D)),
            ),
          ),
          centerTitle: true,
          toolbarHeight: 23,
          actions: actions,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(_height);
}
