import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/resources/theme/theme.dart';

class NavigatorMenuItem extends StatelessWidget {
  final String title;
  final bool selected;
  final bool favorite;
  final String iconAssetName;
  final VoidCallback onTap;
  final bool isShowBadge;
  final Widget? badge;

  const NavigatorMenuItem({
    required this.title,
    required this.selected,
    required this.iconAssetName,
    required this.onTap,
    required this.favorite,
    this.isShowBadge = false,
    this.badge,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(),
      horizontalTitleGap: 8,
      selected: selected,
      selectedTileColor: const Color(0xFF0D362D),
      leading: SizedBox(
        width: 28,
        height: 28,
        child: Stack(
          children: [
            SvgPicture.asset(
              iconAssetName,
              width: 28,
              height: 28,
              fit: BoxFit.scaleDown,
              colorFilter: ColorFilter.mode(
                selected ? ColorConstants.grey09 : ColorConstants.grey05,
                BlendMode.srcIn,
              ),
            ),
            Positioned(
              left: 18,
              child: isShowBadge
                  ? badge ?? const SizedBox.shrink()
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      trailing: favorite
          ? SvgPicture.asset(
              AppIcons.navigatorFavorite,
              width: 10,
              height: 10,
              fit: BoxFit.scaleDown,
            )
          : null,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: 'Roboto',
          color: ColorConstants.grey10,
          fontWeight: FontWeight.w500,
          fontSize: 18,
          height: 21 / 18,
        ),
      ),
    );
  }
}
