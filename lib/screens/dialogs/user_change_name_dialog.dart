import 'package:flutter/material.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

Future<void> showUserChangeNameDialog(
  BuildContext context,
  final String name,
) async {
  return showDialog(
    context: context,
    builder: (context) {
      return UserChangeNameDialog(name: name);
    },
  );
}

class UserChangeNameDialogStore extends WStore {
  String name = '';
  ChangeNameErrors changeNameError = ChangeNameErrors.none;
  WStoreStatus statusChangeName = WStoreStatus.init;

  void setName(String value) {
    setStore(() {
      name = value;
    });
  }

  void changeName() {
    if (statusChangeName == WStoreStatus.loading) return;

    setStore(() {
      statusChangeName = WStoreStatus.loading;
      changeNameError = ChangeNameErrors.none;
    });

    if (name.isEmpty) {
      setStore(() {
        changeNameError = ChangeNameErrors.emptyName;
        statusChangeName = WStoreStatus.error;
      });
      return;
    }

    if (name == widget.name) {
      setStore(() {
        statusChangeName = WStoreStatus.loaded;
      });
      return;
    }

    subscribe(
      future: UserStore().setUserName(name),
      subscriptionId: 1,
      onData: (_) {
        setStore(() {
          statusChangeName = WStoreStatus.loaded;
        });
      },
      onError: (error, stack) {
        logger.d(
          'UserChangeNameDialogStore.changeName error: $error stack: $stack',
        );
        setStore(() {
          statusChangeName = WStoreStatus.error;
          changeNameError = ChangeNameErrors.changeNameError;
        });
      },
    );
  }

  @override
  UserChangeNameDialog get widget => super.widget as UserChangeNameDialog;
}

class UserChangeNameDialog extends WStoreWidget<UserChangeNameDialogStore> {
  final String name;

  const UserChangeNameDialog({
    required this.name,
    super.key,
  });

  @override
  UserChangeNameDialogStore createWStore() =>
      UserChangeNameDialogStore()..name = name;

  @override
  Widget build(BuildContext context, UserChangeNameDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.statusChangeName,
      onStatusLoaded: (context) {
        Navigator.of(context).pop();
      },
      builder: (context, status) {
        final loading = status == WStoreStatus.loading;
        final error = status == WStoreStatus.error;
        return AppDialogWithButtons(
          title: localization.change_name,
          primaryButtonText: localization.save,
          onPrimaryButtonPressed: () {
            FocusScope.of(context).unfocus();
            store.changeName();
          },
          primaryButtonLoading: loading,
          secondaryButtonText: '',
          children: [
            AddDialogInputField(
              autofocus: true,
              initialValue: name,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                store.setName(value);
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
                store.changeName();
              },
              labelText: localization.enter_a_new_name,
            ),
            if (error)
              Text(
                switch (store.changeNameError) {
                  ChangeNameErrors.emptyName => localization.empty_name_error,
                  ChangeNameErrors.changeNameError =>
                    localization.change_name_error,
                  ChangeNameErrors.none => ''
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
