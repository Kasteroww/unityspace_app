import 'package:flutter/material.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

Future<void> showUserChangeJobDialog(
  BuildContext context,
  final String jobTitle,
) async {
  return showDialog(
    context: context,
    builder: (context) {
      return UserChangeJobDialog(jobTitle: jobTitle);
    },
  );
}

class UserChangeJobDialogStore extends WStore {
  String jobTitle = '';
  String changeError = '';
  WStoreStatus statusChange = WStoreStatus.init;

  void setJobTitle(String value) {
    setStore(() {
      jobTitle = value;
    });
  }

  void changeJobTitle(String changeJobError) {
    if (statusChange == WStoreStatus.loading) return;
    //
    setStore(() {
      statusChange = WStoreStatus.loading;
      changeError = '';
    });
    //
    if (jobTitle == widget.jobTitle) {
      setStore(() {
        statusChange = WStoreStatus.loaded;
      });
      return;
    }
    //
    subscribe(
      future: UserStore().setJobTitle(jobTitle),
      subscriptionId: 1,
      onData: (_) {
        setStore(() {
          statusChange = WStoreStatus.loaded;
        });
      },
      onError: (error, stack) {
        logger.d(
          'UserChangeJobDialogStore.changeJobTitle error: $error stack: $stack',
        );
        setStore(() {
          statusChange = WStoreStatus.error;
          changeError = changeJobError;
        });
      },
    );
  }

  @override
  UserChangeJobDialog get widget => super.widget as UserChangeJobDialog;
}

class UserChangeJobDialog extends WStoreWidget<UserChangeJobDialogStore> {
  final String jobTitle;

  const UserChangeJobDialog({
    required this.jobTitle,
    super.key,
  });

  @override
  UserChangeJobDialogStore createWStore() =>
      UserChangeJobDialogStore()..jobTitle = jobTitle;

  @override
  Widget build(BuildContext context, UserChangeJobDialogStore store) {
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
          title: localization.change_work_position,
          primaryButtonText: localization.save,
          onPrimaryButtonPressed: () {
            FocusScope.of(context).unfocus();
            store.changeJobTitle(localization.change_job_error);
          },
          primaryButtonLoading: loading,
          secondaryButtonText: '',
          children: [
            AddDialogInputField(
              autofocus: true,
              initialValue: jobTitle,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.text,
              onChanged: (value) {
                store.setJobTitle(value);
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
                store.changeJobTitle(localization.change_job_error);
              },
              labelText: localization.enter_work_position,
            ),
            if (error)
              Text(
                store.changeError,
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
