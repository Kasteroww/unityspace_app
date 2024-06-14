import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/service/task_service.dart' as api;
import 'package:wstore/wstore.dart';

class TaskDetailStore extends GStore {
  static TaskDetailStore? _instance;

  factory TaskDetailStore() => _instance ??= TaskDetailStore._();

  TaskDetailStore._();

  Task? task;

  /// Подгрузка данных о таске
  Future<void> loadTaskById(int taskId) async {
    final response = await api.getTaskById(taskId: taskId);

    _updateTaskLocally(response);
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
      task = newTask;
    });
  }
}
