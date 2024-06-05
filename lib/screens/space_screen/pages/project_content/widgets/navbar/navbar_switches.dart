import 'package:flutter/material.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/project_content.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/add_tab_dialog.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/navbar_popup_button.dart';
import 'package:unityspace/screens/widgets/tabs_list/tab_button.dart';
import 'package:unityspace/screens/widgets/tabs_list/tabs_list_row.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class NavbarSwitches extends StatelessWidget {
  const NavbarSwitches({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.wstore<ProjectContentStore>();
    final localization = LocalizationHelper.getLocalizations(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WStoreBuilder(
          store: store,
          watch: (store) => [
            store.selectedTab,
            store.embeddings,
            store.isShowProjectReviewTab,
          ],
          builder: (context, store) {
            final List<(String, String)> listTabs = [
              (ProjectContentStore.tabTasks, localization.tasks),
              if (store.isShowProjectReviewTab)
                (ProjectContentStore.tabDocuments, localization.documents),
              ...store.embeddings.map(
                (embedding) => ('embed-${embedding.id}', embedding.name),
              ),
            ];
            return Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        TabsListRow(
                          children: [
                            ...listTabs.map(
                              (tab) => TabButton(
                                title: tab.$2,
                                onPressed: () {
                                  store.selectTab(tab.$1);
                                },
                                selected: tab.$1 == store.selectedTab,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => showAddTabDialog(context, store.project?.id),
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
