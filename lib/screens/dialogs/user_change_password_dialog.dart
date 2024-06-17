import 'package:flutter/material.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/service/exceptions/http_exceptions.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

Future<void> showUserChangePasswordDialog(
  BuildContext context,
) async {
  return showDialog(
    context: context,
    builder: (context) {
      return const UserChangePasswordDialog();
    },
  );
}

class UserChangePasswordDialogStore extends WStore {
  String oldPassword = '';
  String newPassword = '';
  String confirmPassword = '';
  ChangePasswordErrors changePasswordError = ChangePasswordErrors.none;
  WStoreStatus statusChange = WStoreStatus.init;

  void setOldPassword(String value) {
    setStore(() {
      oldPassword = value;
    });
  }

  void setNewPassword(String value) {
    setStore(() {
      newPassword = value;
    });
  }

  void setConfirmPassword(String value) {
    setStore(() {
      confirmPassword = value;
    });
  }

  void changePassword() {
    if (statusChange == WStoreStatus.loading) return;
    //
    setStore(() {
      statusChange = WStoreStatus.loading;
      changePasswordError = ChangePasswordErrors.none;
    });
    //
    if (oldPassword.isEmpty || newPassword.isEmpty) {
      setStore(() {
        changePasswordError = ChangePasswordErrors.emptyPassword;
        statusChange = WStoreStatus.error;
      });
      return;
    }
    //
    if (newPassword.length < 8) {
      setStore(() {
        changePasswordError = ChangePasswordErrors.lengthAtLeast8;
        statusChange = WStoreStatus.error;
      });
      return;
    }
    //
    if (confirmPassword != newPassword) {
      setStore(() {
        changePasswordError = ChangePasswordErrors.passwordsDoNotMatch;
        statusChange = WStoreStatus.error;
      });
      return;
    }
    //
    if (oldPassword == newPassword) {
      setStore(() {
        changePasswordError = ChangePasswordErrors.matchesOldPassword;
        statusChange = WStoreStatus.error;
      });
      return;
    }
    //
    subscribe(
      future: UserStore().setUserPassword(oldPassword, newPassword),
      subscriptionId: 1,
      onData: (_) {
        setStore(() {
          statusChange = WStoreStatus.loaded;
        });
      },
      onError: (error, stack) {
        ChangePasswordErrors currentError =
            ChangePasswordErrors.changePasswordError;
        if (error is UserIncorrectOldPasswordHttpException) {
          currentError = ChangePasswordErrors.incorrectOldPassword;
        } else {
          logger.d(
            'UserChangePasswordDialogStore.changePassword error: $error stack: $stack',
          );
        }
        setStore(() {
          statusChange = WStoreStatus.error;
          changePasswordError = currentError;
        });
      },
    );
  }

  @override
  UserChangePasswordDialog get widget =>
      super.widget as UserChangePasswordDialog;
}

class UserChangePasswordDialog
    extends WStoreWidget<UserChangePasswordDialogStore> {
  const UserChangePasswordDialog({
    super.key,
  });

  @override
  UserChangePasswordDialogStore createWStore() =>
      UserChangePasswordDialogStore();

  @override
  Widget build(BuildContext context, UserChangePasswordDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.statusChange,
      onStatusLoaded: (context) {
        Navigator.of(context).pop();
      },
      builder: (context, status) {
        final loading = status == WStoreStatus.loading;
        final error = status == WStoreStatus.error;
        return AppDialogWithButtons(
          title: localization.change_password,
          primaryButtonText: localization.save,
          onPrimaryButtonPressed: () {
            FocusScope.of(context).unfocus();
            store.changePassword();
          },
          primaryButtonLoading: loading,
          secondaryButtonText: '',
          children: [
            Text(
              '${localization.come_up_with_a_new_password_with_length_at_least_8_characters})',
            ),
            const SizedBox(height: 16),
            AddDialogInputField(
              autofocus: true,
              obscureText: true,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.visiblePassword,
              onChanged: (value) {
                store.setOldPassword(value);
              },
              labelText: localization.enter_old_password,
            ),
            const SizedBox(height: 16),
            AddDialogInputField(
              textInputAction: TextInputAction.next,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              onChanged: (value) {
                store.setNewPassword(value);
              },
              labelText: localization.enter_new_password,
            ),
            const SizedBox(height: 16),
            AddDialogInputField(
              textInputAction: TextInputAction.done,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              onChanged: (value) {
                store.setConfirmPassword(value);
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
                store.changePassword();
              },
              labelText: localization.repeat_new_password,
            ),
            if (error)
              Text(
                switch (store.changePasswordError) {
                  ChangePasswordErrors.emptyPassword =>
                    localization.empty_password_error,
                  ChangePasswordErrors.lengthAtLeast8 =>
                    localization.at_least_8_characters,
                  ChangePasswordErrors.passwordsDoNotMatch =>
                    localization.match_password_error,
                  ChangePasswordErrors.matchesOldPassword =>
                    localization.new_password_equal_old_error,
                  ChangePasswordErrors.changePasswordError =>
                    localization.change_password_error,
                  ChangePasswordErrors.incorrectOldPassword =>
                    localization.incorrect_old_password_error,
                  ChangePasswordErrors.none => ''
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
