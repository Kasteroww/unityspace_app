import 'package:flutter/material.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/screens/app_navigation_drawer.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/project_page.dart';
import 'package:unityspace/screens/space_screen/pages/reglaments_page/reglaments_page.dart';
import 'package:unityspace/screens/space_screen/pages/space_members_page/space_members_page.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/tasks_page.dart';
import 'package:unityspace/screens/space_screen/widgets/pop_up_button.dart';
import 'package:unityspace/screens/widgets/appbar.dart';
import 'package:wstore/wstore.dart';

class SpaceScreenStore extends WStore {
  late Space spaceId;
  SpacesScreenTab selectedTab = SpacesScreenTab.projects;

  void selectTab(SpacesScreenTab tab) {
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
    required this.space,
    super.key,
  });

  @override
  SpaceScreenStore createWStore() =>
      SpaceScreenStore()..initValues(space: space);

  @override
  Widget build(BuildContext context, SpaceScreenStore store) {
    return Scaffold(
      drawer: const AppNavigationDrawer(),
      appBar: CustomAppBar(
        titleText: space.name,
        actions: [
          PopUpSpacesScreenButton(
            onSelected: (tab) {
              store.selectTab(tab);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  SpacesScreenTab.members => SpaceMembersPage(spaceId: space.id)
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum SpacesScreenTab { projects, tasks, reglaments, members }
