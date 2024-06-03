import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/resources/constants.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/utils/enums.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/widgets/divider.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/widgets/grouped_tasks_list.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/widgets/popup_filter_button.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/widgets/popup_grouping_button.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/widgets/popup_sort_button.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/widgets/tasks_list.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/paddings.dart';
import 'package:unityspace/store/projects_store.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/tasks_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/helpers.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

/// extension с методом локализации
/// для каждого возможного значения TaskGrouping
/// возвращает его локализованное значение

class TasksPageStore extends WStore {
  // GENERAL
  TasksErrors error = TasksErrors.none;
  WStoreStatus status = WStoreStatus.init;
  TasksStore tasksStore = TasksStore();
  ProjectsStore projectsStore = ProjectsStore();
  SpacesStore spacesStore = SpacesStore();
  int spaceId = 0;

  // FILTERING, GROUPING, SORTING
  // default values
  TaskGrouping groupingType = TaskGrouping.byProject;
  TaskSort sortType = TaskSort.defaultSort;
  TaskFilter filterType = TaskFilter.onlyActive;

  // SEARCHING
  final SearchTaskErrors searchError = SearchTaskErrors.none;
  String searchString = '';
  List<Task> searchedTasks = [];

  /// режим поиска, от него зависит отображается ли
  /// результат поиска или список всех задач
  bool isSearching = false;

  /// геттер задач из TasksStore
  List<Task> get tasks => computedFromStore(
        store: tasksStore,
        getValue: (store) => store.tasks ?? [],
        keyName: 'tasks',
      );

