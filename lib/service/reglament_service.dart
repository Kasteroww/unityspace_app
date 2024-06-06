import 'dart:convert';

import 'package:unityspace/models/reglament_models.dart';
import 'package:unityspace/service/service_exceptions.dart';
import 'package:unityspace/utils/helpers.dart';
import 'package:unityspace/utils/http_plugin.dart';

///Создание нового регламента
Future<ReglamentResponse> createReglament(
  String name,
  int columnId,
  String content, {
  double? order,
}) async {
  try {
    final response = await HttpPlugin().post('/reglaments', {
      'name': name,
      'reglamentColumnId': columnId,
      'content': content,
      if (order != null) 'order': convertToOrderRequest(order),
    });
    return ReglamentResponse.fromJson(
      jsonDecode(response.body),
    );
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

/// Запись в историю о действии с регламентом
Future<void> createReglamentSaveHistory({
  required int reglamentId,
  required String comment,
  required bool clearUsersPassed,
}) async {
  await HttpPlugin().post(
    '/reglaments/$reglamentId/history',
    {
      'comment': comment,
      'clearUsersPassed': clearUsersPassed,
    },
  );
}

/// Функция для получения всех регламентов
Future<List<ReglamentResponse>> getReglaments() async {
  try {
    final response = await HttpPlugin().get('/reglaments');
    final List jsonData = json.decode(response.body);
    return jsonData.map((data) => ReglamentResponse.fromJson(data)).toList();
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

/// Функция для изменения колонки и порядка регламента
Future<ChangeReglamentColumnAndOrderResponse> changeReglamentColumnAndOrder({
  required int reglamentId,
  required int columnId,
  required double order,
}) async {
  try {
    final response = await HttpPlugin().patch(
      '/reglaments/$reglamentId/changeReglamentColumnAndOrder',
      {
        'columnId': columnId,
        'order': convertToOrderRequest(order),
      },
    );
    final validated = ChangeReglamentColumnAndOrderResponse.fromJson(
      jsonDecode(response.body),
    );
    return validated;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<RenameReglamentResponse> renameReglament({
  required int reglamentId,
  required String name,
}) async {
  final response = await HttpPlugin().patch('/reglaments/$reglamentId/name', {
    'name': name,
  });
  final jsonData = await jsonDecode(response.body);
  return RenameReglamentResponse.fromJson(jsonData);
}

// Функция для удаления регламента
Future<DeleteReglamentResponse> deleteReglament({
  required int reglamentId,
}) async {
  try {
    final response = await HttpPlugin().delete(
      '/reglaments/$reglamentId',
    );
    final jsonData = await jsonDecode(response.body);
    return DeleteReglamentResponse.fromJson(jsonData);
  } catch (e) {
    if (e is HttpPluginException) {
      final responseBody = jsonDecode(e.message);
      if (responseBody == 'Not organization owner') {
        return throw ServiceException('Not organization owner');
      }
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<FullReglamentResponse> getFullReglament(int reglamentId) async {
  try {
    final response = await HttpPlugin().get('/reglaments/$reglamentId');
    final data = json.decode(response.body);
    return FullReglamentResponse.fromJson(data);
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<List<ReglamentQuestionResponse>> getReglamentsQuesions({
  required int reglamentId,
}) async {
  try {
    final response = await HttpPlugin().get(
      '/reglaments/$reglamentId/questions',
    );

    final List<dynamic> jsonData = json.decode(response.body);
    final List<ReglamentQuestionResponse> questions = jsonData
        .map((json) => ReglamentQuestionResponse.fromJson(json))
        .toList();

    return questions;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<ReglamentQuestionResponse> createReglamentQuestion({
  required String name,
  required int reglamentId,
}) async {
  try {
    final response =
        await HttpPlugin().post('/reglaments/$reglamentId/questions', {
      'name': name,
      'reglamentId': reglamentId,
    });
    final data = json.decode(response.body);
    return ReglamentQuestionResponse.fromJson(data);
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<ReglamentAnswerResponse> createReglamentAnswer({
  required int reglamentId,
  required int questionId,
  required String name,
}) async {
  final response = await HttpPlugin().post(
    '/reglaments/$reglamentId/questions/$questionId/answers',
    {name: name},
  );

  final data = json.decode(response.body);
  return ReglamentAnswerResponse.fromJson(data);
}

Future<ReglamentAnswerResponse> changeIsRightReglamentAnswerProperty({
  required int reglamentId,
  required int questionId,
  required int answerId,
  required bool isRight,
}) async {
  final response = await HttpPlugin().patch(
    '/reglaments/$reglamentId/questions/$questionId/answers/$answerId/isRight',
    {'isRight': isRight},
  );
  final data = json.decode(response.body);
  return ReglamentAnswerResponse.fromJson(data);
}

Future<ReglamentRequiredResponse> changeReglamentRequiredProperty({
  required int reglamentId,
  required bool required,
}) async {
  final response =
      await HttpPlugin().patch('/reglaments/$reglamentId/required', {
    'required': required,
  });
  final data = json.decode(response.body);
  return ReglamentRequiredResponse.fromJson(data);
}
