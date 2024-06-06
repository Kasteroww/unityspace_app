import 'dart:convert';

import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/service/service_exceptions.dart';
import 'package:unityspace/utils/http_plugin.dart';

Future<List<SpaceResponse>> getSpacesData() async {
  try {
    final response = await HttpPlugin().get('/spaces');
    final jsonDataList = json.decode(response.body) as List<dynamic>;
    final result =
        jsonDataList.map((data) => SpaceResponse.fromJson(data)).toList();
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<SpaceResponse> createSpaces(final String title, final int order) async {
  try {
    final response =
        await HttpPlugin().post('/spaces', {'name': title, 'order': order});
    final jsonData = json.decode(response.body);
    final result = SpaceResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      if (e.message ==
          'Cannot add more spaces, check paid tariff or remove spaces') {
        throw SpacesCannotAddPaidTariffServiceException();
      }
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future removeUserFromSpace(final int spaceId, final int memberId) async {
  try {
    await HttpPlugin().delete('/spaces/$spaceId/members/$memberId');
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}
