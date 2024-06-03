import 'package:flutter/material.dart';
import 'package:unityspace/resources/l10n/app_localizations.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/helpers.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

Future<void> showUserChangeGitHubLinkDialog(
  BuildContext context,
  final String link,
) async {
  return showDialog(
    context: context,
    builder: (context) {
      return UserChangeGitHubLinkDialog(link: link);
    },
  );
}

class UserChangeGitHubLinkDialogStore extends WStore {
  String link = '';
  String changeGitHubLinkError = '';
  WStoreStatus statusChangeGitHubLink = WStoreStatus.init;

  void setLink(String value) {
    setStore(() {
      link = value;
    });
  }

  void changeGitHubLink(AppLocalizations localization) {
    if (statusChangeGitHubLink == WStoreStatus.loading) return;
    //
    setStore(() {
      statusChangeGitHubLink = WStoreStatus.loading;
      changeGitHubLinkError = '';
    });
    //
    String formattedLink = link;
    if (formattedLink.isNotEmpty) {
      if (!formattedLink.startsWith('https://github.com/')) {
        formattedLink = 'https://github.com/$formattedLink';
      }
      if (!isLinkValid(formattedLink)) {
        setStore(() {
          changeGitHubLinkError = localization.invalid_link_error;
          statusChangeGitHubLink = WStoreStatus.error;
        });
        return;
      }
    }
    //
    if (formattedLink == widget.link) {
      setStore(() {
        statusChangeGitHubLink = WStoreStatus.loaded;
      });
      return;
    }
    //
    subscribe(
      future: UserStore().setUserGitHubLink(formattedLink),
      subscriptionId: 1,
      onData: (_) {
        setStore(() {
          statusChangeGitHubLink = WStoreStatus.loaded;
        });
      },
      onError: (error, stack) {
        final String errorText = localization.change_link_error;
        logger.d(
          'UserChangeGitHubLinkDialogStore.changeGitHubLink error: $error stack: $stack',
        );
        setStore(() {
          statusChangeGitHubLink = WStoreStatus.error;
          changeGitHubLinkError = errorText;
        });
      },
    );
  }

  @override
  UserChangeGitHubLinkDialog get widget =>
      super.widget as UserChangeGitHubLinkDialog;
}

class UserChangeGitHubLinkDialog
    extends WStoreWidget<UserChangeGitHubLinkDialogStore> {
  final String link;

  const UserChangeGitHubLinkDialog({
    required this.link,
    super.key,
  });

  @override
  UserChangeGitHubLinkDialogStore createWStore() =>
      UserChangeGitHubLinkDialogStore()..link = link;

  @override
  Widget build(BuildContext context, UserChangeGitHubLinkDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.statusChangeGitHubLink,
      onStatusLoaded: (context) {
        Navigator.of(context).pop();
      },
      builder: (context, status) {
        final loading = status == WStoreStatus.loading;
        final error = status == WStoreStatus.error;
        return AppDialogWithButtons(
          title: localization.change_github_link,
          primaryButtonText: localization.save,
          onPrimaryButtonPressed: () {
            FocusScope.of(context).unfocus();
            store.changeGitHubLink(localization);
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
                store.changeGitHubLink(localization);
              },
              labelText: localization.link_on_name_profile,
            ),
            if (error)
              Text(
                store.changeGitHubLinkError,
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
