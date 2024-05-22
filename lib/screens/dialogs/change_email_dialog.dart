import 'package:flutter/material.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/screens/widgets/common/paddings.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/errors.dart';
import 'package:wstore/wstore.dart';
import 'package:unityspace/utils/localization_helper.dart';

Future<void> showChangeEmailDialog(BuildContext context) async {
  return showDialog(
      context: context,
      builder: (_) {
        return const ChangeEmailDialog();
      });
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

  setNewEmail(String value) {
    setStore(() {
      newEmail = value.trim();
    });
  }

  Future<void> changeUserEmail(String email) async {
    if (isChangeEmail) return;
    setStore(() {
      isChangeEmail = true;
      statusEmail = WStoreStatus.loading;
    });
    final requestEmailVerify = await UserStore()
        .requestEmailVerification(email: email, isChangeEmail: true);
    switch (requestEmailVerify) {
      case null:
        setStore(() {
          isChangeEmail = false;
          statusEmail = WStoreStatus.error;
          emailError = EmailErrors.incorrectEmailAddress;
        });
        break;
      case "User already exists":
        setStore(() {
          isChangeEmail = false;
          statusEmail = WStoreStatus.error;
          emailError = EmailErrors.emailAlreadyExists;
        });
        break;
      case "Cannot process this email":
        setStore(() {
          isChangeEmail = false;
          statusEmail = WStoreStatus.error;
          emailError = EmailErrors.cannotSendEmail;
        });
      case "Incorrect email format":
        setStore(() {
          isChangeEmail = false;
          statusEmail = WStoreStatus.error;
          emailError = EmailErrors.incorrectEmailAddress;
        });
      default:
        setStore(() {
          isChangeEmail = false;
          statusEmail = WStoreStatus.loaded;
          emailError = EmailErrors.none;
          newEmail = email;
        });
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
                    return 'Введите email';
                  } else if (!isValidEmail(value)) {
                    return 'Некорректный формат';
                  } else if (value == store.currentUserEmail) {
                    return 'Почты совпадают';
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
                  store.emailError.localization,
                  style: const TextStyle(
                    color: Color(0xFFD83400),
                  ),
                ),
            ]);
      },
    );
  }

  bool isValidEmail(String email) {
    return RegExp(r'\S+@\S+\.\S+').hasMatch(email);
  }
}

Future<void> showConfirmEmailDialog(BuildContext context,
    {required String newEmail}) async {
  return showDialog(
      context: context,
      builder: (_) {
        return ConfirmEmailDialog(newEmail: newEmail);
      });
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

  setCode(String value) {
    setStore(() {
      code = value.trim();
    });
  }

  confirmEmail({required String email, required String code}) async {
    if (currentUser == null) return;
    setStore(() {
      codeStatus = WStoreStatus.loading;
    });
    try {
      await userStore.confirmEmail(
          email: email,
          code: code,
          userGlobalId: currentUserGlobalId,
          userId: currentUserId);
      codeStatus = WStoreStatus.loaded;
      if (currentUser != null) {
        _updateEmailLocally(email: email, userId: currentUserId);
      }
      setStore(() {
        isShowConfirm = true;
      });
    } catch (e) {
      setStore(() {
        codeStatus = WStoreStatus.error;
        codeError = CodeConfimationErrors.incorrectCode;
      });
    }
  }

  _updateEmailLocally({required String email, required int userId}) {
    userStore.changeEmailLocally(newEmail: email);
    userStore.changeMemberEmailLocally(userId: userId, newEmail: email);
    spacesStore.changeSpaceMemberEmailLocally(newEmail: email, userId: userId);
  }

  @override
  ConfirmEmailDialog get widget => super.widget as ConfirmEmailDialog;
}

class ConfirmEmailDialog extends WStoreWidget<ConfirmEmailDialogStore> {
  const ConfirmEmailDialog({
    super.key,
    required this.newEmail,
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
                            .copyWith(fontWeight: FontWeight.w500))
                  ])),
              const PaddingTop(16),
              AddDialogInputField(
                fieldKey: fieldKey,
                labelText: localization.enter_code,
                autofocus: true,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Введите код';
                  } else if (value.length != 4) {
                    return 'Длина кода должна быть 4';
                  } else if (int.tryParse(value) == null) {
                    return 'Разрешены только числа';
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
                        email: newEmail, code: store.code.trim());
                  }
                },
              ),
              if (error)
                Text(
                  store.codeError.name,
                  style: const TextStyle(
                    color: Color(0xFFD83400),
                  ),
                ),
            ]);
      },
    );
  }
}
