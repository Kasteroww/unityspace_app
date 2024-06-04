import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/utils/helpers/role.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/tasks_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

class ProjectBoardsStore extends WStore {
  //обязательно нужно инициализировать при загрузке данных на странице
  late Project project;
  List<ProjectStage> get projectStages => project.stages;

  NotificationErrors error = NotificationErrors.none;
  WStoreStatus status = WStoreStatus.init;

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
              tasks: stageTasks
                  .where((task) => isTaskInCurrentFilter(task))
                  .toList(),
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

  ///Загрузка задач
  Future<void> loadData({required Project project}) async {
    this.project = project;
    if (status == WStoreStatus.loading) return;

    setStore(() {
      status = WStoreStatus.loading;
      error = NotificationErrors.none;
    });
    try {
      await TasksStore().getProjectTasks(projectId: project.id);
      setStore(() {
        status = WStoreStatus.loaded;
      });
    } catch (e, stack) {
      logger.d('''
          on ProjectBoardsStore 
          ProjectBoardsStore 
          loadData error=$e\nstack=$stack
          ''');
      setStore(() {
        status = WStoreStatus.error;
        error = NotificationErrors.loadingDataError;
      });
      throw Exception(e);
    }
  }

  /// Фильтр задач
  bool isTaskInCurrentFilter(Task task) {
    return task.status == TaskStatuses.inWork;
  }

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
  ProjectBoardsStore createWStore() =>
      ProjectBoardsStore()..loadData(project: project);

  @override
  Widget build(BuildContext context, ProjectBoardsStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Expanded(
      child: WStoreStatusBuilder(
        store: store,
        watch: (store) => store.status,
        builder: (context, status) => const SizedBox.shrink(),
        builderLoaded: (context) {
          return ListView.separated(
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
              return Padding(
                padding: const EdgeInsets.all(8),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 180,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(stage.name),
                          Text('${tasks.length}'),
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: tasks.length,
                              itemBuilder: (BuildContext context, int index) {
                                final task = tasks[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 8,
                                    right: 8,
                                    left: 8,
                                  ),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text(task.name),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          ColoredBox(
                            color: Colors.blue,
                            child: Center(
                              child: Text('+ ${localization.add_task}'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        builderLoading: (context) =>
            const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
