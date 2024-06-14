import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/utils/helpers/role.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_board/parts/add_stage_button.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_board/parts/add_task_button.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_board/parts/context_menu_button.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/project_detail.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_bottom_sheet.dart';
import 'package:unityspace/store/projects_store.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/tasks_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

class ProjectBoardsStore extends WStore {
  ProjectBoardsErrors error = ProjectBoardsErrors.none;
  WStoreStatus status = WStoreStatus.init;
  List<ProjectStage> get projectStages => project?.stages ?? [];
  int? focusedIndex;

  bool isAddingStage = false;

  Project? get project => computedFromStore(
        store: ProjectsStore(),
        getValue: (store) {
          return store.projectsMap[widget.projectId];
        },
        keyName: 'project',
      );

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
                .any((taskStage) => taskStage.projectId == project?.id);

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
            spaceId: project?.spaceId,
          );
        },
        keyName: 'userRole',
      );

  ///Загрузка задач
  Future<void> loadData({required int projectId}) async {
    if (status == WStoreStatus.loading) return;

    setStore(() {
      status = WStoreStatus.loading;
      error = ProjectBoardsErrors.none;
    });
    try {
      await TasksStore().getProjectTasks(projectId: projectId);
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
        error = ProjectBoardsErrors.loadingDataError;
      });
      throw Exception(e);
    }
  }

  Future<void> createTask({
    required String name,
    required int stageId,
  }) async {
    try {
      await TasksStore().createTask(name: name, stageId: stageId);
    } catch (e, stack) {
      logger.d('''
          on ProjectBoardsStore 
          ProjectBoardsStore 
          createTask error=$e\nstack=$stack
          ''');
      throw Exception(e);
    }
  }

  /// Пытается создать новую колонку
  Future<void> tryTocreateStage({
    required int? projectId,
    required String name,
  }) async {
    if (projectId == null) {
      setStore(() {
        status = WStoreStatus.error;
        error = ProjectBoardsErrors.createStageError;
        return;
      });
    } else {
      await createStage(projectId: projectId, name: name);
    }
  }

  double _getNextOrder() {
    return projectStages
            .map((column) => column.order)
            .reduce((max, order) => max > order ? max : order) +
        1;
  }

  ///Создает новый стейдж
  Future<void> createStage({
    required int projectId,
    required String name,
  }) async {
    try {
      final double newOrder = _getNextOrder();
      await ProjectsStore()
          .createStage(projectId: projectId, name: name, order: newOrder);
    } catch (e, stack) {
      logger.d('''
          on ProjectBoardsStore 
          ProjectBoardsStore 
          createTask error=$e\nstack=$stack
          ''');
      throw Exception(e);
    }
  }

  /// Фильтр задач
  bool isTaskInCurrentFilter(Task task) {
    return task.status == TaskStatuses.inWork;
  }

  /// выбирается индекс для фокусирования на конкретной
  /// кнопке добавления задач
  void setFocusedIndex(int? newFocusedIndex) {
    setStore(() {
      focusedIndex = newFocusedIndex;
    });
  }

  /// ставится статус того, что добавляется новая колонка (стейдж)
  void startAddingStage() {
    setStore(() {
      isAddingStage = true;
    });
  }

  /// убирается статус того, что добавляется новая колонка (стейдж)
  void stopAddingStage() {
    setStore(() {
      isAddingStage = false;
    });
  }

  Future<void> deleteTaskFromStage({
    required int taskId,
    required int stageId,
  }) async {
    try {
      await TasksStore().deleteTaskFromStage(
        taskId: taskId,
        stageId: stageId,
      );
    } catch (e, stack) {
      logger.d('''
          on ProjectBoardsStore 
          ProjectBoardsStore 
          deleteTaskFromStage error=$e\nstack=$stack
          ''');
      throw Exception(e);
    }
  }

  Future<void> moveTaskDownOfStage({
    required int taskId,
    required int currentStageId,
    required Task? lastTask,
  }) async {
    try {
      await TasksStore().moveTaskDownOfStage(
        taskId: taskId,
        currentStageId: currentStageId,
        lastTask: lastTask,
      );
    } catch (e, stack) {
      logger.d('''
          on ProjectBoardsStore 
          ProjectBoardsStore 
          moveTaskDownInStage error=$e\nstack=$stack
          ''');
      throw Exception(e);
    }
  }

  Future<void> moveTaskUpOfStage({
    required int taskId,
    required int currentStageId,
    required Task? firstTask,
  }) async {
    try {
      await TasksStore().moveTaskUpOfStage(
        taskId: taskId,
        currentStageId: currentStageId,
        firstTask: firstTask,
      );
    } catch (e, stack) {
      logger.d('''
          on ProjectBoardsStore 
          ProjectBoardsStore 
          moveTaskToTopOfStage error=$e\nstack=$stack
          ''');
      throw Exception(e);
    }
  }

  @override
  ProjectBoards get widget => super.widget as ProjectBoards;
}

