import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/project_content.dart';
import 'package:unityspace/screens/widgets/pop_up_button.dart/default_pop_up_button.dart';
import 'package:unityspace/screens/widgets/pop_up_button.dart/pop_up_menu_child.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class NavbarPopupButton extends StatelessWidget {
  const NavbarPopupButton({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final store = context.wstore<ProjectContentStore>();

    return DefaultPopUpButton(
      child: SizedBox(
        height: 24,
        width: 24,
        child: SvgPicture.asset('assets/icons/settings.svg'),
      ),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          if (store.selectedTab == ProjectContentStore.tabTasks) ...[
            PopupMenuItem(
              child: PopupMenuItemChild(
                text: '${localization.search_task}...',
                iconPath: AppIcons.search,
              ),
            ),
            PopupMenuItem(
              child: PopupMenuItemChild(
                text: localization.filter_tasks,
                iconPath: AppIcons.filter,
              ),
            ),
          ] else if (store.selectedTab == ProjectContentStore.tabDocuments)
            PopupMenuItem(
              child: PopupMenuItemChild(
                text: localization.edit,
              ),
            ),
        ];
      },
    );
  }
}
