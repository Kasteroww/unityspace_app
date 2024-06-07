import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/navbar_switches.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/navbar_tab.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_board/project_boards.dart';
import 'package:unityspace/store/projects_store.dart';
import 'package:unityspace/utils/helpers.dart';
import 'package:wstore/wstore.dart';

class ProjectContentStore extends WStore {
  static const tabTasks = 'tasks';
  static const tabDocuments = 'docs';
  String selectedTab = tabTasks;

  Project? get project => computedFromStore(
        store: ProjectsStore(),
        getValue: (store) {
          return store.projectsMap[widget.projectId];
        },
        keyName: 'project',
      );

  List<ProjectEmbed> get embeddings => computed(
        getValue: () => project?.embeddings ?? [],
        keyName: 'embeddings',
        watch: () => [project],
      );

  bool get isShowProjectReviewTab => computed(
        getValue: () => project?.showProjectReviewTab ?? false,
        keyName: 'isShowProjectReviewTab',
        watch: () => [project],
      );

  void selectTab(String tab) {
    setStore(() {
      selectedTab = tab;
    });
  }

  bool isTasksTab(String tab) {
    return tab == ProjectContentStore.tabTasks;
  }

  void tryToHideTabDocs() {
    if (project == null) return;
    hideProjectTabDocs();
  }

  void hideProjectTabDocs() {
    ProjectsStore().showProjectReviewTab(
      projectId: project!.id,
      show: false,
    );
  }

  void copyTabLink(String tabId) {
    final tabIdNum = int.tryParse(tabId);
    final embeddingByTabId = embeddings
        .firstWhereOrNull((embedding) => embedding.id == tabIdNum)
        ?.url;
    if (embeddingByTabId == null) return;
    copyToClipboard(embeddingByTabId);
  }

  Future<void> onLongPressAction({
    required String tabId,
    PopupItemActionTypes? action,
  }) async {
    if (action == null) return;
    return switch (action) {
      PopupItemActionTypes.hide => hideProjectTabDocs(),
      PopupItemActionTypes.copyLink => copyTabLink(tabId),
      PopupItemActionTypes.edit => null,
      PopupItemActionTypes.delete => null,
    };
  }

  @override
  ProjectContent get widget => super.widget as ProjectContent;
}

class ProjectContent extends WStoreWidget<ProjectContentStore> {
  final int projectId;

  const ProjectContent({
    required this.projectId,
    super.key,
  });

  @override
  ProjectContentStore createWStore() => ProjectContentStore();

  @override
  Widget build(BuildContext context, ProjectContentStore store) {
    return Scaffold(
      appBar: AppBar(
        title: Text(store.project?.name ?? ' '),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const NavbarSwitches(),
            const SizedBox(height: 16),
            ProjectBoards(projectId: projectId),
          ],
        ),
      ),
    );
  }
}
