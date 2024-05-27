import 'dart:convert';

import 'package:unityspace/models/reglament_models.dart';
import 'package:unityspace/service/service_exceptions.dart';
import 'package:unityspace/utils/http_plugin.dart';

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
  required int order,
}) async {
  try {
    final response = await HttpPlugin().patch(
      '/$reglamentId/changeReglamentColumnAndOrder',
      {
        'columnId': columnId,
        'order': order,
      },
    );
    final validated = ChangeReglamentColumnAndOrderResponse.fromJson(
        jsonDecode(response.body));
    return validated;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

// Функция для удаления регламента
Future<DeleteReglamentResponse> deleteReglament(int reglamentId) async {
  try {
    final response = await HttpPlugin().delete(
      '/reglaments/$reglamentId',
    );

    if (response.statusCode == 200) {
      final jsonData = await jsonDecode(response.body);
      return DeleteReglamentResponse.fromFson(jsonData);
    } else {
      throw Exception('Failed to delete reglament');
    }
  } catch (e) {
    if (e is HttpPluginException) {
      final responseBody = jsonDecode(e.message);
      if (responseBody == 'Not organization owner') {
        return Future.error('Not organization owner');
      }
    }
    rethrow;
  }
}
