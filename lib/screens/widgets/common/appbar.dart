import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unityspace/screens/account_screen/account_screen.dart';
import 'package:unityspace/screens/widgets/common/paddings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unityspace/utils/constants.dart';

PreferredSizeWidget getCustomAppBar(
    {required AppLocalizations localization,
    required AccountScreenStore store}) {
  return CustomAppBar(
    localization: localization,
  );
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.localization,
    this.actions,
  });

  final AppLocalizations localization;

  final List<Widget>? actions;

  final double _height = 45;

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(_height),
      child: PaddingTop(
        22,
        child: AppBar(
          title: Text(localization.my_profile),
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
