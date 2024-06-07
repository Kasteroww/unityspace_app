import 'package:flutter/material.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/resources/l10n/app_localizations.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/project_content.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/utils/helpers/screen_center_position.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/add_tab_dialog.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/navbar_popup_button.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/navbar_popup_item.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/navbar_tab.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

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
            // составление листа элементов tab панели
            final List<(String, String)> listTabs = [
              (ProjectContentStore.tabTasks, localization.tasks),
              // если у модели проекта параметр true, добавляем вкладку документы
              if (store.isShowProjectReviewTab)
                (ProjectContentStore.tabDocuments, localization.documents),
              // добавляем в лист вкладок embeddings из модели проекта
              ...store.embeddings.map(
                (embedding) => ('${embedding.id}', embedding.name),
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
                          title: listTabs[index].$2,
                          onPressed: () => store.selectTab(listTabs[index].$1),
                          onLongPress: () async {
                            final action = await showOnLongPressMenu(
                              context: context,
                              tabId: listTabs[index].$1,
                            );
                            await store.onLongPressAction(
                              tabId: listTabs[index].$1,
                              action: action,
                            );
                          },
                          selected: listTabs[index].$1 == store.selectedTab,
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

Future<PopupItemActionTypes?> showOnLongPressMenu({
  required String tabId,
  required BuildContext context,
}) async {
  if (tabId == ProjectContentStore.tabTasks) return null;
  final items = getListPopupMenu(
    tabId: tabId,
    localization: LocalizationHelper.getLocalizations(context),
  );
  final size = MediaQuery.of(context).size;
  return showMenu(
    context: context,
    position: getCenterScreenPosition(size),
    items: items,
  );
}

List<PopupMenuItem<PopupItemActionTypes>> getListPopupMenu({
  required String tabId,
  required AppLocalizations localization,
}) {
  if (tabId == ProjectContentStore.tabDocuments) {
    return getListPopMenuDocs(localization: localization);
  } else {
    return getListPopMenuEmbed(localization: localization);
  }
}

List<PopupMenuItem<PopupItemActionTypes>> getListPopMenuDocs({
  required AppLocalizations localization,
}) {
  return [
    PopupMenuItem(
      value: PopupItemActionTypes.hide,
      child: NavbarPopupItem(
        text: localization.hide,
        icon: AppIcons.hide,
      ),
    ),
  ];
}

List<PopupMenuItem<PopupItemActionTypes>> getListPopMenuEmbed({
  required AppLocalizations localization,
}) {
  return [
    PopupMenuItem(
      value: PopupItemActionTypes.edit,
      child: NavbarPopupItem(
        text: localization.change,
        icon: AppIcons.edit,
      ),
    ),
    PopupMenuItem(
      value: PopupItemActionTypes.copyLink,
      child: NavbarPopupItem(
        text: localization.copy_link,
        icon: AppIcons.link,
      ),
    ),
    PopupMenuItem(
      value: PopupItemActionTypes.delete,
      child: NavbarPopupItem(
        text: localization.delete,
        icon: AppIcons.delete,
      ),
    ),
  ];
}
