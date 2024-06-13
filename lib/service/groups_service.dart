import 'dart:convert';

import 'package:unityspace/models/groups_models.dart';
import 'package:unityspace/service/service_exceptions.dart';
import 'package:unityspace/utils/http_plugin.dart';

Future<List<GroupResponse>> getGroups() async {
  try {
    final response = await HttpPlugin().get('/groups');
    final List<dynamic> jsonDataList = json.decode(response.body);
    return jsonDataList.map((data) => GroupResponse.fromJson(data)).toList();
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}
