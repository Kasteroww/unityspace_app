import 'package:flutter/material.dart';
import 'package:unityspace/screens/app_navigation_drawer.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/project_page.dart';
import 'package:unityspace/screens/space_screen/pages/regulations_page/regulations_page.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/tasks_page.dart';
import 'package:unityspace/screens/widgets/tabs_list/tab_button.dart';
import 'package:unityspace/screens/widgets/tabs_list/tabs_list_row.dart';
import 'package:wstore/wstore.dart';
import 'package:unityspace/utils/localization_helper.dart';

class SpaceScreenStore extends WStore {
  // TODO: add data here...

  SpacesScreenTab selectedTab = SpacesScreenTab.projects;

  void selectTab(final SpacesScreenTab tab) {
    setStore(() {
      selectedTab = tab;
    });
  }

  List<SpacesScreenTab> get currentUserTabs => SpacesScreenTab.values.toList();

  @override
  SpaceScreen get widget => super.widget as SpaceScreen;
}

class SpaceScreen extends WStoreWidget<SpaceScreenStore> {
  final int spaceId;

  const SpaceScreen({
    super.key,
    required this.spaceId,
  });

  @override
  SpaceScreenStore createWStore() => SpaceScreenStore();

  @override
  Widget build(BuildContext context, SpaceScreenStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Scaffold(
      drawer: const AppNavigationDrawer(),
      appBar: AppBar(
        title: Text('${localization.space} $spaceId'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WStoreBuilder(
            store: store,
            watch: (store) => [store.selectedTab, store.currentUserTabs],
            builder: (context, store) => TabsListRow(
              children: [
                ...store.currentUserTabs.map(
                  (tab) => TabButton(
                    title: tab.title,
                    onPressed: () {
                      store.selectTab(tab);
                    },
                    selected: tab == store.selectedTab,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: WStoreValueBuilder(
                store: store,
                watch: (store) => store.selectedTab,
                builder: (context, selectedTab) {
                  return switch (selectedTab) {
                    SpacesScreenTab.projects => ProjectsPage(spaceId: spaceId),
                    SpacesScreenTab.tasks => const TasksPage(),
                    SpacesScreenTab.regulations => const RegulationsPage(),
                  };
                }),
          ),
        ],
      ),
    );
  }
}

enum SpacesScreenTab {
  projects(
    title: 'Проекты',
  ),
  tasks(
    title: 'Задачи',
  ),
  regulations(
    title: 'Регламенты',
  );

  const SpacesScreenTab({
    required this.title,
  });

  final String title;
}
