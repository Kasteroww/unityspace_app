enum NotificationErrors { none, loadingDataError }

enum ActionsErrors { none, loadingDataError }

enum FormatErrors { none, incorrectDateFormat, incorrectColorFormat }

enum UserAuthErrors { none, incorrectOldPassword, noAccessToken }

enum PaidTariffErrors { none, paidTariffError }

enum EmailErrors {
  none(''),
  incorrectEmailAddress('Некорректная почта'),
  emailAlreadyExists('Такая почта уже зарегистрирована'),
  cannotSendEmail('Ошибка отправки, попробуйте позже'),
  unknown('Неизвестная ошибка, попробуйте позже');

  final String localization;

  const EmailErrors(this.localization);
}

enum CodeConfimationErrors {
  none(''),
  incorrectCode('Неверный код'),
  unknown('Неизвестная ошибка, попробуйте позже');

  final String localization;

  const CodeConfimationErrors(this.localization);
}

enum ImageErrors { none, imageIsEmpty }

enum TextErrors { none, textIsEmpty }

enum LinkErrors { none, linkIsEmpty, couldNotLaunch }

enum ProjectErrors { none, loadingDataError }
