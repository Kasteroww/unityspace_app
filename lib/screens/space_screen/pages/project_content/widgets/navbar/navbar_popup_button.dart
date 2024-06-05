import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/project_content.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/navbar_popup_item.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class NavbarPopupButton extends StatelessWidget {
  const NavbarPopupButton({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final store = context.wstore<ProjectContentStore>();

    return PopupMenuButton<String>(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      child: SizedBox(
        height: 24,
        width: 24,
        child: SvgPicture.asset('assets/icons/settings.svg'),
      ),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          if (store.selectedTab == ProjectContentStore.tabTasks) ...[
            PopupMenuItem(
              child: NavbarPopupItem(
                text: '${localization.completed_today}: 0',
              ),
            ),
            PopupMenuItem(
              child: NavbarPopupItem(
                text: localization.search_task,
                icon: AppIcons.search,
              ),
            ),
            PopupMenuItem(
              child: NavbarPopupItem(
                text: localization.filter_tasks,
                icon: AppIcons.filter,
              ),
            ),
          ] else if (store.selectedTab == ProjectContentStore.tabDocuments)
            PopupMenuItem(
              child: NavbarPopupItem(
                text: localization.edit,
              ),
            ),
        ];
      },
    );
  }
}
