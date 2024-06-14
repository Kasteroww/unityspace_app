enum NotificationErrors { none, loadingDataError }

enum ActionsErrors { none, loadingDataError }

enum FormatErrors { none, incorrectDateFormat, incorrectColorFormat }

enum UserAuthErrors { none, incorrectOldPassword, noAccessToken }

enum PaidTariffErrors { none, paidTariffError }

enum EmailErrors {
  none,
  incorrectEmailAddress,
  emailAlreadyExists,
  cannotSendEmail,
  unknown;
}

enum CodeConfimationErrors {
  none,
  incorrectCode,
  unknown;
}

enum ImageErrors { none, imageIsEmpty }

enum TextErrors { none, textIsEmpty }

enum LinkErrors { none, linkIsEmpty, couldNotLaunch }

enum ProjectErrors { none, loadingDataError }

enum TasksErrors { none, loadingDataError }

enum SpaceMembersErrors { none, loadingDataError }

enum SearchTaskErrors { none }

enum AddProjectTabErrors { none, addProjectTabError, valueIsEmpty }

enum ChangeProjectTabErrors { none, changeProjectTabError, valueIsEmpty }

enum DeleteProjectTabErrors { none, deleteProjectTabError }

enum CreateProjectErrors { none, emptyName, createError }

enum AddSpaceErrors { none, emptyName, paidTariffError, createError }

enum ChangeGitHubLinkErrors { none, invalidLink, changeLinkError }

enum ChangeNameErrors { none, emptyName, changeNameError }

enum ChangePasswordErrors {
  none,
  emptyPassword,
  lengthAtLeast8,
  passwordsDoNotMatch,
  matchesOldPassword,
  changePasswordError,
  incorrectOldPassword
}

enum ChangeTgLinkErrors { none, invalidLink, changeLinkError }

enum LoginByEmailErrors { none, loginError, invalidEmailOrPassword }

enum RenameReglamentErrors { none, emptyName, problemUploadingData }

enum RegistrationErrors {
  none,
  emailAlreadyExists,
  createAccountError,
  incorrectEmail,
  overloadedService
}

enum RestorePasswordErrors { none, restoreError, accountDoesNotExist }

enum MoveProjectErrors { none, columnIdIsNull, moveProjectError }

enum EditProjectPropertiesErrors { none, savePropertiesError }

enum AddReglamentErrors { none, emptyName, problemUploadingData }

enum DuplicateReglamentErrors { none, emptyName, problemUploadingData }

enum ConfirmEmailErrors { none, confirmEmailError, incorrectCode }

enum DrawerErrors { none, groupsLoadingError, drawerError }

enum ProjectBoardsErrors { none, loadingDataError, createStageError }
