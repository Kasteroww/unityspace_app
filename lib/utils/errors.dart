enum NotificationErrors { none, loadingDataError }

enum ActionsErrors { none, loadingDataError }

enum FormatErrors { none, incorrectDateFormat, incorrectColorFormat }

enum UserAuthErrors { none, incorrectOldPassword, noAccessToken }

enum PaidTariffErrors { none, paidTariffError }

enum EmailErrors {
  none,
  incorrectEmailAddress,
  emailAlreadyExists,
  cannotSendEmail
}

enum CodeConfimationErrors {
  none,
  incorrectCode,
}

enum ImageErrors { none, imageIsEmpty }

enum TextErrors { none, textIsEmpty }

enum LinkErrors { none, linkIsEmpty, couldNotLaunch }

enum ProjectErrors { none, loadingDataError }
