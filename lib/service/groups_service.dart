import 'dart:convert';

import 'package:unityspace/models/groups_models.dart';
import 'package:unityspace/service/exceptions/handlers.dart';
import 'package:unityspace/service/exceptions/service_exceptions.dart';
import 'package:unityspace/utils/http_plugin.dart';

Future<List<GroupResponse>> getGroups() async {
  try {
    final response = await HttpPlugin().get('/groups');
    final List<dynamic> jsonDataList = json.decode(response.body);
    return jsonDataList.map((data) => GroupResponse.fromJson(data)).toList();
  } catch (e) {
    if (e is HttpPluginException) {
      handleDefaultHttpExceptions(e);
    }
    rethrow;
  }
}

Future<UpdateGroupNameResponse> updateGroupName({
  required int id,
  required String newName,
}) async {
  try {
    final response = await HttpPlugin().patch(
      '/groups/$id/name',
      {'name': newName},
    );
    if (response.body.isEmpty) {
      throw EmptyResponseServiceException(
        message: '''
                  Failed to update spaces group name. 
                  Expected JSON response with the new name
                  and the group id, 
                  but received an empty response.
                  ''',
        response: response,
      );
    }
    return UpdateGroupNameResponse.fromJson(json.decode(response.body));
  } catch (e) {
    if (e is HttpPluginException) {
      handleDefaultHttpExceptions(e);
    }
    rethrow;
  }
}
