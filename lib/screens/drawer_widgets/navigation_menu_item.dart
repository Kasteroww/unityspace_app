import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/resources/l10n/app_localizations.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/app_navigation_drawer.dart';
import 'package:unityspace/screens/dialogs/rename_spaces_group_dialog.dart';
import 'package:unityspace/screens/widgets/svg_icon.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class NavigatorMenuListTitle extends StatelessWidget {
  final int? groupId;
  final String title;
  final bool isOpen;

  const NavigatorMenuListTitle({
    required this.groupId,
    required this.title,
    required this.isOpen,
    super.key,
  });

  bool isShowGroupOptions({required String groupName}) {
    return (groupName == 'All Spaces' || groupName == 'Favorite')
        ? false
        : true;
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final isOwnerOrAdmin =
        context.wstore<AppNavigationDrawerStore>().isOwnerOrAdmin;
    return GestureDetector(
      onLongPressStart: (details) {
        if (isOwnerOrAdmin &&
            isShowGroupOptions(groupName: title) &&
            groupId != null) {
          showCustomSpaceGroupMenu(
            context: context,
            position: details.globalPosition,
            localization: localization,
            groupName: title,
            onTapRename: () {
              showRenameSpacesGroupDialog(
                context: context,
                groupId: groupId!,
                currentName: title,
              );
            },
          );
        }
      },
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ColorConstants.grey05,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            if (groupId != null)
              if (isOpen)
                const SvgIcon(
                  icon: AppIcons.drawerArrowDown,
                  width: 12,
                  height: 10,
                  color: ColorConstants.grey05,
                )
              else
                const SvgIcon(
                  icon: AppIcons.drawerArrowRight,
                  width: 10,
                  height: 12,
                  color: ColorConstants.grey05,
                ),
          ],
        ),
      ),
    );
  }

  Future<void> showCustomSpaceGroupMenu({
    required BuildContext context,
    required Offset position,
    required AppLocalizations localization,
    required String groupName,
    Function()? onTapRename,
    Function()? onTapDelete,
  }) async {
    final RenderBox? overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;

    if (overlay != null) {
      await showMenu(
        context: context,
        position: RelativeRect.fromRect(
          position & const Size(48, 48),
          Offset.zero & overlay.size,
        ),
        items: [
          PopupMenuItem(
            onTap: () => onTapRename != null ? onTapRename() : {},
            child: Text(
              localization.rename_group,
              style: const TextStyle(
                color: Color.fromRGBO(51, 51, 51, 1),
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ),
          PopupMenuItem(
            onTap: () => onTapDelete,
            child: Text(
              localization.delele_group,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ),
        ],
      );
    }
  }
}

class NavigatorMenuItem extends StatelessWidget {
  final String title;
  final bool selected;
  final bool favorite;
  final String iconAssetName;
  final double iconSize;
  final VoidCallback onTap;
  final bool isShowBadge;
  final Widget? badge;

  const NavigatorMenuItem({
    required this.title,
    required this.selected,
    required this.iconAssetName,
    required this.onTap,
    required this.favorite,
    this.iconSize = 28,
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
      leading: Stack(
        children: [
          SvgPicture.asset(
            iconAssetName,
            width: iconSize,
            height: iconSize,
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
