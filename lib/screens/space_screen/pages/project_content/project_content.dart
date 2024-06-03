import 'package:flutter/material.dart';
import 'package:unityspace/models/project_models.dart';
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('${project.id}'),
          ],
        ),
      ),
    );
  }
}
