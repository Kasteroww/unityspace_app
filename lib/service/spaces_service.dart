import 'dart:convert';

import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/service/service_exceptions.dart';
import 'package:unityspace/utils/helpers.dart';
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

Future<SpaceResponse> createSpaces(
  final String title,
  final double order,
) async {
  try {
    final response = await HttpPlugin().post(
      '/spaces',
      {
        'name': title,
        'order': convertToOrderRequest(order),
      },
    );
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

Future<SpaceColumnResponse> createSpaceColumn({
  required int spaceId,
  required String name,
  required double order,
}) async {
  try {
    final response = await HttpPlugin().post(
      '/spaces/$spaceId/columns/',
      {
        'name': name,
        'order': convertToOrderRequest(order),
      },
    );
    final jsonData = json.decode(response.body);

    return SpaceColumnResponse.fromJson(jsonData);
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<RemoveMemberFromSpaceResponse> removeUserFromSpace(
  final int spaceId,
  final int memberId,
) async {
  try {
    final response =
        await HttpPlugin().delete('/spaces/$spaceId/members/$memberId');
    final jsonData = json.decode(response.body);
    final result = RemoveMemberFromSpaceResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<RemoveMemberFromSpaceResponse> removeInviteFromSpace({
  required int spaceId,
  required int inviteId,
}) async {
  try {
    final response = await HttpPlugin().delete(
      '/spaces/$spaceId/invite/remove',
      {
        'id': inviteId,
      },
    );
    final jsonData = json.decode(response.body);
    final result = RemoveMemberFromSpaceResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}