  List<ITasksGroup> get groupedTasks {
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

  List<TasksProjectGroup> get tasksByProject => _tasksByProject(tasks);

  List<TasksDateGroup> get tasksByDate => _tasksByDate(tasks);

  List<TasksProjectGroup> get searchTasksByProject =>
      _tasksByProject(searchedTasks);

  void setSearchString(String value) {
    setStore(() {
      searchString = value;
    });
  }

  void setGroupingType(TaskGrouping value) {
    setStore(() {
      groupingType = value;
    });
  }

  void setSortType(TaskSort value) {
    setStore(() {
      sortType = value;
    });
  }

  void setFilterType(TaskFilter value) {
    setStore(() {
      filterType = value;
    });
    getTasksByFilter(filterType);
  }

  String? getProjectNameById(int projectId) {
    return projectsStore.getProjectById(projectId)?.name;
  }

  String getUserNameById({required int userId}) {
    final user = UserStore().organizationMembersMap[userId];
    if (user == null) {
      return 'Пользователя нет';
    }
    return user.name;
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

  /// получение информации о колонках в проектах по
  /// TaskStages stages в задаче
  TaskStageWithOrder getStageName({
    required List<TaskStages> stages,
    int? projectId,
  }) {
    // если известнен id проета, то подходящая колонка только одна
    if (projectId != null) {
      final taskStage = stages.firstWhereOrNull(
        (stage) => stage.projectId == projectId,
      );
      final stage =
          taskStage != null ? projectsStore.stagesMap[taskStage.stageId] : null;
      if (stage == null || taskStage == null) {
        return TaskStageWithOrder(
          stageName: '',
          stagesOrder: 0,
          taskOrder: 0,
        );
      }
      return TaskStageWithOrder(
        stageName: stage.name,
        stagesOrder: stage.order,
        taskOrder: taskStage.order,
      );
    }
    // если projectId неизвестен, данные берутся для всех колонок
    final stagesPropsArrays = stages.fold(
      (
        stagesNames: <String>[],
        stagesOrders: <int>[],
        taskOrders: <int>[],
      ),
      (acc, taskStage) {
        final stage = projectsStore.stagesMap[taskStage.stageId];
        if (stage != null) {
          acc.stagesNames.add(stage.name);
          acc.stagesOrders.add(stage.order);
          acc.taskOrders.add(taskStage.order);
        }
        return acc;
      },
    );

    return TaskStageWithOrder(
      stageName: stagesPropsArrays.stagesNames.join(', '),
      stagesOrder: stagesPropsArrays.stagesOrders.fold(0, (a, b) => a + b),
      taskOrder: stagesPropsArrays.taskOrders.fold(0, (a, b) => a + b),
    );
  }

  List<SortedTask> sortTasks(List<Task> tasks) {
    final List<SortedTask> sortedTasks = tasks.map(
      (task) {
        final stageParams = getStageName(stages: task.stages);
        return SortedTask(
          id: task.id,
          task: task,
          stageName: stageParams.stageName,
          stageOrder: stageParams.stagesOrder,
          taskOrder: stageParams.taskOrder,
        );
      },
    ).toList();
    sortedTasks.sort((a, b) {
      if (sortType == TaskSort.byDate) {
        if (a.task.dateEnd == null && b.task.dateEnd != null) {
          return 1;
        } else if (a.task.dateEnd != null && b.task.dateEnd == null) {
          return -1;
        } else if (a.task.dateEnd == null || b.task.dateEnd == null) {
          return 0;
        } else {
          final DateTime aDate = dateFromDateTime(a.task.dateEnd!);
          final DateTime bDate = dateFromDateTime(b.task.dateEnd!);

          final int compareByDate = aDate.difference(bDate).inDays;
          if (compareByDate != 0) return compareByDate;
        }
      } else if (sortType == TaskSort.byStatus) {
        final compareByStatus = a.task.status - b.task.status;
        if (compareByStatus != 0) return compareByStatus;
      } else if (sortType == TaskSort.byImportance) {
        final compareByImportance =
            b.task.importance.value - a.task.importance.value;
        if (compareByImportance != 0) return compareByImportance;
      }
      final compareByStageNames = a.stageName.compareTo(b.stageName);
      if (compareByStageNames != 0) return compareByStageNames;
      final compareByStagesOrder = a.stageOrder - b.stageOrder;
      if (compareByStagesOrder != 0) return compareByStagesOrder;
      final compareByTaskOrder = a.taskOrder - b.taskOrder;
      if (compareByTaskOrder != 0) return compareByTaskOrder;
      return 0;
    });
    return sortedTasks;
  }

  /// получение задач по фильтрам
  Future<void> getTasksByFilter(TaskFilter filter) async {
    switch (filter) {
      case TaskFilter.onlyActive:
        await loadTasks(statuses: [TaskStatuses.inWork.value]);
      case TaskFilter.onlyCompleted:
        await loadTasks(
          statuses: [TaskStatuses.completed.value, TaskStatuses.rejected.value],
        );
      case TaskFilter.allTasks:
        await loadTasks(
          statuses: [
            TaskStatuses.inWork.value,
            TaskStatuses.completed.value,
            TaskStatuses.rejected.value,
          ],
        );
      default:
        await loadTasks(statuses: [TaskStatuses.inWork.value]);
    }
  }

  /// загрузка задач по пространству и статусам
  Future<void> loadTasks({List<int>? statuses}) async {
    if (status == WStoreStatus.loading) return;
    setStore(() {
      status = WStoreStatus.loading;
      error = TasksErrors.none;
    });
    try {
      await tasksStore.getSpaceTasks(
        spaceId: spaceId,
        statuses: statuses ?? [TaskStatuses.inWork.value],
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
    ..loadTasks();

  @override
  Widget build(BuildContext context, TasksPageStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
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
        return PaddingAll(
          20,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Flexible(
                            child:
                                WStoreValueBuilder<TasksPageStore, TaskFilter>(
                              watch: (store) => store.filterType,
                              builder: (BuildContext context, value) {
                                return PopupTaskFilterButton(
                                  value: value,
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Flexible(
                            child: WStoreValueBuilder<TasksPageStore, TaskSort>(
                              watch: (store) => store.sortType,
                              builder: (BuildContext context, value) {
                                return PopUpTaskSortButton(
                                  value: value,
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Flexible(
                            child: WStoreValueBuilder<TasksPageStore,
                                TaskGrouping>(
                              watch: (store) => store.groupingType,
                              builder: (BuildContext context, value) {
                                return PopUpTaskGroupingButton(
                                  value: value,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: AddDialogInputField(
                        labelText: localization.find,
                        onChanged: (value) {
                          context
                              .wstore<TasksPageStore>()
                              .setSearchString(value);
                        },
                        onEditingComplete: () {
                          context.wstore<TasksPageStore>().searchTasks();
                        },
                      ),
                    ),
                  ],
                ),
                const PaddingTop(20),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Text(
                          localization.task_name,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                      const DividerWithoutPadding(
                        isHorisontal: false,
                        color: ColorConstants.grey04,
                      ),
                      Flexible(
                        flex: 2,
                        child: PaddingLeft(
                          8,
                          child: Text(
                            localization.column,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const DividerWithoutPadding(
                  color: ColorConstants.grey04,
                ),
                Expanded(
                  child: WStoreBuilder<TasksPageStore>(
                    builder: (context, store) {
                      if (store.groupingType == TaskGrouping.noGroup) {
                        return TasksList(tasks: store.sortTasks(store.tasks));
                      } else {
                        return GroupedTasksList(
                          tasksList:
                              context.wstore<TasksPageStore>().groupedTasks,
                        );
                      }
                    },
                    watch: (store) => [store.sortType],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
