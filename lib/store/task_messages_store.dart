import 'package:unityspace/models/task_message_models.dart';
import 'package:unityspace/service/task_messages_service.dart' as api;
import 'package:wstore/wstore.dart';

class TaskMessages with GStoreChangeObjectMixin {
  final Map<int, TaskMessage> _taskMessagesMap = {};

  TaskMessages();

  void add(TaskMessage taskMessage) {
    _setTaskMessage(taskMessage);
    incrementObjectChangeCount();
  }

  void addAll(Iterable<TaskMessage> all) {
    if (all.isNotEmpty) {
      for (final taskMessage in all) {
        _setTaskMessage(taskMessage);
      }
      incrementObjectChangeCount();
    }
  }

  void remove(int taskMessageId) {
    _removeTaskMessage(taskMessageId);
    incrementObjectChangeCount();
  }

  void clear() {
    if (_taskMessagesMap.isNotEmpty) {
      _taskMessagesMap.clear();
      incrementObjectChangeCount();
    }
  }

  void _setTaskMessage(TaskMessage task) {
    _removeTaskMessage(task.id);
    _taskMessagesMap[task.id] = task;
  }

  void _removeTaskMessage(int id) {
    _taskMessagesMap.remove(id);
  }

  TaskMessage? operator [](int id) => _taskMessagesMap[id];

  Iterable<TaskMessage> get iterable => _taskMessagesMap.values;

  int get length => _taskMessagesMap.length;
}

class TaskMessagesStore extends GStore {
  static TaskMessagesStore? _instance;

  factory TaskMessagesStore() => _instance ??= TaskMessagesStore._();

  TaskMessagesStore._();

  TaskMessages taskMessages = TaskMessages();

  Future<void> getMessages({required int taskId}) async {
    final response = await api.getMessages(taskId: taskId);
    final allTasks =
        response.map((res) => TaskMessage.fromResponse(res)).toList();
    setStore(() {
      // задачи в сторе перезаписываются полученными
      taskMessages.addAll(allTasks);
    });
  }

  void empty() {
    setStore(() {
      taskMessages.clear();
    });
  }
}
