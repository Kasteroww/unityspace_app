import 'package:flutter/material.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/screens/app_navigation_drawer.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/project_page.dart';
import 'package:unityspace/screens/space_screen/pages/reglaments_page/reglaments_page.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/tasks_page.dart';
import 'package:unityspace/screens/widgets/tabs_list/tab_button.dart';
import 'package:unityspace/screens/widgets/tabs_list/tabs_list_row.dart';
import 'package:wstore/wstore.dart';
import 'package:unityspace/utils/localization_helper.dart';

class SpaceScreenStore extends WStore {
  late Space spaceId;
  SpacesScreenTab selectedTab = SpacesScreenTab.projects;

  void selectTab(final SpacesScreenTab tab) {
    setStore(() {
      selectedTab = tab;
    });
  }

  void initValues({required Space space}) {
    spaceId = space;
  }

  List<SpacesScreenTab> get currentUserTabs => SpacesScreenTab.values.toList();

  @override
  SpaceScreen get widget => super.widget as SpaceScreen;
}

class SpaceScreen extends WStoreWidget<SpaceScreenStore> {
  final Space space;

  const SpaceScreen({
    super.key,
    required this.space,
  });

  @override
  SpaceScreenStore createWStore() =>
      SpaceScreenStore()..initValues(space: space);

  @override
  Widget build(BuildContext context, SpaceScreenStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Scaffold(
      drawer: const AppNavigationDrawer(),
      appBar: AppBar(
        title: Text(space.name),
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
                    title: switch (tab) {
                      SpacesScreenTab.projects => localization.projects,
                      SpacesScreenTab.tasks => localization.tasks,
                      SpacesScreenTab.reglaments => localization.reglaments,
                    },
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
                    SpacesScreenTab.projects => ProjectsPage(space: space),
                    SpacesScreenTab.tasks => TasksPage(spaceId: space.id),
                    SpacesScreenTab.reglaments => ReglamentsPage(space: space),
                  };
                }),
          ),
        ],
      ),
    );
  }
}

enum SpacesScreenTab { projects, tasks, reglaments }
