import 'package:unityspace/service/data_exceptions.dart';

class RegisterResponse {
  final String status;
  final String message;

  RegisterResponse({
    required this.status,
    required this.message,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> jsonData) {
    try {
      return RegisterResponse(
        status: jsonData['status'] as String,
        message: jsonData['message'] as String,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class ResetPasswordResponse {
  final String status;
  final String message;

  ResetPasswordResponse({
    required this.status,
    required this.message,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> jsonData) {
    try {
      return ResetPasswordResponse(
        status: jsonData['status'] as String,
        message: jsonData['message'] as String,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class OnlyTokensResponse {
  final String accessToken;
  final String refreshToken;

  const OnlyTokensResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory OnlyTokensResponse.fromJson(Map<String, dynamic> jsonData) {
    try {
      return OnlyTokensResponse(
        accessToken: jsonData['access_token'].toString(),
        refreshToken: jsonData['refresh_token'].toString(),
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class GoogleAuthResponse {
  final OnlyTokensResponse tokens;
  final bool registered;
  final String? picture;
  final int? spaceId;

  const GoogleAuthResponse({
    required this.tokens,
    required this.registered,
    required this.picture,
    required this.spaceId,
  });

  factory GoogleAuthResponse.fromJson(Map<String, dynamic> jsonData) {
    try {
      return GoogleAuthResponse(
        tokens: OnlyTokensResponse.fromJson(
          jsonData['tokens'] as Map<String, dynamic>,
        ),
        registered: jsonData['registered'] as bool,
        picture: jsonData['picture'] as String?,
        spaceId: jsonData['spaceId'] as int?,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens(this.accessToken, this.refreshToken);
}
