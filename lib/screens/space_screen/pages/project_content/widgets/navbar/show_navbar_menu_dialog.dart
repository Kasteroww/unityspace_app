import 'package:flutter/material.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/project_content.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/app_dialog_confirm_delete.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/change_tab_dialog.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/navbar_popup_item.dart';
import 'package:unityspace/utils/localization_helper.dart';

Future<void> showNavbarMenuDialog({
  required BuildContext context,
  required ProjectContentStore store,
  ProjectEmbed? embed,
}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return NavbarMenuDialog(
        embed: embed,
        store: store,
      );
    },
  );
}

class NavbarMenuDialog extends StatelessWidget {
  const NavbarMenuDialog({
    required this.embed,
    required this.store,
    super.key,
  });

  final ProjectEmbed? embed;
  final ProjectContentStore store;

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (embed != null) ...[
              NavbarMenuDialogItem(
                text: localization.change,
                icon: AppIcons.edit,
                onTap: () {
                  Navigator.pop(context);
                  showChangeTabDialog(context: context, embedding: embed!);
                },
              ),
              NavbarMenuDialogItem(
                text: localization.copy_link,
                icon: AppIcons.link,
                onTap: () {
                  Navigator.pop(context);
                  store.copyTabLink(embed!.url);
                },
              ),
              NavbarMenuDialogItem(
                text: localization.delete,
                onTap: () {
                  Navigator.pop(context);
                  showConfirmDeleteDialog(context: context, embedding: embed!);
                },
                icon: AppIcons.delete,
              ),
            ] else
              NavbarMenuDialogItem(
                text: localization.hide,
                icon: AppIcons.hide,
                onTap: () {
                  Navigator.pop(context);
                  store.hideProjectTabDocs();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class NavbarMenuDialogItem extends StatelessWidget {
  const NavbarMenuDialogItem({
    required this.text,
    required this.onTap,
    this.icon,
    super.key,
  });

  final String text;
  final String? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: NavbarPopupItem(
        text: text,
        icon: icon,
      ),
    );
  }
}
