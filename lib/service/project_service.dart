import 'dart:convert';

import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/service/service_exceptions.dart';
import 'package:unityspace/utils/helpers.dart';
import 'package:unityspace/utils/http_plugin.dart';

Future<List<ProjectResponse>> getProjects({required int spaceId}) async {
  try {
    final response = await HttpPlugin().get('/spaces/$spaceId/projects');
    final jsonDataList = json.decode(response.body) as List<dynamic>;
    final result =
        jsonDataList.map((data) => ProjectResponse.fromJson(data)).toList();
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<List<ProjectResponse>> getAllProjects() async {
  try {
    final response = await HttpPlugin().get('/projects/all-projects');
    final jsonDataList = json.decode(response.body) as List<dynamic>;
    final result =
        jsonDataList.map((data) => ProjectResponse.fromJson(data)).toList();
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

/// Архивация и разархивация Проектов
Future<List<ProjectResponse>> changeProjectColumn({
  required List<int> projectIds,
  required int columnId,
}) async {
  try {
    final response = await HttpPlugin()
        .patch('/projects/changeColumn/$columnId', {'projectIds': projectIds});
    final List jsonData = json.decode(response.body);
    return jsonData
        .map((element) => ProjectResponse.fromJson(element))
        .toList();
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<ProjectResponse> addProject(AddProject project) async {
  try {
    final response = await HttpPlugin().post('/projects', project.toJson());
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return ProjectResponse.fromJson(jsonData);
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<Map<String, dynamic>> deleteProject(int projectId) async {
  try {
    // приходит только статус и сообщение
    final response = await HttpPlugin().delete('/projects/$projectId');
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return jsonData;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

/// Добавление Проекта в избранное и Удаление
Future<Map<String, dynamic>> setProjectFavorite({
  required int projectId,
  required bool favorite,
}) async {
  try {
    // приходит userId, projectId, favorite
    final response = await HttpPlugin().patch(
      '/user-preference/set-project-favorite',
      {
        'projectId': projectId,
        'favorite': favorite,
      },
    );
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return jsonData;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

/// Изменение названия, цвета, ответственного Проекта
/// и через сколько отмечать задачи Проекта как неактивные
Future<ProjectResponse> updateProject({
  required int id,
  required String name,
  int postponingTaskDayCount = 0,
  String? color,
  int? responsibleId,
}) async {
  try {
    final response = await HttpPlugin().patch(
      '/projects/$id',
      {
        'name': name,
        'color': color,
        'responsibleId': responsibleId,
        'postponingTaskDayCount': postponingTaskDayCount,
      },
    );
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return ProjectResponse.fromJson(jsonData);
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<ProjectStageResponse> createProjectStage({
  required int projectId,
  required String name,
  required double order,
}) async {
  try {
    final response = await HttpPlugin().post('/projects/$projectId/stages', {
      'name': name,
      'order': convertToOrderRequest(order),
      'tasks': [],
      'projectId': projectId,
    });

    final result = json.decode(response.body);

    return ProjectStageResponse.fromJson(result);
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

/// Создание элемента tab панели проекта
Future<ProjectEmbedResponse> createProjectEmbed({
  required int projectId,
  required String name,
  required String url,
  required String category,
}) async {
  try {
    final response = await HttpPlugin().post(
      '/projects/$projectId/embed',
      {
        'name': name,
        'url': url,
        'category': category,
      },
    );
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return ProjectEmbedResponse.fromJson(jsonData);
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

/// Отображение элемента tab панели проекта "Документация"
Future<Map<String, dynamic>> showProjectReviewTab({
  required int projectId,
  required bool show,
}) async {
  try {
    final response = await HttpPlugin().patch(
      '/projects/$projectId/showProjectReviewTab',
      {
        'show': show,
      },
    );
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return jsonData;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

/// Обновление элемента tab панели проекта
Future<Map<String, dynamic>> updateProjectEmbed({
  required int projectId,
  required int embedId,
  required ProjectEmbed embed,
}) async {
  try {
    final response = await HttpPlugin()
        .patch('projects/$projectId/embed/$embedId', embed.toJson());
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return jsonData;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}
