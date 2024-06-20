import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unityspace/resources/app_icons.dart';

class NavigatorMenuItem extends StatelessWidget {
  final String title;
  final bool selected;
  final bool favorite;
  final String iconAssetName;
  final VoidCallback onTap;

  const NavigatorMenuItem({
    required this.title,
    required this.selected,
    required this.iconAssetName,
    required this.onTap,
    required this.favorite,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      horizontalTitleGap: 8,
      selected: selected,
      selectedTileColor: const Color(0xFF0D362D),
      leading: SvgPicture.asset(
        iconAssetName,
        width: 32,
        height: 32,
        fit: BoxFit.scaleDown,
        theme: SvgTheme(
          currentColor: selected ? Colors.white : const Color(0xFF908F90),
        ),
      ),
      trailing: favorite
          ? SvgPicture.asset(
              AppIcons.navigatorFavorite,
              width: 12,
              height: 12,
              fit: BoxFit.scaleDown,
            )
          : null,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xE6FFFFFF),
          fontSize: 18,
        ),
      ),
    );
  }
}
