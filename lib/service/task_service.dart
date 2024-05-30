import 'dart:convert';

import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/service/service_exceptions.dart';
import 'package:unityspace/utils/http_plugin.dart';

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

/// получение задач по spaceId и статусам
Future getSpaceTasks({
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
