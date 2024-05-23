import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';

import 'package:flutter/material.dart';
import 'package:unityspace/service/service_exceptions.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  String changePasswordError = '';
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

  void changePassword(AppLocalizations localization) {
    if (statusChange == WStoreStatus.loading) return;
    //
    setStore(() {
      statusChange = WStoreStatus.loading;
      changePasswordError = '';
    });
    //
    if (oldPassword.isEmpty || newPassword.isEmpty) {
      setStore(() {
        changePasswordError = localization.empty_password_error;
        statusChange = WStoreStatus.error;
      });
      return;
    }
    //
    if (newPassword.length < 8) {
      setStore(() {
        changePasswordError = localization.at_least_8_characters_error;
        statusChange = WStoreStatus.error;
      });
      return;
    }
    //
    if (confirmPassword != newPassword) {
      setStore(() {
        changePasswordError = localization.match_password_error;
        statusChange = WStoreStatus.error;
      });
      return;
    }
    //
    if (oldPassword == newPassword) {
      setStore(() {
        changePasswordError = localization.new_password_equal_old_error;
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
        String errorText = localization.change_password_error;
        if (error is UserIncorrectOldPasswordException) {
          errorText = localization.incorrect_old_password_error;
        } else {
          logger.d(
              'UserChangePasswordDialogStore.changePassword error: $error stack: $stack');
        }
        setStore(() {
          statusChange = WStoreStatus.error;
          changePasswordError = errorText;
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
            store.changePassword(localization);
          },
          primaryButtonLoading: loading,
          secondaryButtonText: '',
          children: [
            Text(
              '${localization.come_up_with_a_new_password} (${localization.at_least_8_characters})',
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
                store.changePassword(localization);
              },
              labelText: localization.repeat_new_password,
            ),
            if (error)
              Text(
                store.changePasswordError,
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
