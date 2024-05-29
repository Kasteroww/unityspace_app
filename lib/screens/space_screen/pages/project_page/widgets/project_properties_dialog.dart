import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/store/project_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

Future<void> showProjectPropertiesDialog(
  BuildContext context,
  Project project,
) async {
  return showDialog(
    context: context,
    builder: (context) {
      return ProjectPropertiesDialog(
        project: project,
      );
    },
  );
}

class ProjectPropertiesDialogStore extends WStore {
  late Project project;
  String projectPropertiesError = '';
  WStoreStatus statusProjectProperties = WStoreStatus.init;

  void setProjectName(String projectName) {
    setStore(() {
      project = project.copyWith(name: projectName);
    });
  }

  void initData(Project project) {
    setStore(() {
      this.project = project;
    });
  }

  void saveProjectProperties(AppLocalizations localization) {
    if (statusProjectProperties == WStoreStatus.loading) return;
    setStore(() {
      statusProjectProperties = WStoreStatus.loading;
      projectPropertiesError = '';
    });

    subscribe(
      future: ProjectStore().updateProject(
        UpdateProject(
          id: project.id,
          name: project.name,
        ),
      ),
      subscriptionId: 1,
      onData: (_) {
        setStore(() {
          statusProjectProperties = WStoreStatus.loaded;
        });
      },
      onError: (error, stack) {
        logger.d(
          'ProjectPropertiesDialogStore.projectProperties error: $error stack: $stack',
        );
        setStore(() {
          statusProjectProperties = WStoreStatus.error;
          projectPropertiesError = localization.save_project_properties_error;
        });
      },
    );
  }

  @override
  ProjectPropertiesDialog get widget => super.widget as ProjectPropertiesDialog;
}

class ProjectPropertiesDialog
    extends WStoreWidget<ProjectPropertiesDialogStore> {
  final Project project;

  const ProjectPropertiesDialog({
    required this.project,
    super.key,
  });

  @override
  ProjectPropertiesDialogStore createWStore() =>
      ProjectPropertiesDialogStore()..initData(project);

  @override
  Widget build(BuildContext context, ProjectPropertiesDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.statusProjectProperties,
      onStatusLoaded: (context) {
        Navigator.of(context).pop();
      },
      builder: (context, status) {
        final loading = status == WStoreStatus.loading;
        final error = status == WStoreStatus.error;
        return WStoreBuilder<ProjectPropertiesDialogStore>(
          watch: (store) => [store.project],
          store: context.wstore(),
          builder: (context, store) {
            return AppDialogWithButtons(
              title: localization.change_project,
              primaryButtonText: localization.save,
              onPrimaryButtonPressed: () {
                FocusScope.of(context).unfocus();
                store.saveProjectProperties(localization);
              },
              primaryButtonLoading: loading,
              secondaryButtonText: '',
              children: [
                AddDialogInputField(
                  autofocus: true,
                  initialValue: store.project.name,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (projectName) {
                    store.setProjectName(projectName);
                  },
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                    // store.saveProjectProperties(localization);
                  },
                  labelText: localization.project_name,
                ),
                const SizedBox(height: 16),
                if (error)
                  Text(
                    store.projectPropertiesError,
                    style: const TextStyle(
                      color: Color(0xFFD83400),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
