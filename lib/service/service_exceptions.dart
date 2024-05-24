class ServiceException implements Exception {
  final String? message;
  ServiceException([this.message]);
}

class UserUnauthorizedServiceException extends ServiceException {
  UserUnauthorizedServiceException([super.message]);
}

class UserNameIsNotAStringServiceException extends ServiceException {
  UserNameIsNotAStringServiceException([super.message]);
}

class UserEmailAlreadyExistsServiceException extends ServiceException {
  UserEmailAlreadyExistsServiceException([super.message]);
}

class UserCannotProcessEmailServiceException extends ServiceException {
  UserCannotProcessEmailServiceException([super.message]);
}

class UserIncorrectEmailFormatServiceException extends ServiceException {
  UserIncorrectEmailFormatServiceException([super.message]);
}

class UserIncorrectConfirmationCodeServiceException extends ServiceException {
  UserIncorrectConfirmationCodeServiceException([super.message]);
}

class UserIncorrectOldPasswordServiceException extends ServiceException {
  UserIncorrectOldPasswordServiceException([super.message]);
}

class AuthUserAlreadyExistsServiceException extends ServiceException {
  AuthUserAlreadyExistsServiceException([super.message]);
}

class AuthIncorrectEmailServiceException extends ServiceException {
  AuthIncorrectEmailServiceException([super.message]);
}

class AuthTooManyMessagesServiceException extends ServiceException {
  AuthTooManyMessagesServiceException([super.message]);
}

class AuthIncorrectConfirmationCodeServiceException extends ServiceException {
  AuthIncorrectConfirmationCodeServiceException([super.message]);
}

class AuthIncorrectCredentialsServiceException extends ServiceException {
  AuthIncorrectCredentialsServiceException([super.message]);
}

class AuthUnauthorizedServiceException extends ServiceException {
  AuthUnauthorizedServiceException([super.message]);
}

class SpacesCannotAddPaidTariffServiceException extends ServiceException {
  SpacesCannotAddPaidTariffServiceException([super.message]);
}
