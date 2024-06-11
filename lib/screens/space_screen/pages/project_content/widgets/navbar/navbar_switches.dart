import 'package:flutter/material.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/resources/l10n/app_localizations.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/project_content.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/utils/helpers/screen_center_position.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/add_tab_dialog.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/app_dialog_confirm_delete.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/change_tab_dialog.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/navbar_popup_button.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/navbar_popup_item.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/navbar_tab.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class NavbarProjectTab {
  final String id;
  final String title;
  final VoidCallback onPressed;
  final VoidCallback? onLongTap;

  NavbarProjectTab({
    required this.id,
    required this.title,
    required this.onPressed,
    this.onLongTap,
  });
}

class NavbarSwitches extends StatelessWidget {
  const NavbarSwitches({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WStoreBuilder<ProjectContentStore>(
          watch: (store) => [
            store.selectedTab,
            store.embeddings,
            store.isShowProjectReviewTab,
          ],
          builder: (context, store) {
            final listTabs = [
              NavbarProjectTab(
                id: ProjectContentStore.tabTasks,
                title: localization.tasks,
                onPressed: () => store.selectTab(ProjectContentStore.tabTasks),
              ),
              if (store.isShowProjectReviewTab)
                NavbarProjectTab(
                  id: ProjectContentStore.tabDocuments,
                  title: localization.documents,
                  onPressed: () {
                    store.selectTab(ProjectContentStore.tabDocuments);
                  },
                  onLongTap: () => showOnLongPressMenuDocs(context: context),
                ),
              ...store.embeddings.map(
                (embeddings) => NavbarProjectTab(
                  id: '${embeddings.id}',
                  title: embeddings.name,
                  onPressed: () => store.launchLinkInBrowser(embeddings.url),
                  onLongTap: () => showOnLongPressMenuEmbed(
                    context: context,
                    embedding: embeddings,
                  ),
                ),
              ),
            ];
            return Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: listTabs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return NavbarTab(
                          title: listTabs[index].title,
                          onPressed: listTabs[index].onPressed,
                          onLongPress: listTabs[index].onLongTap,
                          selected: listTabs[index].id == store.selectedTab,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => showAddTabDialog(context, store.project?.id),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(width: 4),
                if (store.selectedTab == ProjectContentStore.tabTasks ||
                    (store.selectedTab == ProjectContentStore.tabDocuments))
                  const NavbarPopupButton(),
                const SizedBox(width: 12),
              ],
            );
          },
        ),
      ],
    );
  }
}

Future<void> showOnLongPressMenuDocs({
  required BuildContext context,
}) async {
  final localization = LocalizationHelper.getLocalizations(context);
  final size = MediaQuery.of(context).size;
  final items = getListPopMenuDocs(localization: localization);
  final action = await showMenu(
    context: context,
    position: getCenterScreenPosition(size),
    items: items,
  );
  if (action == null) return;
  if (context.mounted) {
    return context.wstore<ProjectContentStore>().hideProjectTabDocs();
  }
}

Future<void> showOnLongPressMenuEmbed({
  required BuildContext context,
  required ProjectEmbed embedding,
}) async {
  final localization = LocalizationHelper.getLocalizations(context);
  final size = MediaQuery.of(context).size;
  final items = getListPopMenuEmbed(localization: localization);
  final store = context.wstore<ProjectContentStore>();
  final action = await showMenu(
    context: context,
    position: getCenterScreenPosition(size),
    items: items,
  );
  if (action == null) return;
  if (context.mounted) {
    return switch (action) {
      PopupItemEmbedActionTypes.copyLink => store.copyTabLink(embedding.url),
      PopupItemEmbedActionTypes.edit =>
        showChangeTabDialog(context: context, embedding: embedding),
      PopupItemEmbedActionTypes.delete =>
        showConfirmDeleteDialog(context: context, embedding: embedding),
    };
  }
}

List<PopupMenuItem<PopupItemDocsActionTypes>> getListPopMenuDocs({
  required AppLocalizations localization,
}) {
  return [
    PopupMenuItem(
      value: PopupItemDocsActionTypes.hide,
      child: NavbarPopupItem(
        text: localization.hide,
        icon: AppIcons.hide,
      ),
    ),
  ];
}

List<PopupMenuItem<PopupItemEmbedActionTypes>> getListPopMenuEmbed({
  required AppLocalizations localization,
}) {
  return [
    PopupMenuItem(
      value: PopupItemEmbedActionTypes.edit,
      child: NavbarPopupItem(
        text: localization.change,
        icon: AppIcons.edit,
      ),
    ),
    PopupMenuItem(
      value: PopupItemEmbedActionTypes.copyLink,
      child: NavbarPopupItem(
        text: localization.copy_link,
        icon: AppIcons.link,
      ),
    ),
    PopupMenuItem(
      value: PopupItemEmbedActionTypes.delete,
      child: NavbarPopupItem(
        text: localization.delete,
        icon: AppIcons.delete,
      ),
    ),
  ];
}
