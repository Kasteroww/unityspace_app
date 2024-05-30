import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unityspace/models/color_models.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_dropdown_menu.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/store/project_store.dart';
import 'package:unityspace/utils/helpers.dart';
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
  late ColorType selectedColor;
  List<ColorType> listProjectColors = [
    ColorType(colorHex: '', name: getColorName('Цвет не выбран')),
    ColorType(colorHex: '#D8EFF4', name: getColorName('#D8EFF4')),
    ColorType(colorHex: '#F3E2D9', name: getColorName('#F3E2D9')),
    ColorType(colorHex: '#F1DBF2', name: getColorName('#F1DBF2')),
    ColorType(colorHex: '#D9DDF3', name: getColorName('#D9DDF3')),
    ColorType(colorHex: '#E5F5DD', name: getColorName('#E5F5DD')),
    ColorType(colorHex: '#CAECD8', name: getColorName('#CAECD8')),
    ColorType(colorHex: '#ECDECA', name: getColorName('#ECDECA')),
  ];

  String projectPropertiesError = '';
  WStoreStatus statusProjectProperties = WStoreStatus.init;

  void setProjectName(String projectName) {
    setStore(() {
      project = project.copyWith(name: projectName);
    });
  }

  void setProjectColor(ColorType color, AppLocalizations localization) {
    setStore(() {
      project = project.copyWith(color: color.colorHex);
      selectedColor = color;
    });
  }

  String setProjectColorName(ColorType color, AppLocalizations localization) {
    if (color.name.isNotEmpty) {
      return color.name;
    } else if (color.colorHex.isNotEmpty) {
      return color.colorHex;
    } else {
      return localization.color_is_empty;
    }
  }

  void initData(Project project) {
    setStore(() {
      this.project = project;
      selectedColor = listProjectColors.firstWhereOrNull(
            (color) => color.colorHex == (project.color ?? ''),
          ) ??
          listProjectColors.first;
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
          color: project.color,
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
                  },
                  labelText: localization.project_name,
                ),
                const SizedBox(height: 16),
                AddDialogDropdownMenu<ColorType>(
                  onChanged: (color) {
                    FocusScope.of(context).unfocus();
                    if (color is ColorType) {
                      store.setProjectColor(color, localization);
                    } else {
                      throw Exception('Value has wrong type');
                    }
                  },
                  labelText: localization.color,
                  listValues: store.listProjectColors,
                  currentValue: store.selectedColor,
                ),
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
