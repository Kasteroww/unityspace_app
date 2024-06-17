import 'dart:collection';

import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/service/task_service.dart' as api;
import 'package:unityspace/utils/extensions/gstore_extension.dart';
import 'package:unityspace/utils/helpers.dart';
import 'package:wstore/wstore.dart';

class TasksStore extends GStore {
  static TasksStore? _instance;

  factory TasksStore() => _instance ??= TasksStore._();

  TasksStore._();

  List<TaskHistory>? history;
  List<Task>? tasks;
  List<Task> searchedTasks = [];

  Map<int, Task> get tasksMap {
    return createMapById(tasks);
  }

  Map<int, TaskHistory> get historyMap {
    return createMapById(history);
  }

  /// Создание задачи в проекте
  Future<int> createTask({
    required String name,
    required int stageId,
    double? order,
    String? color,
    String? dateBegin,
    String? dateEnd,
    bool? createTaskAbove,
  }) async {
    if (name.isEmpty) {
      return 0;
    }
    final taskResponse = await api.createTask(
      name: name,
      stageId: stageId,
      order: order,
      color: color,
      dateBegin: dateBegin,
      dateEnd: dateEnd,
      createTaskAbove: createTaskAbove,
    );

    final newTask = Task.fromResponse(taskResponse.task);
    final newHistory = TaskHistory.fromResponse(taskResponse.history);

    setStore(() {
      tasks = List<Task>.from(
        updateLocally(
          [newTask],
          tasksMap,
        ),
      );
      history = List<TaskHistory>.from(
        updateLocally(
          [newHistory],
          historyMap,
        ),
      );
    });

    return taskResponse.task.id;
  }

  Future<void> deleteTaskFromStage({
    required int taskId,
    required int stageId,
  }) async {
    final deleteTaskResponse =
        await api.deleteTaskFromStage(taskId: taskId, stageId: stageId);

    final deletedTask = Task.fromResponse(deleteTaskResponse.task);
    final newHistory = TaskHistory.fromResponse(deleteTaskResponse.history);

    setStore(() {
      tasks = List<Task>.from(
        deleteLocally(
          deletedTask,
          tasksMap,
        ),
      );
      history = List<TaskHistory>.from(
        updateLocally(
          [newHistory],
          historyMap,
        ),
      );
    });
  }

  Future<void> moveTaskDownOfStage({
    required int taskId,
    required int currentStageId,
    required Task? lastTask,
  }) async {
    final lastOrder = lastTask?.stages.last.order;
    if (lastOrder == null) {
      return;
    }
    final newOrder = lastOrder + 1;
    final response = await api.moveTask(
      taskId: taskId,
      currentStageId: currentStageId,
      newStageId: currentStageId,
      newOrder: newOrder,
    );

    final movedTask = Task.fromResponse(response);
    final newListTasks = List<Task>.from(
      updateLocally(
        [
          // Удаляем старую запись по id
          ...deleteLocally(movedTask, tasksMap),
          movedTask,
        ],
        tasksMap,
      ),
    );

    setStore(() {
      tasks = newListTasks;
    });
  }

  Future<void> moveTaskUpOfStage({
    required int taskId,
    required int currentStageId,
    required Task? firstTask,
  }) async {
    final firstOrder = firstTask?.stages.first.order;
    if (firstOrder == null) {
      return;
    }
    final newOrder = firstOrder - 1;

    final response = await api.moveTask(
      taskId: taskId,
      currentStageId: currentStageId,
      newStageId: currentStageId,
      newOrder: newOrder,
    );

    final movedTask = Task.fromResponse(response);
    final newListTasks = List<Task>.from(
      updateLocally(
        [
          movedTask,
          ...deleteLocally(movedTask, tasksMap),
        ],
        tasksMap,
      ),
    );

    setStore(() {
      tasks = newListTasks;
    });
  }

  Future<int> getTasksHistory(int page) async {
    final response = await api.getMyTasksHistory(page);
    final maxPageCount = response.maxPageCount;
    _setHistory(response);
    _setTasks(response);
    return maxPageCount;
  }

  Task? getTaskById(int id) {
    return tasksMap[id];
  }

  void _setTasks(MyTaskHistoryResponse response) {
    final tasksResponse = response.tasks;
    final List<Task> tasksList =
        tasksResponse.map((res) => Task.fromResponse(res)).toList();
    final HashMap<int, Task>? tasksMap = tasks != null
        ? HashMap.fromIterable(
            tasks!,
            key: (element) => element is Task ? element.id : throw Exception,
            value: (element) => element,
          )
        : null;

    setStore(() {
      if (tasksMap == null || tasksMap.isEmpty) {
        tasks = tasksList;
      } else {
        final List<Task> updatedTasksList =
            List<Task>.from(updateLocally(tasksList, tasksMap));
        tasks = updatedTasksList;
      }
    });
  }

  void _setHistory(MyTaskHistoryResponse response) {
    final historyResponse = response.history;
    final historyPage =
        historyResponse.map((res) => TaskHistory.fromResponse(res)).toList();

    final HashMap<int, TaskHistory>? historyMap = history != null
        ? HashMap.fromIterable(
            history!,
            key: (element) => element is TaskHistory
                ? element.id
                : throw Exception('Value has wrong type'),
            value: (element) => element,
          )
        : null;

    setStore(() {
      if (historyMap == null || historyMap.isEmpty) {
        history = historyPage;
      } else {
        final List<TaskHistory> updatedHistoryList =
            List<TaskHistory>.from(updateLocally(historyPage, historyMap));

        updatedHistoryList.sort((a, b) => a.updateDate.compareTo(b.updateDate));
        history = updatedHistoryList.reversed.toList();
      }
    });
  }

  /// получение задач по spaceId и статусам
  Future<List<Task>> getSpaceTasks({
    required int spaceId,
    required List<int> statuses,
  }) async {
    final List<TaskResponse> tasksResponse =
        await api.getSpaceTasks(spaceId: spaceId, statuses: statuses);
    final allTasks =
        tasksResponse.map((res) => Task.fromResponse(res)).toList();
    setStore(() {
      // задачи в сторе перезаписываются полученными
      tasks = allTasks;
    });
    return allTasks;
  }

  /// Получение задач в конкретном проекте по projectID
  Future<List<Task>> getProjectTasks({
    required int projectId,
  }) async {
    final List<TaskResponse> tasksResponse =
        await api.getProjectTasks(projectId: projectId);
    final allTasks =
        tasksResponse.map((res) => Task.fromResponse(res)).toList();
    setStore(() {
      // задачи в сторе перезаписываются полученными
      tasks = allTasks;
    });
    return allTasks;
  }

  void clearSearchedTasksStateLocally() {
    setStore(() {
      searchedTasks = [];
    });
  }

  void empty() {
    setStore(() {
      history = null;
      tasks = null;
      searchedTasks = [];
    });
  }
}
