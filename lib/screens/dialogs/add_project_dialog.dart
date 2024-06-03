import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/store/projects_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

Future<void> showAddProjectDialog(BuildContext context, int columnId) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AddProjectDialog(
        columnId: columnId,
      );
    },
  );
}

class AddProjectDialogStore extends WStore {
  String projectName = '';
  String createProjectError = '';
  WStoreStatus statusCreateProject = WStoreStatus.init;

  void setProjectName(String value) {
    setStore(() {
      projectName = value;
    });
  }

  void createProject(AppLocalizations localization) {
    if (statusCreateProject == WStoreStatus.loading) return;
    setStore(() {
      statusCreateProject = WStoreStatus.loading;
      createProjectError = '';
    });
    if (projectName.isEmpty) {
      setStore(() {
        createProjectError = localization.empty_project_name_error;
        statusCreateProject = WStoreStatus.error;
      });
      return;
    }

    subscribe(
      future: ProjectsStore().addProject(
        AddProject(name: projectName, spaceColumnId: widget.columnId),
      ),
      subscriptionId: 1,
      onData: (_) {
        setStore(() {
          statusCreateProject = WStoreStatus.loaded;
        });
      },
      onError: (error, stack) {
        logger.d(
          'CreateProjectDialogStore.createProject error: $error stack: $stack',
        );
        setStore(() {
          statusCreateProject = WStoreStatus.error;
          createProjectError = localization.create_project_error;
        });
      },
    );
  }

  @override
  AddProjectDialog get widget => super.widget as AddProjectDialog;
}

class AddProjectDialog extends WStoreWidget<AddProjectDialogStore> {
  final int columnId;

  const AddProjectDialog({
    required this.columnId,
    super.key,
  });

  @override
  AddProjectDialogStore createWStore() => AddProjectDialogStore();

  @override
  Widget build(BuildContext context, AddProjectDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.statusCreateProject,
      onStatusLoaded: (context) {
        Navigator.of(context).pop();
      },
      builder: (context, status) {
        final loading = status == WStoreStatus.loading;
        final error = status == WStoreStatus.error;
        return AppDialogWithButtons(
          title: localization.add_project,
          primaryButtonText: localization.create,
          onPrimaryButtonPressed: () {
            FocusScope.of(context).unfocus();
            store.createProject(localization);
          },
          primaryButtonLoading: loading,
          secondaryButtonText: '',
          children: [
            AddDialogInputField(
              autofocus: true,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                store.setProjectName(value);
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
                store.createProject(localization);
              },
              labelText: '${localization.project_name}:',
            ),
            if (error)
              Text(
                store.createProjectError,
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
