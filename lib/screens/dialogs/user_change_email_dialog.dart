import 'package:flutter/material.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/screens/widgets/paddings.dart';
import 'package:unityspace/service/exceptions/http_exceptions.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

Future<void> showChangeEmailDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (_) {
      return const ChangeEmailDialog();
    },
  );
}

class ChangeEmailDialogStore extends WStore {
  WStoreStatus statusEmail = WStoreStatus.init;
  EmailErrors emailError = EmailErrors.none;
  bool isChangeEmail = false;
  String newEmail = '';

  UserStore userStore = UserStore();

  User? get currentUser => computedFromStore(
        store: userStore,
        getValue: (store) => store.user,
        keyName: 'currentUser',
      );

  String get currentUserEmail => computed(
        getValue: () => currentUser?.email ?? '',
        watch: () => [currentUser],
        keyName: 'currentUserEmail',
      );

  void setNewEmail(String value) {
    setStore(() {
      newEmail = value.trim();
    });
  }

  void _setErrorChangeUserEmail(EmailErrors error) {
    setStore(() {
      isChangeEmail = false;
      statusEmail = WStoreStatus.error;
      emailError = error;
    });
  }

  Future<void> changeUserEmail(String email) async {
    if (isChangeEmail) return;
    setStore(() {
      isChangeEmail = true;
      statusEmail = WStoreStatus.loading;
    });
    try {
      final requestEmailVerify = await UserStore()
          .requestEmailVerification(email: email, isChangeEmail: true);
      if (requestEmailVerify == null) {
        _setErrorChangeUserEmail(EmailErrors.incorrectEmailAddress);
      }
      setStore(() {
        isChangeEmail = false;
        statusEmail = WStoreStatus.loaded;
        emailError = EmailErrors.none;
        newEmail = email;
      });
    } catch (e) {
      if (e is UserEmailAlreadyExistsHttpException) {
        _setErrorChangeUserEmail(EmailErrors.emailAlreadyExists);
      } else if (e is UserCannotProcessEmailHttpException) {
        _setErrorChangeUserEmail(EmailErrors.cannotSendEmail);
      } else if (e is UserIncorrectEmailFormatHttpException) {
        _setErrorChangeUserEmail(EmailErrors.incorrectEmailAddress);
      } else if (e is HttpException) {
        _setErrorChangeUserEmail(EmailErrors.unknown);
      }
    }
  }

  @override
  ChangeEmailDialog get widget => super.widget as ChangeEmailDialog;
}

class ChangeEmailDialog extends WStoreWidget<ChangeEmailDialogStore> {
  const ChangeEmailDialog({
    super.key,
  });

  @override
  ChangeEmailDialogStore createWStore() => ChangeEmailDialogStore();

  @override
  Widget build(BuildContext context, ChangeEmailDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    final fieldKey = GlobalKey<FormFieldState>();
    return WStoreStatusBuilder<ChangeEmailDialogStore>(
      store: store,
      watch: (store) => store.statusEmail,
      onStatusLoaded: (context) {
        if (context.mounted) {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
          showConfirmEmailDialog(context, newEmail: store.newEmail);
        }
      },
      builder: (context, status) {
        final loading = status == WStoreStatus.loading;
        final error = status == WStoreStatus.error;
        return AppDialogWithButtons(
          title: localization.change_email,
          primaryButtonText: localization.save,
          onPrimaryButtonPressed: () {
            FocusScope.of(context).unfocus();
            store.changeUserEmail(store.newEmail);
          },
          primaryButtonLoading: loading,
          secondaryButtonText: '',
          children: [
            AddDialogInputField(
              fieldKey: fieldKey,
              labelText: localization.enter_new_email,
              autofocus: true,
              initialValue: store.currentUserEmail,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value.isEmpty) {
                  return localization.email_cannot_be_empty;
                } else if (!isValidEmail(value)) {
                  return localization.incorrect_email_format;
                } else if (value == store.currentUserEmail) {
                  return localization.emails_are_the_same;
                }
                return '';
              },
              onChanged: (value) => store.setNewEmail(value),
              onEditingComplete: () {
                final bool isValidated =
                    fieldKey.currentState?.validate() ?? false;
                if (isValidated) {
                  FocusScope.of(context).unfocus();
                  store.changeUserEmail(store.newEmail);
                }
              },
            ),
            if (error)
              Text(
                switch (store.emailError) {
                  EmailErrors.incorrectEmailAddress =>
                    localization.email_is_incorrect,
                  EmailErrors.emailAlreadyExists =>
                    localization.this_email_already_exists,
                  EmailErrors.cannotSendEmail =>
                    localization.error_while_sending_try_later,
                  EmailErrors.unknown => localization.unknown_error_try_later,
                  EmailErrors.none => '',
                },
                style: const TextStyle(
                  color: Color(0xFFD83400),
                ),
              ),
          ],
        );
      },
    );
  }

  bool isValidEmail(String email) {
    return RegExp(r'\S+@\S+\.\S+').hasMatch(email);
  }
}

