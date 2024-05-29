import 'package:flutter/material.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

Future<void> showUserChangeBirthdayDialog(
  BuildContext context,
  final DateTime? birthDate,
) async {
  return showDialog(
    context: context,
    builder: (context) {
      return UserChangeBirthdayDialog(date: birthDate);
    },
  );
}

class UserChangeBirthdayDialogStore extends WStore {
  DateTime? date;
  String changeError = '';
  WStoreStatus statusChangeBirthday = WStoreStatus.init;

  void setDate(DateTime? newDate) {
    setStore(() {
      date = newDate;
    });
  }

  void changeBirthday(String changeBirthdayError) {
    if (statusChangeBirthday == WStoreStatus.loading) return;
    //
    setStore(() {
      statusChangeBirthday = WStoreStatus.loading;
      changeError = '';
    });
    //
    if (date == widget.date) {
      setStore(() {
        statusChangeBirthday = WStoreStatus.loaded;
      });
      return;
    }
    //
    subscribe(
      future: UserStore().setUserBirthday(date),
      subscriptionId: 1,
      onData: (_) {
        setStore(() {
          statusChangeBirthday = WStoreStatus.loaded;
        });
      },
      onError: (error, stack) {
        logger.d(
          'UserChangeBirthdayDialogStore.changeBirthday error: $error stack: $stack',
        );
        setStore(() {
          statusChangeBirthday = WStoreStatus.error;
          changeError = changeBirthdayError;
        });
      },
    );
  }

  @override
  UserChangeBirthdayDialog get widget =>
      super.widget as UserChangeBirthdayDialog;
}

class UserChangeBirthdayDialog
    extends WStoreWidget<UserChangeBirthdayDialogStore> {
  final DateTime? date;

  const UserChangeBirthdayDialog({
    required this.date,
    super.key,
  });

  @override
  UserChangeBirthdayDialogStore createWStore() =>
      UserChangeBirthdayDialogStore()..date = date;

  @override
  Widget build(BuildContext context, UserChangeBirthdayDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.statusChangeBirthday,
      onStatusLoaded: (context) {
        Navigator.of(context).pop();
      },
      builder: (context, status) {
        final loading = status == WStoreStatus.loading;
        final error = status == WStoreStatus.error;
        return AppDialogWithButtons(
          title: localization.change_the_date_of_birth,
          primaryButtonText: localization.save,
          onPrimaryButtonPressed: () {
            store.changeBirthday(localization.change_birthday_error);
          },
          primaryButtonLoading: loading,
          secondaryButtonText: localization.clear,
          onSecondaryButtonPressed: () {
            store.setDate(null);
            store.changeBirthday(localization.change_birthday_error);
          },
          secondaryButtonLoading: loading,
          children: [
            SizedBox(
              width: 320,
              child: CalendarDatePicker(
                initialDate: store.date,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                onDateChanged: (DateTime newDate) {
                  store.setDate(newDate);
                },
              ),
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
