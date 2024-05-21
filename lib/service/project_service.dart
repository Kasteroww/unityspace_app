import 'dart:convert';

import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/utils/http_plugin.dart';

Future<List<ProjectResponse>> getProjects({required int spaceId}) async {
  final response = await HttpPlugin().get('/spaces/$spaceId/projects');
  final jsonDataList = json.decode(response.body) as List<dynamic>;
  final result =
      jsonDataList.map((data) => ProjectResponse.fromJson(data)).toList();
  return result;
}
