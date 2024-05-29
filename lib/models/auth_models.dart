class RegisterResponse {
  final String status;
  final String message;

  RegisterResponse({
    required this.status,
    required this.message,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> jsonData) {
    return RegisterResponse(
      status: jsonData['status'] as String,
      message: jsonData['message'] as String,
    );
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
    return ResetPasswordResponse(
      status: jsonData['status'] as String,
      message: jsonData['message'] as String,
    );
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
    return OnlyTokensResponse(
      accessToken: jsonData['access_token'].toString(),
      refreshToken: jsonData['refresh_token'].toString(),
    );
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
    return GoogleAuthResponse(
      tokens: OnlyTokensResponse.fromJson(
        jsonData['tokens'] as Map<String, dynamic>,
      ),
      registered: jsonData['registered'] as bool,
      picture: jsonData['picture'] as String?,
      spaceId: jsonData['spaceId'] as int?,
    );
  }
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens(this.accessToken, this.refreshToken);
}
