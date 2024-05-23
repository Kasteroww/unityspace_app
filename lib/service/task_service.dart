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
