import 'package:unityspace/utils/http_plugin.dart';

class HttpException implements Exception {
  final String? message;
  final HttpPluginException? exception;

  HttpException([
    this.message,
    this.exception,
  ]);
}

class UserNameIsNotAStringHttpException extends HttpException {
  UserNameIsNotAStringHttpException([
    super.message,
    super.exception,
  ]);
}

class UserEmailAlreadyExistsHttpException extends HttpException {
  UserEmailAlreadyExistsHttpException([
    super.message,
    super.exception,
  ]);
}

class UserCannotProcessEmailHttpException extends HttpException {
  UserCannotProcessEmailHttpException([
    super.message,
    super.exception,
  ]);
}

class UserIncorrectEmailFormatHttpException extends HttpException {
  UserIncorrectEmailFormatHttpException([
    super.message,
    super.exception,
  ]);
}

class UserIncorrectConfirmationCodeHttpException extends HttpException {
  UserIncorrectConfirmationCodeHttpException([
    super.message,
    super.exception,
  ]);
}

class UserIncorrectOldPasswordHttpException extends HttpException {
  UserIncorrectOldPasswordHttpException([
    super.message,
    super.exception,
  ]);
}

class AuthUserAlreadyExistsHttpException extends HttpException {
  AuthUserAlreadyExistsHttpException([
    super.message,
    super.exception,
  ]);
}

class AuthIncorrectEmailHttpException extends HttpException {
  AuthIncorrectEmailHttpException([
    super.message,
    super.exception,
  ]);
}

class AuthIncorrectConfirmationCodeHttpException extends HttpException {
  AuthIncorrectConfirmationCodeHttpException([
    super.message,
    super.exception,
  ]);
}

class AuthIncorrectCredentialsHttpException extends HttpException {
  AuthIncorrectCredentialsHttpException([
    super.message,
    super.exception,
  ]);
}

class AuthUnauthorizedHttpException extends HttpException {
  AuthUnauthorizedHttpException([
    super.message,
    super.exception,
  ]);
}

class SpacesCannotAddPaidTariffHttpException extends HttpException {
  SpacesCannotAddPaidTariffHttpException([
    super.message,
    super.exception,
  ]);
}

class ReglamentsNotOrganizationOwnerHttpException extends HttpException {
  ReglamentsNotOrganizationOwnerHttpException([
    super.message,
    super.exception,
  ]);
}

class RequestFailed400HttpException extends HttpException {
  RequestFailed400HttpException([
    super.message,
    super.exception,
  ]);
}

class Unauthorized401HttpException extends HttpException {
  Unauthorized401HttpException([
    super.message,
    super.exception,
  ]);
}

class AccessForbidden403HttpException extends HttpException {
  AccessForbidden403HttpException([
    super.message,
    super.exception,
  ]);
}

class UserBlocked403HttpException extends HttpException {
  UserBlocked403HttpException([
    super.message,
    super.exception,
  ]);
}

class AddressDoesNotExist404HttpException extends HttpException {
  AddressDoesNotExist404HttpException([
    super.message,
    super.exception,
  ]);
}

class ServerUnavailable500HttpException extends HttpException {
  ServerUnavailable500HttpException([
    super.message,
    super.exception,
  ]);
}

class TooManyRequests500HttpException extends HttpException {
  TooManyRequests500HttpException([
    super.message,
    super.exception,
  ]);
}
