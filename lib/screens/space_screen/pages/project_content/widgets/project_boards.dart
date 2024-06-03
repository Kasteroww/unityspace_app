import 'package:flutter/material.dart';
import 'package:unityspace/models/project_models.dart';

class ProjectBoards extends StatelessWidget {
  const ProjectBoards({
    required this.project,
    super.key,
  });

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        itemCount: project.stages.length,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(
            width: 4,
          );
        },
        itemBuilder: (BuildContext context, int index) {
          final ProjectStage stage = project.stages[index];
          return DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(stage.name),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