Future<void> showConfirmEmailDialog(
  BuildContext context, {
  required String newEmail,
}) async {
  return showDialog(
    context: context,
    builder: (_) {
      return ConfirmEmailDialog(newEmail: newEmail);
    },
  );
}

class ConfirmEmailDialogStore extends WStore {
  WStoreStatus codeStatus = WStoreStatus.init;
  CodeConfimationErrors codeError = CodeConfimationErrors.none;
  bool isShowConfirm = false;

  String code = '';

  UserStore userStore = UserStore();
  SpacesStore spacesStore = SpacesStore();

  User? get currentUser => computedFromStore(
        store: userStore,
        getValue: (store) => store.user,
        keyName: 'currentUser',
      );

  int get currentUserId => computed(
        getValue: () => currentUser?.id ?? 0,
        watch: () => [currentUser],
        keyName: 'currentUserId',
      );

  int get currentUserGlobalId => computed(
        getValue: () => currentUser?.globalId ?? 0,
        watch: () => [currentUser],
        keyName: 'currentUserGlobalId',
      );

  void setCode(String value) {
    setStore(() {
      code = value.trim();
    });
  }

  Future<void> confirmEmail({
    required String email,
    required String code,
  }) async {
    if (currentUser == null) return;
    setStore(() {
      codeStatus = WStoreStatus.loading;
    });
    try {
      await userStore.confirmEmail(
        email: email,
        code: code,
        userGlobalId: currentUserGlobalId,
        userId: currentUserId,
      );
      codeStatus = WStoreStatus.loaded;
      if (currentUser != null) {
        _updateEmailLocally(email: email, userId: currentUserId);
      }
      setStore(() {
        isShowConfirm = true;
      });
    } catch (e) {
      if (e is UserIncorrectConfirmationCodeHttpException) {
        setStore(() {
          codeStatus = WStoreStatus.error;
          codeError = CodeConfimationErrors.incorrectCode;
        });
      }
      setStore(() {
        codeStatus = WStoreStatus.error;
        codeError = CodeConfimationErrors.unknown;
      });
    }
  }

  void _updateEmailLocally({required String email, required int userId}) {
    userStore.changeEmailLocally(newEmail: email);
    userStore.changeMemberEmailLocally(userId: userId, newEmail: email);
    spacesStore.changeSpaceMemberEmailLocally(newEmail: email, userId: userId);
  }

  @override
  ConfirmEmailDialog get widget => super.widget as ConfirmEmailDialog;
}

class ConfirmEmailDialog extends WStoreWidget<ConfirmEmailDialogStore> {
  const ConfirmEmailDialog({
    required this.newEmail,
    super.key,
  });

  final String newEmail;

  @override
  ConfirmEmailDialogStore createWStore() => ConfirmEmailDialogStore();

  @override
  Widget build(BuildContext context, ConfirmEmailDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStatusBuilder<ConfirmEmailDialogStore>(
      store: store,
      watch: (store) => store.codeStatus,
      onStatusLoaded: (context) {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, status) {
        final loading = status == WStoreStatus.loading;
        final error = status == WStoreStatus.error;
        final fieldKey = GlobalKey<FormFieldState>();
        return AppDialogWithButtons(
          title: localization.confirm_email,
          primaryButtonText: localization.confirm,
          onPrimaryButtonPressed: () {
            FocusScope.of(context).unfocus();
            store.confirmEmail(email: newEmail, code: store.code);
          },
          primaryButtonLoading: loading,
          secondaryButtonText: '',
          children: [
            RichText(
              text: TextSpan(
                text: localization.code_has_been_send_to,
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: newEmail,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const PaddingTop(16),
            AddDialogInputField(
              fieldKey: fieldKey,
              labelText: localization.enter_code,
              autofocus: true,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value.isEmpty) {
                  return localization.enter_code;
                } else if (value.length != 4) {
                  return localization.code_length_must_be_4;
                } else if (int.tryParse(value) == null) {
                  return localization.only_numbers_allowed;
                }
                return '';
              },
              onChanged: (value) => store.setCode(value),
              onEditingComplete: () {
                final bool isValidated =
                    fieldKey.currentState?.validate() ?? false;
                if (isValidated) {
                  FocusScope.of(context).unfocus();
                  store.confirmEmail(
                    email: newEmail,
                    code: store.code.trim(),
                  );
                }
              },
            ),
            if (error)
              Text(
                switch (store.codeError) {
                  CodeConfimationErrors.incorrectCode =>
                    localization.incorrect_code,
                  CodeConfimationErrors.unknown =>
                    localization.unknown_error_try_later,
                  CodeConfimationErrors.none => '',
                },
                style: const TextStyle(
                  color: Color(0xFFD83400),
                ),
              ),
          ],
        );
      },
    );
  }
}
