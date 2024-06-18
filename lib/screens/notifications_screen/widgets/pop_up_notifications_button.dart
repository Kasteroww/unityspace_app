import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/screens/notifications_screen/notifications_screen.dart';
import 'package:unityspace/screens/widgets/pop_up_button.dart/default_pop_up_button.dart';
import 'package:unityspace/screens/widgets/pop_up_button.dart/pop_up_menu_child.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class PopUpNotificationsButton extends StatelessWidget {
  const PopUpNotificationsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final store = context.wstore<NotificationsScreenStore>();

    return DefaultPopUpButton(
      child: SizedBox(
        height: 55,
        width: 55,
        child: SvgPicture.asset('assets/icons/settings.svg'),
      ),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          if (store.selectedTab == NotificationsScreenTab.current) ...[
            //Прочитать все
            PopupMenuItem<String>(
              onTap: store.readAllNotifications,
              child: PopupMenuItemChild(
                iconPath: 'assets/icons/notifications/visible.svg',
                text: localization.read_all,
              ),
            ),
            //Архивировать все
            PopupMenuItem<String>(
              onTap: store.archiveAllNotifications,
              child: PopupMenuItemChild(
                iconPath: 'assets/icons/notifications/download_box_1.svg',
                text: localization.archive_all,
              ),
            ),
          ] else if (store.selectedTab == NotificationsScreenTab.archived) ...[
            //Удалить все
            PopupMenuItem<String>(
              onTap: store.deleteAllNotifications,
              child: PopupMenuItemChild(
                iconPath: 'assets/icons/notifications/recycle_bin_2.svg',
                text: localization.delete_all,
              ),
            ),
          ],
        ];
      },
    );
  }
}