class ProjectBoards extends WStoreWidget<ProjectBoardsStore> {
  const ProjectBoards({
    required this.projectId,
    super.key,
  });

  final int projectId;

  @override
  ProjectBoardsStore createWStore() =>
      ProjectBoardsStore()..loadData(projectId: projectId);

  @override
  Widget build(BuildContext context, ProjectBoardsStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Expanded(
      child: WStoreStatusBuilder(
        store: store,
        watch: (store) => store.status,
        builderError: (context) {
          return Text(
            switch (store.error) {
              ProjectBoardsErrors.none => '',
              ProjectBoardsErrors.loadingDataError =>
                localization.problem_uploading_data_try_again,
              ProjectBoardsErrors.createStageError =>
                localization.create_stage_error,
            },
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF111012).withOpacity(0.8),
              fontSize: 20,
              height: 1.2,
            ),
          );
        },
        builder: (context, status) => const SizedBox.shrink(),
        builderLoaded: (context) {
          return WStoreBuilder(
            store: store,
            watch: (store) => [
              store.tasksTree,
              store.focusedIndex,
              store.isAddingStage,
            ],
            builder: (context, store) {
              return GestureDetector(
                onTap: () {
                  // при нажатии в любое место, кроме кнопки добавления новой задачи
                  // устанавливается index null
                  store.setFocusedIndex(null);

                  /// останавливается добавление нового стейджа (колонки)
                  store.stopAddingStage();
                },
                child: ListView.separated(
                  // Длинна списка - это кол - во стейджей в пространстве
                  // + 1 место для кнопки добавления нового стейджа (колонки)
                  itemCount: store.tasksTree.length + 1,
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(
                      width: 4,
                    );
                  },
                  itemBuilder: (BuildContext context, int index) {
                    if (index == store.tasksTree.length) {
                      return AddStageButton(
                        onSubmitted: (name) {
                          store.tryTocreateStage(
                            projectId: store.project?.id,
                            name: name,
                          );
                          store.stopAddingStage();
                        },
                        onTapButton: () {
                          store.startAddingStage();
                        },
                        isAddingStage: store.isAddingStage,
                      );
                    }
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
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final task = tasks[index];
                                      return InkWell(
                                        onTap: () => AppBottomSheet.show(
                                          context,
                                          builder: (BuildContext context) =>
                                              ProjectDetail(
                                            task: task,
                                            spaceId: store.project?.spaceId,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                            right: 8,
                                            left: 8,
                                          ),
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      task.name,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  ContextMenuButton(
                                                    projectId: projectId,
                                                    tasks: tasks,
                                                    stage: stage,
                                                    task: task,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                AddTaskButton(
                                  focusedIndex: store.focusedIndex,
                                  onSubmitted: (name) {
                                    store.createTask(
                                      name: name,
                                      stageId: stage.id,
                                    );
                                    store.setFocusedIndex(null);
                                  },
                                  buttonIdex: index,
                                  onTapButton: () {
                                    store.setFocusedIndex(index);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
