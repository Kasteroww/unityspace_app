import 'dart:convert';
import 'dart:typed_data';

import 'package:unityspace/models/auth_models.dart';
import 'package:unityspace/service/files_service.dart' as api_files;

import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/utils/http_plugin.dart';

Future<UserResponse> getUserData() async {
  final response = await HttpPlugin().get('/user/me');
  final jsonData = json.decode(response.body);
  final result = UserResponse.fromJson(jsonData);
  return result;
}

Future<OrganizationResponse> getOrganizationData() async {
  final response = await HttpPlugin().get('/user/organization');
  final jsonData = json.decode(response.body);
  final result = OrganizationResponse.fromJson(jsonData);
  return result;
}

Future<UserResponse> removeUserAvatar() async {
  final response = await HttpPlugin().patch('/user/removeAvatar');
  final jsonData = json.decode(response.body);
  final result = UserResponse.fromJson(jsonData);
  return result;
}

Future<UserResponse> setUserAvatar(final Uint8List avatarImage) async {
  final key = await api_files.uploadAvatarByChunks(file: avatarImage);
  final response = await HttpPlugin().post('/user/avatar', {
    'key': key,
  });
  final jsonData = json.decode(response.body);
  final result = UserResponse.fromJson(jsonData);
  return result;
}

Future<UserResponse> setUserName(final String userName) async {
  final response = await HttpPlugin().patch('/user/name', {
    'name': userName,
  });
  final jsonData = json.decode(response.body);
  final result = UserResponse.fromJson(jsonData);
  return result;
}

Future<OnlyTokensResponse> setUserPassword(
  final String oldPassword,
  final String newPassword,
) async {
  final response = await HttpPlugin().patch('/user/password', {
    'oldPassword': oldPassword,
    'password': newPassword,
  });
  final jsonData = json.decode(response.body);
  final result = OnlyTokensResponse.fromJson(jsonData);
  return result;
}

Future<UserResponse> setJobTitle(final String jobTitle) async {
  final response = await HttpPlugin().patch('/user/job-title', {
    'jobTitle': jobTitle,
  });
  final jsonData = json.decode(response.body);
  final result = UserResponse.fromJson(jsonData);
  return result;
}

Future<UserResponse> setPhone(final String phone) async {
  final response = await HttpPlugin().patch('/user/phoneNumber', {
    'phoneNumber': phone,
  });
  final jsonData = json.decode(response.body);
  final result = UserResponse.fromJson(jsonData);
  return result;
}

Future<UserResponse> setUserGitHubLink(final String githubLink) async {
  final response = await HttpPlugin().patch('/user/github-link', {
    'githubLink': githubLink,
  });
  final jsonData = json.decode(response.body);
  final result = UserResponse.fromJson(jsonData);
  return result;
}

Future<UserResponse> setUserTelegramLink(final String link) async {
  final response = await HttpPlugin().patch('/user/link', {
    'link': link,
  });
  final jsonData = json.decode(response.body);
  final result = UserResponse.fromJson(jsonData);
  return result;
}

Future<UserResponse> setUserBirthday(final String? date) async {
  final response = await HttpPlugin().patch('/user/edit-birthdate', {
    'birthDate': date,
  });
  final jsonData = json.decode(response.body);
  final result = UserResponse.fromJson(jsonData);
  return result;
}

Future<String?> requestEmailVerification({
  required String email,
  required bool isChangeEmail,
}) async {
  try {
    final response = await HttpPlugin().post(
        '/auth/request-email-verification/',
        {'email': email},
        {'change': isChangeEmail.toString()});
    return response.body;
  } catch (e) {
    if (e is HttpPluginException) {
      if (e.message == 'User is already exists') {
        return 'User already exists';
      } else if (e.message == 'Cannot process its email') {
        return 'Cannot process this email';
      } else {
        throw Exception(e.message);
      }
    }
    rethrow;
  }
}

Future confirmUserEmail(
    {required String email,
    required String code,
    required int userGlobalId,
    required int userId}) async {
  try {
    final response = await HttpPlugin().post('/auth/verify-email-change', {
      "email": email,
      "code": code,
      "userGlobalId": userGlobalId,
      "userId": userId
    });
    return response.body;
  } catch (e) {
    if (e is HttpPluginException) {
      return 'Code is incorrect';
    }
    rethrow;
  }
}
