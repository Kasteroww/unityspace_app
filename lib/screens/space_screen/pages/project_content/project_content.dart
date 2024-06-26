import 'package:flutter/material.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/navbar_switches.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_board/project_boards.dart';
import 'package:unityspace/screens/widgets/stubs/work_in_progress_stub.dart';
import 'package:unityspace/store/projects_store.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wstore/wstore.dart';

class ProjectContentStore extends WStore {
  static const tabTasks = 'tasks';
  static const tabDocuments = 'docs';
  String selectedTab = tabTasks;

  Project? get project => computedFromStore(
        store: ProjectsStore(),
        getValue: (store) => store.projectsMap[widget.projectId],
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

  bool get isTasksTab => computed(
        getValue: () => selectedTab == tabTasks,
        keyName: 'isTasksTab',
        watch: () => [selectedTab],
      );

  void selectTab(String tab) {
    setStore(() {
      selectedTab = tab;
    });
  }

  void selectTasksTabWhenHideDocs() {
    if (!isShowProjectReviewTab && selectedTab == tabDocuments) {
      selectTab(tabTasks);
    }
  }

  Future<void> launchLinkInBrowser(String embedUrl) async {
    final url = Uri.parse(embedUrl);
    if (url.isAbsolute) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
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
      backgroundColor: store.project?.color,
      appBar: AppBar(
        title: Text(store.project?.name ?? ' '),
      ),
      body: WStoreBuilder<ProjectContentStore>(
        watch: (store) => [store.selectedTab],
        builder: (context, store) {
          return SafeArea(
            child: Column(
              children: [
                NavbarSwitches(projectId: projectId),
                const SizedBox(height: 16),
                if (store.isTasksTab)
                  ProjectBoards(
                    projectId: projectId,
                  )
                else
                  const Expanded(child: WorkInProgressStub()),
              ],
            ),
          );
        },
      ),
    );
  }
}
