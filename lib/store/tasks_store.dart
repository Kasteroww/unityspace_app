import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/service/task_service.dart' as api;
import 'package:unityspace/utils/extensions/gstore_extension.dart';
import 'package:wstore/wstore.dart';

class TasksStore extends GStore {
  static TasksStore? _instance;

  factory TasksStore() => _instance ??= TasksStore._();

  TasksStore._();

  List<TaskHistory>? history;
  List<Task>? tasks;

  Future<int> getTasksHistory(int page) async {
    final response = await api.getMyTasksHistory(page);
    final maxPageCount = response.maxPageCount;
    _setHistory(response);
    _setTasks(response);
    return maxPageCount;
  }

  Task? getTaskById(int id) {
    return tasks?.firstWhereOrNull((element) => element.id == id);
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

  @override
  void clear() {
    super.clear();
    setStore(() {
      history = null;
      tasks = null;
    });
  }
}
