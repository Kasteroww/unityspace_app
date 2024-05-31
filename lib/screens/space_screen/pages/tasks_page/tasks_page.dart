import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/widgets/all_tasks_body.dart';
import 'package:unityspace/screens/widgets/common/paddings.dart';
import 'package:unityspace/store/project_store.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/tasks_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/constants.dart';
import 'package:unityspace/utils/errors.dart';
import 'package:unityspace/utils/helpers.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

enum TaskGrouping {
  byProject,
  byDate,
  byUser,
  noGroup,
}

enum TaskFilter {
  onlyActive,
  onlyCompleted,
  allTasks,
}

enum TaskSort {
  byDate,
  byStatus,
  byImportance,
  defaultSort,
}

class TasksPageStore extends WStore {
  // GENERAL
  TasksErrors error = TasksErrors.none;
  WStoreStatus status = WStoreStatus.init;
  TasksStore tasksStore = TasksStore();
  ProjectStore projectsStore = ProjectStore();
  SpacesStore spacesStore = SpacesStore();
  int spaceId = 0;

  TaskGrouping groupingType = TaskGrouping.byUser;

  // SEARCHING
  final SearchTaskErrors searchError = SearchTaskErrors.none;
  String searchString = '';

  /// режим поиска, от него зависит отображается ли
  /// результат поиска или список всех задач
  bool isSearching = false;

  /// геттер задач из TasksStore
  List<Task> get tasks => computedFromStore(
        store: tasksStore,
        getValue: (store) => store.tasks ?? [],
        keyName: 'tasks',
      );
  List<ITasksGroup> get tasksToDisplay {
    switch (groupingType) {
      case TaskGrouping.byProject:
        return _tasksByProject(isSearching ? searchedTasks : tasks);
      case TaskGrouping.byUser:
        return _tasksByUser(isSearching ? searchedTasks : tasks);
      case TaskGrouping.byDate:
        return _tasksByDate(isSearching ? searchedTasks : tasks);
      default:
        return _tasksByProject(isSearching ? searchedTasks : tasks);
    }
  }

  List<Task> searchedTasks = [];

  List<TasksProjectGroup> get tasksByProject => _tasksByProject(tasks);

  List<TasksDateGroup> get tasksByDate => _tasksByDate(tasks);

  List<TasksProjectGroup> get searchTasksByProject =>
      _tasksByProject(searchedTasks);

  void setSearchString(String value) {
    setStore(() {
      searchString = value;
    });
  }

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
    return projectsStore.getProjectById(projectId)?.name;
  }

  /// поиск задач по строке
  Future<void> searchTasks() async {
    tasksStore.clearSearchedTasksStateLocally();
    if (searchString.isNotEmpty) {
      setStore(() {
        isSearching = true;
      });

      final searchResult = tasks.where((task) {
        return task.stages.any((taskStage) {
              final Project? project =
                  projectsStore.projectsMap[taskStage.projectId];
              return project != null && project.spaceId == spaceId;
            }) &&
            (searchString.isEmpty ||
                task.name.toLowerCase().contains(searchString.toLowerCase()));
      }).toList();
      setStore(() {
        searchedTasks = searchResult;
      });
    } else {
      setStore(() {
        isSearching = false;
      });
    }
  }

  /// группирует задачи по проектам
  List<TasksProjectGroup> _tasksByProject(List<Task>? tasks) {
    final List<TasksProjectGroup> group = [];
    if (tasks != null && tasks.isNotEmpty) {
      for (final Task task in tasks) {
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
            final project = projectsStore.projectsMap[taskStage.projectId];
            final space =
                project != null ? spacesStore.spacesMap[spaceId] : null;
            final SpaceColumn? column = project != null
                ? spacesStore.columnsMap[project.columnId]
                : null;
            if (project != null && space != null && column != null) {
              if (spaceId == 0 || spaceId == space.id) {
                group.add(
                  TasksProjectGroup(
                    id: project.id,
                    spaceOrder: space.order.toInt(),
                    spaceFavorite: space.favorite ? 1 : 0,
                    spaceId: space.id,
                    projectOrder: project.order,
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

  List<TasksUserGroup> _tasksByUser(List<Task>? tasks) {
    final List<TasksUserGroup> group = [];

    if (tasks != null && tasks.isNotEmpty) {
      for (final Task task in tasks) {
        for (final int id in task.responsibleUsersId) {
          final userGroup = group.firstWhereOrNull((user) => user.id == id);
          if (userGroup != null) {
            userGroup.tasks.add(task);
          } else {
            group.add(
              TasksUserGroup(
                id: id,
                userId: id,
                groupTitle: getUserNameById(userId: id),
                tasks: [task],
              ),
            );
          }
        }
        if (task.responsibleUsersId.isEmpty) {
          final userGroup = group.firstWhereOrNull((user) => user.id == -1);
          if (userGroup != null) {
            userGroup.tasks.add(task);
          } else {
            group.add(
              TasksUserGroup(
                id: -1,
                userId: null,
                groupTitle: 'Нет ответственного',
                tasks: [task],
              ),
            );
          }
        }
      }
    }
    group.sort((a, b) {
      if (b.id < 0 && a.id >= 0) return -1;
      if (b.id >= 0 && a.id < 0) return 1;
      return a.groupTitle.compareTo(b.groupTitle);
    });
    return group;
  }

  List<TasksDateGroup> _tasksByDate(List<Task>? tasks) {
    List<TasksDateGroup> groups = [];
    if (tasks != null && tasks.isNotEmpty) {
      final List<Task> tasksWithoutDate = [];
      final List<Task> todayTasks = [];
      final List<Task> tomorrowTasks = [];
      final List<Task> overdueTasks = [];
      final List<Task> futureTasks = [];

      final todayDate = dateFromDateTime(DateTime.now());
      final tomorrowDate =
          DateTime(todayDate.year, todayDate.month, todayDate.day + 1);

      for (final Task task in tasks) {
        DateTime? taskDateEnd;

        if (task.dateEnd != null) {
          taskDateEnd = task.dateEnd;
        }

        if (taskDateEnd == null) {
          tasksWithoutDate.add(task);
        } else if (dateFromDateTime(taskDateEnd) == todayDate) {
          todayTasks.add(task);
        } else if (dateFromDateTime(taskDateEnd) == tomorrowDate) {
          tomorrowTasks.add(task);
        } else if (dateFromDateTime(taskDateEnd).isBefore(todayDate)) {
          overdueTasks.add(task);
        } else if (dateFromDateTime(taskDateEnd).isAfter(tomorrowDate)) {
          futureTasks.add(task);
        } else {
          tasksWithoutDate.add(task);
        }
      }
      groups = [
        TasksDateGroup(id: 1, groupTitle: 'Сегодня', tasks: todayTasks),
        TasksDateGroup(id: 2, groupTitle: 'Завтра', tasks: tomorrowTasks),
        TasksDateGroup(id: 3, groupTitle: 'Просрочено', tasks: overdueTasks),
        TasksDateGroup(id: 4, groupTitle: 'На будущее', tasks: futureTasks),
        TasksDateGroup(id: 5, groupTitle: 'Без даты', tasks: tasksWithoutDate),
      ];
    }
    return groups;
  }

  String getUserNameById({required int userId}) {
    final user = UserStore().organizationMembersMap[userId];
    if (user == null) {
      return 'Пользователя нет';
    }
    return user.name;
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
