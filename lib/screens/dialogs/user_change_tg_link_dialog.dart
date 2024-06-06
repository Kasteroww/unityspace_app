import 'package:flutter/material.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/helpers.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

Future<void> showUserChangeTgLinkDialog(
  BuildContext context,
  final String link,
) async {
  return showDialog(
    context: context,
    builder: (context) {
      return UserChangeTgLinkDialog(link: link);
    },
  );
}

class UserChangeTgLinkDialogStore extends WStore {
  String link = '';
  ChangeTgLinkErrors changeLinkError = ChangeTgLinkErrors.none;
  WStoreStatus statusChangeLink = WStoreStatus.init;

  void setLink(String value) {
    setStore(() {
      link = value;
    });
  }

  void changeTgLink() {
    if (statusChangeLink == WStoreStatus.loading) return;
    //
    setStore(() {
      statusChangeLink = WStoreStatus.loading;
      changeLinkError = ChangeTgLinkErrors.none;
    });
    //
    String formattedLink = link;
    if (formattedLink.isNotEmpty) {
      if (formattedLink.startsWith('@')) {
        formattedLink = 'https://t.me/${formattedLink.substring(1)}';
      }
      if (!isLinkValid(formattedLink)) {
        setStore(() {
          changeLinkError = ChangeTgLinkErrors.invalidLink;
          statusChangeLink = WStoreStatus.error;
        });
        return;
      }
    }

    //
    if (formattedLink == widget.link) {
      setStore(() {
        statusChangeLink = WStoreStatus.loaded;
      });
      return;
    }
    //
    subscribe(
      future: UserStore().setUserTelegramLink(formattedLink),
      subscriptionId: 1,
      onData: (_) {
        setStore(() {
          statusChangeLink = WStoreStatus.loaded;
        });
      },
      onError: (error, stack) {
        logger.d(
          'UserChangeTgLinkDialogStore.changeTgLink error: $error stack: $stack',
        );
        setStore(() {
          statusChangeLink = WStoreStatus.error;
          changeLinkError = ChangeTgLinkErrors.changeLinkError;
        });
      },
    );
  }

  @override
  UserChangeTgLinkDialog get widget => super.widget as UserChangeTgLinkDialog;
}

class UserChangeTgLinkDialog extends WStoreWidget<UserChangeTgLinkDialogStore> {
  final String link;

  const UserChangeTgLinkDialog({
    required this.link,
    super.key,
  });

  @override
  UserChangeTgLinkDialogStore createWStore() => UserChangeTgLinkDialogStore();

  @override
  Widget build(BuildContext context, UserChangeTgLinkDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.statusChangeLink,
      onStatusLoaded: (context) {
        Navigator.of(context).pop();
      },
      builder: (context, status) {
        final loading = status == WStoreStatus.loading;
        final error = status == WStoreStatus.error;
        return AppDialogWithButtons(
          title: localization.change_telegram_link,
          primaryButtonText: localization.save,
          onPrimaryButtonPressed: () {
            FocusScope.of(context).unfocus();
            store.changeTgLink();
          },
          primaryButtonLoading: loading,
          secondaryButtonText: '',
          children: [
            AddDialogInputField(
              autofocus: true,
              initialValue: link,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.url,
              autocorrect: false,
              onChanged: (value) {
                store.setLink(value);
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
                store.changeTgLink();
              },
              labelText: localization.link_on_name_profile,
            ),
            if (error)
              Text(
                switch (store.changeLinkError) {
                  ChangeTgLinkErrors.invalidLink =>
                    localization.invalid_link_error,
                  ChangeTgLinkErrors.changeLinkError =>
                    localization.change_link_error,
                  ChangeTgLinkErrors.none => ''
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
