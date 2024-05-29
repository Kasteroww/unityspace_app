import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/widgets/all_tasks_body.dart';
import 'package:unityspace/screens/widgets/common/paddings.dart';
import 'package:unityspace/store/project_store.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/tasks_store.dart';
import 'package:unityspace/utils/constants.dart';
import 'package:unityspace/utils/errors.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

class TasksPageStore extends WStore {
  TasksErrors error = TasksErrors.none;
  WStoreStatus status = WStoreStatus.init;
  TasksStore tasksStore = TasksStore();
  ProjectStore projectStore = ProjectStore();
  SpacesStore spacesStore = SpacesStore();
  int spaceId = 0;

  /// геттер задач из TasksStore
  List<Task>? get tasks => computedFromStore(
        store: tasksStore,
        getValue: (store) => store.tasks,
        keyName: 'tasks',
      );

  List<Task> get searchTasks => computedFromStore(
        store: tasksStore,
        getValue: (store) => store.searchedTasks,
        keyName: 'searchedTasks',
      );

  /// загрузка задач по пространству и статусам
  Future<void> loadData() async {
    if (status == WStoreStatus.loading) return;
    setStore(() {
      status = WStoreStatus.loading;
      error = TasksErrors.none;
    });
    try {
      await tasksStore.getSpaceTasks(
        spaceId: spaceId,
        statuses: [TaskStatuses.inWork.value],
      );
      setStore(() {
        status = WStoreStatus.loaded;
      });
    } catch (e, stack) {
      logger.d('on AllTasksPage'
          'TasksStore loadData error=$e\nstack=$stack');
      setStore(() {
        status = WStoreStatus.error;
        error = TasksErrors.loadingDataError;
      });
    }
  }

  String? getProjectNameById(int projectId) {
    return projectStore.getProjectById(projectId)?.name;
  }

  List<TasksGroup> get tasksByProject => _tasksByProject(tasks);

  List<TasksGroup> get searchTasksByProject => _tasksByProject(searchTasks);

  /// группирует задачи по проектам
  List<TasksGroup> _tasksByProject(List<Task>? tasks) {
    final group = <TasksGroup>[];
    if (tasks != null && tasks.isNotEmpty) {
      for (final task in tasks) {
        // так как у задачи нет ссылки на ее проект,
        // находим его в поле taskStage
        for (final taskStage in task.stages) {
          final taskProject = group.firstWhereOrNull(
            (project) => project.id == taskStage.projectId,
          );
          // если проект уже есть в группах, то добавляем задачу
          // в соответствующую группу
          if (taskProject != null) {
            taskProject.tasks.add(task);
            // если проекта нет в группах, добавляем проект
          } else {
            final project = projectStore.projectsMap[taskStage.projectId];
            final space =
                project != null ? spacesStore.spacesMap[spaceId] : null;
            final SpaceColumn? column = project != null
                ? spacesStore.columnsMap[project.columnId]
                : null;
            if (project != null && space != null && column != null) {
              if (spaceId == 0 || spaceId == space.id) {
                group.add(
                  TasksGroup(
                    id: project.id,
                    spaceOrder: space.order.toInt(),
                    spaceFavorite: space.favorite ? 1 : 0,
                    spaceId: space.id,
                    projectOrder: int.parse(project.order),
                    groupTitle: spaceId != 0
                        ? '${column.name} - ${project.name}'
                        : '${space.name} - ${column.name} - ${project.name}',
                    columnOrder: column.order.toInt(),
                    tasks: [task],
                  ),
                );
              }
            }
          }
        }
      }
    }

    group.sort((a, b) {
      final compareBySpaceFavorite = a.spaceFavorite.compareTo(b.spaceFavorite);
      if (compareBySpaceFavorite != 0) return compareBySpaceFavorite;
      final compareBySpaceOrder = a.spaceOrder.compareTo(b.spaceOrder);
      if (compareBySpaceOrder != 0) return compareBySpaceOrder;
      final compareBySpaceColumnOrder = a.columnOrder.compareTo(b.columnOrder);
      if (compareBySpaceColumnOrder != 0) return compareBySpaceColumnOrder;
      final compareByProjectOrder = a.projectOrder.compareTo(b.projectOrder);
      if (compareByProjectOrder != 0) return compareByProjectOrder;
      return a.groupTitle.compareTo(b.groupTitle);
    });
    return group;
  }

  /// spaceId для получения задач, вызывается сразу после создания сторы
  void initValues({required int currentSpaceId}) {
    setStore(() {
      spaceId = currentSpaceId;
    });
  }

  @override
  TasksPage get widget => super.widget as TasksPage;
}

class TasksPage extends WStoreWidget<TasksPageStore> {
  const TasksPage({
    required this.spaceId,
    super.key,
  });

  final int spaceId;

  @override
  TasksPageStore createWStore() => TasksPageStore()
    ..initValues(currentSpaceId: spaceId)
    ..loadData();

  @override
  Widget build(BuildContext context, TasksPageStore store) {
    return WStoreStatusBuilder<TasksPageStore>(
      store: store,
      watch: (store) => store.status,
      builder: (context, store) {
        return const SizedBox.shrink();
      },
      builderLoading: (context) {
        return Center(
          child: Lottie.asset(
            ConstantIcons.mainLoader,
            width: 200,
            height: 200,
          ),
        );
      },
      builderLoaded: (context) {
        return const PaddingAll(
          20,
          child: SizedBox(
            width: double.infinity,
            child: AllTasksBody(),
          ),
        );
      },
    );
  }
}
