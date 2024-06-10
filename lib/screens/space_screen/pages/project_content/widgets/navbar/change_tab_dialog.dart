import 'package:flutter/material.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/store/projects_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

Future<void> showChangeTabDialog({
  required BuildContext context,
  required ProjectEmbed embedding,
}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return ChangeTabDialog(
        embedding: embedding,
      );
    },
  );
}

class ChangeTabDialogStore extends WStore {
  ChangeProjectTabErrors changeTabError = ChangeProjectTabErrors.none;
  WStoreStatus statusChangeTabDialog = WStoreStatus.init;
  String name = '';
  String url = '';

  void initData(ProjectEmbed embed) {
    setStore(() {
      url = embed.url;
      name = embed.name;
    });
  }

  void setTabName(String tabName) {
    setStore(() {
      name = tabName;
    });
  }

  void setTabLink(String tabLink) {
    setStore(() {
      url = tabLink;
    });
  }

  void changeTabDialog() {
    if (statusChangeTabDialog == WStoreStatus.loading) return;
    setStore(() {
      statusChangeTabDialog = WStoreStatus.loading;
      changeTabError = ChangeProjectTabErrors.none;
    });

    if (name.isEmpty || url.isEmpty) {
      setStore(() {
        changeTabError = ChangeProjectTabErrors.valueIsEmpty;
        statusChangeTabDialog = WStoreStatus.error;
      });
      return;
    }

    subscribe(
      future: ProjectsStore().updateProjectEmbed(
        projectId: widget.embedding.projectId,
        embedId: widget.embedding.id,
        embed: widget.embedding.copyWith(name: name, url: url),
      ),
      subscriptionId: 1,
      onData: (_) {
        setStore(() {
          statusChangeTabDialog = WStoreStatus.loaded;
        });
      },
      onError: (error, stack) {
        logger.d(
          'ChangeTabDialogStore.changeTab error: $error stack: $stack',
        );
        setStore(() {
          statusChangeTabDialog = WStoreStatus.error;
          changeTabError = ChangeProjectTabErrors.changeProjectTabError;
        });
      },
    );
  }

  @override
  ChangeTabDialog get widget => super.widget as ChangeTabDialog;
}

class ChangeTabDialog extends WStoreWidget<ChangeTabDialogStore> {
  final ProjectEmbed embedding;

  const ChangeTabDialog({
    required this.embedding,
    super.key,
  });

  @override
  ChangeTabDialogStore createWStore() =>
      ChangeTabDialogStore()..initData(embedding);

  @override
  Widget build(BuildContext context, ChangeTabDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.statusChangeTabDialog,
      onStatusLoaded: (context) {
        Navigator.of(context).pop();
      },
      builder: (context, status) {
        final loading = status == WStoreStatus.loading;
        final error = status == WStoreStatus.error;
        return AppDialogWithButtons(
          title: localization.change_tab,
          primaryButtonText: localization.save,
          onPrimaryButtonPressed: () {
            FocusScope.of(context).unfocus();
            store.changeTabDialog();
          },
          primaryButtonLoading: loading,
          secondaryButtonText: '',
          children: [
            const SizedBox(height: 16),
            AddDialogInputField(
              autofocus: true,
              initialValue: store.name,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.text,
              onChanged: (value) {
                store.setTabName(value);
              },
              labelText: localization.enter_name,
            ),
            const SizedBox(height: 16),
            AddDialogInputField(
              initialValue: store.url,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.characters,
              keyboardType: TextInputType.url,
              onChanged: (value) {
                store.setTabLink(value);
              },
              labelText: localization.link,
            ),
            const SizedBox(height: 16),
            if (error)
              Text(
                switch (store.changeTabError) {
                  ChangeProjectTabErrors.none => '',
                  ChangeProjectTabErrors.valueIsEmpty =>
                    localization.value_cannot_be_empty,
                  ChangeProjectTabErrors.changeProjectTabError =>
                    localization.change_project_tab_error,
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
