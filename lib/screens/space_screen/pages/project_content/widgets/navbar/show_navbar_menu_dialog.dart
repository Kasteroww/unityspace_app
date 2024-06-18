import 'package:flutter/material.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/app_dialog_confirm_delete.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/change_tab_dialog.dart';
import 'package:unityspace/screens/widgets/pop_up_button.dart/pop_up_menu_child.dart';
import 'package:unityspace/store/projects_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:unityspace/utils/mixins/copy_to_clipboard_mixin.dart';
import 'package:wstore/wstore.dart';

Future<void> showNavbarMenuDialog({
  required BuildContext context,
  required int? projectId,
  ProjectEmbed? embed,
}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return NavbarMenuDialog(
        embed: embed,
        projectId: projectId,
      );
    },
  );
}

class NavbarMenuDialogStore extends WStore with CopyToClipboardMixin {
  @override
  String message = '';

  Project? get project => computedFromStore(
        store: ProjectsStore(),
        getValue: (store) => store.projectsMap[widget.projectId],
        keyName: 'project',
      );

  void tryToHideTabDocs() {
    if (project == null) {
      logger.e('NavbarMenuDialogStore.tryToHideTabDocs error: project is null');
      return;
    }
    hideProjectTabDocs();
  }

  void hideProjectTabDocs() {
    ProjectsStore().showProjectReviewTab(
      projectId: project!.id,
      show: false,
    );
  }

  @override
  NavbarMenuDialog get widget => super.widget as NavbarMenuDialog;
}

class NavbarMenuDialog extends WStoreWidget<NavbarMenuDialogStore> {
  const NavbarMenuDialog({
    required this.embed,
    required this.projectId,
    super.key,
  });

  final ProjectEmbed? embed;
  final int? projectId;

  @override
  NavbarMenuDialogStore createWStore() => NavbarMenuDialogStore();

  @override
  Widget build(BuildContext context, NavbarMenuDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStringListener(
      store: store,
      watch: (store) => store.message,
      reset: (store) => store.message = '',
      onNotEmpty: (context, message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      },
      child: AlertDialog(
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
                    store.copy(
                      text: embed!.url,
                      successMessage: localization.link_copied_successfully,
                      errorMessage: localization.copy_error,
                    );
                  },
                ),
                NavbarMenuDialogItem(
                  text: localization.delete,
                  onTap: () {
                    Navigator.pop(context);
                    showConfirmDeleteDialog(
                      context: context,
                      embedding: embed!,
                    );
                  },
                  icon: AppIcons.delete,
                ),
              ] else
                NavbarMenuDialogItem(
                  text: localization.hide,
                  icon: AppIcons.hide,
                  onTap: () {
                    Navigator.pop(context);
                    store.tryToHideTabDocs();
                  },
                ),
            ],
          ),
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
      child: PopupMenuItemChild(
        text: text,
        iconPath: icon,
      ),
    );
  }
}
