import 'package:flutter/material.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/navbar_switches.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_board/project_boards.dart';
import 'package:unityspace/store/projects_store.dart';
import 'package:wstore/wstore.dart';

class ProjectContentStore extends WStore {
  static const tabTasks = 'tasks';
  static const tabDocuments = 'docs';
  String selectedTab = tabTasks;

  void selectTab(String tab) {
    setStore(() {
      selectedTab = tab;
    });
  }

  Project? get project => computedFromStore(
        store: ProjectsStore(),
        getValue: (store) => store.projectsMap[widget.project.id],
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

  @override
  ProjectContent get widget => super.widget as ProjectContent;
}

class ProjectContent extends WStoreWidget<ProjectContentStore> {
  final Project project;

  const ProjectContent({
    required this.project,
    super.key,
  });

  @override
  ProjectContentStore createWStore() => ProjectContentStore();

  @override
  Widget build(BuildContext context, ProjectContentStore store) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const NavbarSwitches(),
            const SizedBox(height: 16),
            ProjectBoards(project: project),
          ],
        ),
      ),
    );
  }
}
