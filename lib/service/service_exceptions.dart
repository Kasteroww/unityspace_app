class ServiceException implements Exception {
  final String? message;
  ServiceException([this.message]);
}

class UserUnauthorizedException extends ServiceException {
  UserUnauthorizedException([super.message]);
}

class UserNameIsNotAStringException extends ServiceException {
  UserNameIsNotAStringException([super.message]);
}

class UserEmailAlreadyExistsException extends ServiceException {
  UserEmailAlreadyExistsException([super.message]);
}

class UserCannotProcessEmailException extends ServiceException {
  UserCannotProcessEmailException([super.message]);
}

class UserIncorrectEmailFormatException extends ServiceException {
  UserIncorrectEmailFormatException([super.message]);
}

class UserIncorrectConfirmationCodeException extends ServiceException {
  UserIncorrectConfirmationCodeException([super.message]);
}

class UserIncorrectOldPasswordException extends ServiceException {
  UserIncorrectOldPasswordException([super.message]);
}

class AuthUserAlreadyExistsException extends ServiceException {
  AuthUserAlreadyExistsException([super.message]);
}

class AuthIncorrectEmailException extends ServiceException {
  AuthIncorrectEmailException([super.message]);
}

class AuthTooManyMessagesException extends ServiceException {
  AuthTooManyMessagesException([super.message]);
}

class AuthIncorrectConfirmationCodeException extends ServiceException {
  AuthIncorrectConfirmationCodeException([super.message]);
}

class AuthIncorrectCredentialsException extends ServiceException {
  AuthIncorrectCredentialsException([super.message]);
}

class AuthUnauthorizedException extends ServiceException {
  AuthUnauthorizedException([super.message]);
}

class SpacesCannotAddPaidTariffException extends ServiceException {
  SpacesCannotAddPaidTariffException([super.message]);
}
