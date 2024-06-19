import 'dart:convert';

import 'package:unityspace/models/task_message_models.dart';
import 'package:unityspace/service/exceptions/handlers.dart';
import 'package:unityspace/utils/http_plugin.dart';

Future<List<MessageResponse>> getMessages({required int taskId}) async {
  try {
    final response = await HttpPlugin().get(
      '/tasks/$taskId/messages',
    );
    final List jsonData = json.decode(response.body);
    return jsonData.map((data) => MessageResponse.fromJson(data)).toList();
  } catch (e) {
    if (e is HttpPluginException) {
      handleDefaultHttpExceptions(e);
    }
    rethrow;
  }
}
