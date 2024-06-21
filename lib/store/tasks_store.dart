import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/service/task_service.dart' as api;
import 'package:wstore/wstore.dart';

class Tasks with GStoreChangeObjectMixin {
  final Map<int, Task> _tasksMap = {};

  Tasks();

  void add(Task task) {
    _setTask(task);
    incrementObjectChangeCount();
  }

  void addAll(Iterable<Task> all) {
    if (all.isNotEmpty) {
      for (final task in all) {
        _setTask(task);
      }
      incrementObjectChangeCount();
    }
  }

  void remove(int taskId) {
    _removeTask(taskId);
    incrementObjectChangeCount();
  }

  void clear() {
    if (_tasksMap.isNotEmpty) {
      _tasksMap.clear();
      incrementObjectChangeCount();
    }
  }

  void _setTask(Task task) {
    _removeTask(task.id);
    _tasksMap[task.id] = task;
  }

  void _removeTask(int id) {
    _tasksMap.remove(id);
  }

  Task? operator [](int id) => _tasksMap[id];

  Iterable<Task> get iterable => _tasksMap.values;

  int get length => _tasksMap.length;
}

class Histories with GStoreChangeObjectMixin {
  final Map<int, TaskHistory> _historyMap = {};

  Histories();

  void add(TaskHistory history) {
    _setHistory(history);
    incrementObjectChangeCount();
  }

  void addAll(Iterable<TaskHistory> all) {
    if (all.isNotEmpty) {
      for (final history in all) {
        _setHistory(history);
      }
      incrementObjectChangeCount();
    }
  }

  void remove(int historyId) {
    _removeHistory(historyId);
    incrementObjectChangeCount();
  }

  void clear() {
    if (_historyMap.isNotEmpty) {
      _historyMap.clear();
      incrementObjectChangeCount();
    }
  }

  void _setHistory(TaskHistory history) {
    _removeHistory(history.id);
    _historyMap[history.id] = history;
  }

  void _removeHistory(int id) {
    _historyMap.remove(id);
  }

  TaskHistory? operator [](int id) => _historyMap[id];

  Iterable<TaskHistory> get iterable => _historyMap.values;

  int get length => _historyMap.length;
}

class TasksStore extends GStore {
  static TasksStore? _instance;

  factory TasksStore() => _instance ??= TasksStore._();

  TasksStore._();

  Histories histories = Histories();
  Tasks tasks = Tasks();
  List<Task> searchedTasks = [];

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
      tasks.add(newTask);
      histories.add(newHistory);
    });

    return taskResponse.task.id;
  }

  Future<void> deleteTask({
    required int taskId,
  }) async {
    final deleteTaskResponse = await api.deleteTask(
      taskId: taskId,
    );

    final deletedTask = Task.fromResponse(deleteTaskResponse.task);
    final newHistory = TaskHistory.fromResponse(deleteTaskResponse.history);

    setStore(() {
      tasks.remove(deletedTask.id);
      histories.add(newHistory);
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

    setStore(() {
      tasks.add(movedTask);
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
    setStore(() {
      tasks.add(movedTask);
    });
  }

  Future<int> getTasksHistory(int page) async {
    final response = await api.getMyTasksHistory(page);
    final maxPageCount = response.maxPageCount;
    _setHistory(response);
    _setTasks(response);
    return maxPageCount;
  }

  Future<void> getTaskHistory({required int taskId}) async {
    final historyData = await api.getTaskHistory(taskId);
    final List<TaskHistory> newHistory = historyData
        .map((historyResponse) => TaskHistory.fromResponse(historyResponse))
        .toList();
    setStore(() {
      histories.addAll(newHistory);
    });
  }

  void _setTasks(MyTaskHistoryResponse response) {
    final tasksResponse = response.tasks;
    final List<Task> tasksList =
        tasksResponse.map((res) => Task.fromResponse(res)).toList();
    setStore(() {
      tasks.addAll(tasksList);
    });
  }

  void _setHistory(MyTaskHistoryResponse response) {
    final historyResponse = response.history;
    final historyPage =
        historyResponse.map((res) => TaskHistory.fromResponse(res)).toList();
    setStore(() {
      histories.addAll(historyPage);
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
      tasks.addAll(allTasks);
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
      tasks.addAll(allTasks);
    });
    return allTasks;
  }

  void clearSearchedTasksStateLocally() {
    setStore(() {
      searchedTasks = [];
    });
  }

  /// Добавляем исполнителя
  Future<void> addTaskResponsible({
    required int taskId,
    required int responsibleId,
  }) async {
    final response = await api.addTaskResponsible(
      taskId: taskId,
      responsibleId: responsibleId,
    );

    _updateTaskLocally(response);
  }

  /// Удаляем выбранного исполнителя
  Future<void> deleteTaskResponsible({
    required int taskId,
    required int responsibleId,
  }) async {
    final response = await api.deleteTaskResponsible(
      taskId: taskId,
      responsibleId: responsibleId,
    );

    _updateTaskLocally(response);
  }

  /// Обновляем текущего исполнителя
  Future<void> updateTaskResponsible({
    required int taskId,
    required int currentResponsibleId,
    required int responsibleId,
  }) async {
    final response = await api.updateTaskResponsible(
      taskId: taskId,
      currentResponsibleId: currentResponsibleId,
      responsibleId: responsibleId,
    );

    _updateTaskLocally(response);
  }

  void _updateTaskLocally(TaskResponse taskResponse) {
    final newTask = Task.fromResponse(taskResponse);
    setStore(() {
      tasks.add(newTask);
    });
  }

  void empty() {
    setStore(() {
      histories.clear();
      tasks.clear();
      searchedTasks = [];
    });
  }
}
