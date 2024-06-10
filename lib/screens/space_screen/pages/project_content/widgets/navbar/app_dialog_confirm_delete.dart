import 'package:flutter/material.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/store/projects_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

Future<void> showConfirmDeleteDialog({
  required BuildContext context,
  required ProjectEmbed embedding,
}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return ConfirmDeleteDialog(
        embedding: embedding,
      );
    },
  );
}

class ConfirmDeleteDialogStore extends WStore {
  DeleteProjectTabErrors confirmDeleteError = DeleteProjectTabErrors.none;
  WStoreStatus statusConfirmDeleteDialog = WStoreStatus.init;

  void confirmDeleteDialog() {
    if (statusConfirmDeleteDialog == WStoreStatus.loading) return;
    setStore(() {
      statusConfirmDeleteDialog = WStoreStatus.loading;
      confirmDeleteError = DeleteProjectTabErrors.none;
    });

    subscribe(
      future: ProjectsStore().deleteProjectEmbed(
        projectId: widget.embedding.projectId,
        embedId: widget.embedding.id,
      ),
      subscriptionId: 1,
      onData: (_) {
        setStore(() {
          statusConfirmDeleteDialog = WStoreStatus.loaded;
        });
      },
      onError: (error, stack) {
        logger.d(
          'ConfirmDeleteDialogStore.confirmDelete error: $error stack: $stack',
        );
        setStore(() {
          statusConfirmDeleteDialog = WStoreStatus.error;
          confirmDeleteError = DeleteProjectTabErrors.deleteProjectTabError;
        });
      },
    );
  }

  @override
  ConfirmDeleteDialog get widget => super.widget as ConfirmDeleteDialog;
}

class ConfirmDeleteDialog extends WStoreWidget<ConfirmDeleteDialogStore> {
  final ProjectEmbed embedding;

  const ConfirmDeleteDialog({
    required this.embedding,
    super.key,
  });

  @override
  ConfirmDeleteDialogStore createWStore() => ConfirmDeleteDialogStore();

  @override
  Widget build(BuildContext context, ConfirmDeleteDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.statusConfirmDeleteDialog,
      onStatusLoaded: (context) {
        Navigator.of(context).pop();
      },
      builder: (context, status) {
        final loading = status == WStoreStatus.loading;
        final error = status == WStoreStatus.error;
        return AppDialogWithButtons(
          title: localization.confirm_delete_project_tab,
          primaryButtonText: localization.delete,
          onPrimaryButtonPressed: () {
            FocusScope.of(context).unfocus();
            store.confirmDeleteDialog();
          },
          onSecondaryButtonPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();
          },
          primaryButtonLoading: loading,
          secondaryButtonText: localization.cancel,
          children: [
            const SizedBox(height: 16),
            if (error)
              Text(
                switch (store.confirmDeleteError) {
                  DeleteProjectTabErrors.none => '',
                  DeleteProjectTabErrors.deleteProjectTabError =>
                    localization.delete_project_tab_error,
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
