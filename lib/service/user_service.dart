import 'dart:convert';
import 'dart:typed_data';

import 'package:unityspace/models/achievement_models.dart';
import 'package:unityspace/models/auth_models.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/service/files_service.dart' as api_files;
import 'package:unityspace/service/service_exceptions.dart';
import 'package:unityspace/utils/http_plugin.dart';

Future<UserResponse> getUserData() async {
  try {
    final response = await HttpPlugin().get('/user/me');
    final jsonData = json.decode(response.body);
    final result = UserResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      if (e.statusCode == 401) {
        throw UserUnauthorizedServiceException();
      }
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<OrganizationResponse> getOrganizationData() async {
  try {
    final response = await HttpPlugin().get('/user/organization');
    final jsonData = json.decode(response.body);
    final result = OrganizationResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      if (e.statusCode == 401) {
        throw UserUnauthorizedServiceException();
      }
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<UserResponse> removeUserAvatar() async {
  try {
    final response = await HttpPlugin().patch('/user/removeAvatar');
    final jsonData = json.decode(response.body);
    final result = UserResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<UserResponse> setUserAvatar(final Uint8List avatarImage) async {
  try {
    final key = await api_files.uploadAvatarByChunks(file: avatarImage);
    final response = await HttpPlugin().post('/user/avatar', {
      'key': key,
    });
    final jsonData = json.decode(response.body);
    final result = UserResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<UserResponse> setUserName(final String userName) async {
  try {
    final response = await HttpPlugin().patch('/user/name', {
      'name': userName,
    });
    final jsonData = json.decode(response.body);
    final result = UserResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      if (e.statusCode == 401) {
        throw UserUnauthorizedServiceException();
      } else if (e.statusCode == 400 && e.message == 'name must be a string') {
        throw UserNameIsNotAStringServiceException();
      }
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<OnlyTokensResponse> setUserPassword(
  final String oldPassword,
  final String newPassword,
) async {
  try {
    final response = await HttpPlugin().patch('/user/password', {
      'oldPassword': oldPassword,
      'password': newPassword,
    });
    final jsonData = json.decode(response.body);
    final result = OnlyTokensResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      if (e.message == 'Credentials incorrect') {
        throw UserIncorrectOldPasswordServiceException();
      }
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<UserResponse> setJobTitle(final String jobTitle) async {
  try {
    final response = await HttpPlugin().patch('/user/job-title', {
      'jobTitle': jobTitle,
    });
    final jsonData = json.decode(response.body);
    final result = UserResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<UserResponse> setPhone(final String phone) async {
  try {
    final response = await HttpPlugin().patch('/user/phoneNumber', {
      'phoneNumber': phone,
    });
    final jsonData = json.decode(response.body);
    final result = UserResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<UserResponse> setUserGitHubLink(final String githubLink) async {
  try {
    final response = await HttpPlugin().patch('/user/github-link', {
      'githubLink': githubLink,
    });
    final jsonData = json.decode(response.body);
    final result = UserResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<UserResponse> setUserTelegramLink(final String link) async {
  try {
    final response = await HttpPlugin().patch('/user/link', {
      'link': link,
    });
    final jsonData = json.decode(response.body);
    final result = UserResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<UserResponse> setUserBirthday(final String? date) async {
  try {
    final response = await HttpPlugin().patch('/user/edit-birthdate', {
      'birthDate': date,
    });
    final jsonData = json.decode(response.body);
    final result = UserResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<String?> requestEmailVerification({
  required String email,
  required bool isChangeEmail,
}) async {
  try {
    final response = await HttpPlugin().post(
      '/auth/request-email-verification/',
      {'email': email},
      {'change': isChangeEmail.toString()},
    );
    return response.body;
  } catch (e) {
    if (e is HttpPluginException) {
      if (e.message == 'User is already exists') {
        throw UserEmailAlreadyExistsServiceException();
      } else if (e.message == 'Cannot process its email') {
        throw UserCannotProcessEmailServiceException();
      } else if (e.message == 'email must be an email') {
        throw UserIncorrectEmailFormatServiceException();
      } else {
        throw ServiceException(e.message);
      }
    }
    rethrow;
  }
}

Future confirmUserEmail({
  required String newEmail,
  required String code,
}) async {
  try {
    final response = await HttpPlugin().post('/auth/verify-email-change', {
      'newEmail': newEmail,
      'code': code,
    });
    return response.body;
  } catch (e) {
    if (e is HttpPluginException) {
      if (e.statusCode == 400 && e.message == 'Error while verifying email') {
        throw UserIncorrectConfirmationCodeServiceException();
      }
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<List<AchievementResponse>> getAchievements() async {
  try {
    final response = await HttpPlugin().get('/achievements');

    return (jsonDecode(response.body) as List)
        .map((e) => AchievementResponse.fromJson(e))
        .toList();
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<UserResponse> setIsAdmin(
  int memberId,
  bool isAdmin,
) async {
  try {
    final response = await HttpPlugin()
        .patch('user/is-admin/$memberId', {'isAdmin': isAdmin});
    final jsonData = json.decode(response.body);
    final result = UserResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}
