import 'dart:convert';

import 'package:unityspace/models/auth_models.dart';
import 'package:unityspace/service/service_exceptions.dart';
import 'package:unityspace/utils/http_plugin.dart';

Future<RegisterResponse> register({
  required final String email,
  required final String password,
}) async {
  try {
    final response = await HttpPlugin().post('/auth/register', {
      'email': email,
      'password': password,
    });
    final jsonData = json.decode(response.body);
    final result = RegisterResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      if (e.message == 'User is already exists') {
        throw AuthUserAlreadyExistsServiceException();
      }
      if (e.message == 'incorrect or non-exist Email') {
        throw AuthIncorrectEmailServiceException();
      }
      if (e.statusCode == 500 && e.message.contains('554')) {
        throw AuthTooManyMessagesServiceException();
      }
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<OnlyTokensResponse> confirmEmail({
  required final String email,
  required final String code,
}) async {
  try {
    final response =
        await HttpPlugin().post('/auth/verify-email-registration', {
      'email': email,
      'code': code,
      'referrer': null,
    });
    final jsonData = json.decode(response.body);
    final result = OnlyTokensResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      if (e.message == 'Error while verifying email') {
        throw AuthIncorrectConfirmationCodeServiceException();
      }
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<OnlyTokensResponse> login({
  required final String email,
  required final String password,
}) async {
  try {
    final response = await HttpPlugin().post('/auth/login', {
      'email': email,
      'password': password,
    });
    final jsonData = json.decode(response.body);
    final result = OnlyTokensResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      if (e.message == 'Credentials incorrect') {
        throw AuthIncorrectCredentialsServiceException();
      }
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<void> signOut({
  required final String refreshToken,
  required final int globalUserId,
}) async {
  try {
    await HttpPlugin().patch('/auth/logout', {
      'refreshToken': refreshToken,
      'userId': globalUserId,
    });
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<OnlyTokensResponse> refreshAccessToken({
  required final String refreshToken,
}) async {
  try {
    final response = await HttpPlugin().get('/auth/refresh', {
      'refreshToken': refreshToken,
    });
    final jsonData = json.decode(response.body);
    final result = OnlyTokensResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      if (e.statusCode == 401) {
        throw AuthUnauthorizedServiceException();
      }
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<void> restorePasswordByEmail({
  required final String email,
}) async {
  try {
    await HttpPlugin().post('/auth/reset-password', {
      'email': email,
    });
  } catch (e) {
    if (e is HttpPluginException) {
      if (e.message == 'Credentials incorrect') {
        throw AuthIncorrectCredentialsServiceException();
      }
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<GoogleAuthResponse> googleAuth({
  required final String credential,
}) async {
  try {
    final response = await HttpPlugin().post('/google/auth', {
      'credential': credential,
      'inviteToken': '',
      'referrer': null,
    });
    final jsonData = json.decode(response.body);
    final result = GoogleAuthResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}
