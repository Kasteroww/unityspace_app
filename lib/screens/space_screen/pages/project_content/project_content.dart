import 'package:flutter/material.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_boards.dart';
import 'package:wstore/wstore.dart';

class ProjectContentStore extends WStore {
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
      body: Column(
        children: [
          Text('${project.id}'),
          ProjectBoards(project: project),
        ],
      ),
    );
  }
}
