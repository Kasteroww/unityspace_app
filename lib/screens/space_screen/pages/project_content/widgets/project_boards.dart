import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/utils/helpers/role.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/tasks_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:wstore/wstore.dart';

class ProjectBoardsStore extends WStore {
  Project get project => widget.project;
  List<ProjectStage> get projectStages => project.stages;

  List<Task> get tasks => computedFromStore(
        store: TasksStore(),
        getValue: (store) => store.tasks ?? [],
        keyName: 'tasks',
      );

  User? get user => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.user,
        keyName: 'user',
      );

  List<ProjectStageWithTasks> get tasksTree => computed(
        getValue: () {
          if (projectStages.isEmpty) return [];

          final projectTasks = tasks.where((task) {
            final isTaskInProject = task.stages
                .any((taskStage) => taskStage.projectId == project.id);

            final isInitiatorMember =
                userRole == UserRoles.initiator && user != null
                    ? task.members.contains(user!.id)
                    : true;

            return isTaskInProject && isInitiatorMember;
          }).toList();

          final stages = projectStages.map((stage) {
            final stageTasks = projectTasks.where((task) {
              return task.stages
                  .any((taskStage) => taskStage.stageId == stage.id);
            }).toList();

            stageTasks.sort((a, b) {
              final stageA = a.stages.firstWhereOrNull(
                (taskStage) => taskStage.stageId == stage.id,
              );
              final stageB = b.stages.firstWhereOrNull(
                (taskStage) => taskStage.stageId == stage.id,
              );
              if (stageA == null || stageB == null) return 0;
              return stageA.order.compareTo(stageB.order);
            });

            return ProjectStageWithTasks(
              stage: stage,
              tasks: stageTasks,
              // tasks: stageTasks.where((task) => isTaskInCurrentFilter(task)).toList(),
              tasksNoFilter: stageTasks,
            );
          }).toList();

          stages.sort((a, b) => a.stage.order.compareTo(b.stage.order));

          return stages;
        },
        watch: () => [project, projectStages, tasks, user],
        keyName: ' tasksTree',
      );

  UserRoles? get userRole => computedFromStore(
        store: SpacesStore(),
        getValue: (store) {
          return store.getCurrentUserRoleAtSpace(
            spaceId: project.spaceId,
          );
        },
        keyName: 'userRole',
      );

  @override
  ProjectBoards get widget => super.widget as ProjectBoards;
}

class ProjectBoards extends WStoreWidget<ProjectBoardsStore> {
  const ProjectBoards({
    required this.project,
    super.key,
  });

  final Project project;

  @override
  ProjectBoardsStore createWStore() => ProjectBoardsStore();

  @override
  Widget build(BuildContext context, ProjectBoardsStore store) {
    return Expanded(
      child: ListView.separated(
        itemCount: store.tasksTree.length,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(
            width: 4,
          );
        },
        itemBuilder: (BuildContext context, int index) {
          final ProjectStage stage = store.tasksTree[index].stage;
          final List<Task> tasks = store.tasksTree[index].tasks;
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
                  Text('${tasks.length}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
