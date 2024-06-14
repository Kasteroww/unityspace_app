import 'dart:convert';

import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/service/service_exceptions.dart';
import 'package:unityspace/utils/helpers.dart';
import 'package:unityspace/utils/http_plugin.dart';

Future<CreateTaskResponse> createTask({
  required String name,
  required int stageId,
  double? order,
  String? color,
  String? dateBegin,
  String? dateEnd,
  bool? createTaskAbove,
}) async {
  try {
    final data = {
      'name': name,
      'stageId': stageId,
      'color': color,
      'dateBegin': dateBegin,
      'dateEnd': dateEnd,
    };

    if (order != null) {
      data['order'] = convertToOrderRequest(order);
    }

    final response = await HttpPlugin().post(
      '/tasks',
      data,
      {
        'toTop': createTaskAbove,
      },
    );

    final result = json.decode(response.body);

    return CreateTaskResponse.fromJson(result);
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<MyTaskHistoryResponse> getMyTasksHistory(int page) async {
  try {
    final response = await HttpPlugin().get('/tasks/myHistory/$page');
    final jsonDataList = json.decode(response.body);
    final MyTaskHistoryResponse result =
        MyTaskHistoryResponse.fromJson(jsonDataList);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

/// Получение задач во всем пространстве по spaceId и статусам
Future<List<TaskResponse>> getSpaceTasks({
  required int spaceId,
  required List<int> statuses,
}) async {
  try {
    final response = await HttpPlugin()
        .get('/spaces/$spaceId/tasks', {'statuses': statuses.join(', ')});
    final List<dynamic> jsonDataList = json.decode(response.body);
    // с сервера приходит список
    return jsonDataList.map((data) => TaskResponse.fromJson(data)).toList();
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

/// Получение задач в конкретном проекте по projectID
Future getProjectTasks({
  required int projectId,
}) async {
  try {
    final response = await HttpPlugin().get(
      '/projects/$projectId/tasks',
    );
    final List<dynamic> jsonDataList = json.decode(response.body);
    // с сервера приходит список
    return jsonDataList.map((data) => TaskResponse.fromJson(data)).toList();
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<DeleteTaskResponse> deleteTaskFromStage({
  required int taskId,
  required int stageId,
}) async {
  try {
    final response = await HttpPlugin().delete(
      '/tasks/$taskId/stages/$stageId',
    );
    final result = json.decode(response.body);
    return DeleteTaskResponse.fromJson(result);
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<TaskResponse> moveTask({
  required int taskId,
  required int currentStageId,
  required int newStageId,
  required double newOrder,
}) async {
  try {
    final payload = {
      'stageId': newStageId,
      'order': convertToOrderRequest(newOrder),
    };

    final response = await HttpPlugin().patch(
      '/tasks/$taskId/stages/$currentStageId',
      payload,
    );
    final result = json.decode(response.body) as Map<String, dynamic>;
    final task = result['task'];
    if (task == null) {
      throw Exception('Cant move task in stage');
    }
    return TaskResponse.fromJson(task);
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<TaskResponse> getTaskById({
  required int taskId,
}) async {
  try {
    final response = await HttpPlugin().get(
      '/tasks/$taskId',
    );
    final result = json.decode(response.body) as Map<String, dynamic>;
    final task = result;
    return TaskResponse.fromJson(task);
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<TaskResponse> addTaskResponsible({
  required int taskId,
  required int responsibleId,
}) async {
  try {
    final payload = {
      'newResponsibleId': responsibleId,
    };

    final response = await HttpPlugin().post(
      '/tasks/$taskId/addTaskResponsible',
      payload,
    );
    final result = json.decode(response.body) as Map<String, dynamic>;
    final task = result['task'];
    if (task == null) {
      throw Exception('Cant add responsible');
    }
    return TaskResponse.fromJson(task);
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<TaskResponse> deleteTaskResponsible({
  required int taskId,
  required int responsibleId,
}) async {
  try {
    final response = await HttpPlugin().delete(
      '/tasks/$taskId/deleteTaskResponsible/$responsibleId',
    );
    final result = json.decode(response.body) as Map<String, dynamic>;
    final task = result['task'];
    if (task == null) {
      throw Exception('Cant delete responsible');
    }
    return TaskResponse.fromJson(task);
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<TaskResponse> updateTaskResponsible({
  required int taskId,
  required int currentResponsibleId,
  required int responsibleId,
}) async {
  try {
    final payload = {
      'currentResponsibleId': currentResponsibleId,
      'newResponsibleId': responsibleId,
    };

    final response = await HttpPlugin().patch(
      '/tasks/$taskId/updateTaskResponsible',
      payload,
    );
    final result = json.decode(response.body) as Map<String, dynamic>;
    final task = result['task'];
    if (task == null) {
      throw Exception('Cant update responsible');
    }
    return TaskResponse.fromJson(task);
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}
