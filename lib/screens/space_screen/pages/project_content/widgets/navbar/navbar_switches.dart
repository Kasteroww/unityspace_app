import 'package:flutter/material.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/project_content.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/add_tab_dialog.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/navbar_popup_button.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/navbar_tab.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/show_navbar_menu_dialog.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class NavbarProjectTab {
  final String id;
  final String title;
  final VoidCallback onTap;
  final VoidCallback? onLongTap;

  NavbarProjectTab({
    required this.id,
    required this.title,
    required this.onTap,
    this.onLongTap,
  });
}

class NavbarSwitches extends StatelessWidget {
  const NavbarSwitches({required this.projectId, super.key});

  final int projectId;

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return ColoredBox(
      color: ColorConstants.background,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WStoreBuilder<ProjectContentStore>(
              watch: (store) => [
                store.selectedTab,
                store.embeddings,
                store.isShowProjectReviewTab,
              ],
              builder: (context, store) {
                store.selectTasksTabWhenHideDocs();
                final listTabs = [
                  NavbarProjectTab(
                    id: ProjectContentStore.tabTasks,
                    title: localization.tasks,
                    onTap: () => store.selectTab(ProjectContentStore.tabTasks),
                  ),
                  if (store.isShowProjectReviewTab)
                    NavbarProjectTab(
                      id: ProjectContentStore.tabDocuments,
                      title: localization.documents,
                      onTap: () {
                        store.selectTab(ProjectContentStore.tabDocuments);
                      },
                      onLongTap: () => showNavbarMenuDialog(
                        context: context,
                        projectId: projectId,
                      ),
                    ),
                  ...store.embeddings.map(
                    (embed) => NavbarProjectTab(
                      id: '${embed.id}',
                      title: embed.name,
                      onTap: () => store.launchLinkInBrowser(embed.url),
                      onLongTap: () => showNavbarMenuDialog(
                        context: context,
                        projectId: projectId,
                        embed: embed,
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
                              onPressed: listTabs[index].onTap,
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
        ),
      ),
    );
  }
}
