import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unityspace/models/i_base_model.dart';
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
  String projectPropertiesError = '';
  WStoreStatus statusProjectProperties = WStoreStatus.init;

  late String projectName;
  late ColorType selectedColor;
  late int markAsSnail;
  late List<Nameable> listMarkAsSnail;

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

  void _setProjectName(String name) {
    setStore(() {
      projectName = name;
    });
  }

  void _setProjectColor(ColorType color) {
    setStore(() {
      selectedColor = color;
    });
  }

  void _setMarkAsSnail(Nameable markAsSnailCount) {
    setStore(() {
      markAsSnail = listMarkAsSnail.indexOf(markAsSnailCount);
    });
  }

  List<Nameable> _initMarkAsSnail(AppLocalizations localization) {
    return MarkAsSnail.values
        .map(
          (element) => Nameable(
            name: switch (element) {
              MarkAsSnail.zero => localization.disabled,
              MarkAsSnail.one => localization.days(1),
              MarkAsSnail.two => localization.days(2),
              MarkAsSnail.three => localization.days(3),
              MarkAsSnail.four => localization.days(4),
              MarkAsSnail.five => localization.days(5),
              MarkAsSnail.six => localization.days(6),
              MarkAsSnail.seven => localization.days(7),
            },
          ),
        )
        .toList();
  }

  ColorType _checkSelectedColor(Project project) {
    final ColorType? colorType = listProjectColors
        .firstWhereOrNull((color) => color.colorHex == project.color);
    if (colorType != null) {
      return colorType;
    } else {
      final ColorType newColor = ColorType(
        colorHex: project.color,
        name: project.color == null ? getColorName('') : project.color!,
      );
      listProjectColors.add(newColor);
      return newColor;
    }
  }

  void _initData(Project project, AppLocalizations localization) {
    setStore(() {
      projectName = project.name;
      listMarkAsSnail = _initMarkAsSnail(localization);
      markAsSnail = project.postponingTaskDayCount;
      selectedColor = _checkSelectedColor(project);
    });
  }

  void saveProjectProperties(AppLocalizations localization, int projectId) {
    if (statusProjectProperties == WStoreStatus.loading) return;
    setStore(() {
      statusProjectProperties = WStoreStatus.loading;
      projectPropertiesError = '';
    });

    subscribe(
      future: ProjectStore().updateProject(
        UpdateProject(
          id: projectId,
          name: projectName,
          color: selectedColor.colorHex,
          postponingTaskDayCount: markAsSnail,
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
  ProjectPropertiesDialogStore createWStore() => ProjectPropertiesDialogStore();

  @override
  Widget build(BuildContext context, ProjectPropertiesDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    store._initData(project, localization);
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.statusProjectProperties,
      onStatusLoaded: (context) {
        Navigator.of(context).pop();
      },
      builder: (context, status) {
        final loading = status == WStoreStatus.loading;
        final error = status == WStoreStatus.error;
        return AppDialogWithButtons(
          title: localization.change_project,
          primaryButtonText: localization.save,
          onPrimaryButtonPressed: () {
            FocusScope.of(context).unfocus();
            store.saveProjectProperties(localization, project.id);
          },
          primaryButtonLoading: loading,
          secondaryButtonText: '',
          children: [
            WStoreValueBuilder(
              store: store,
              watch: (store) => store.projectName,
              builder: (context, projectName) {
                return AddDialogInputField(
                  autofocus: true,
                  initialValue: projectName,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (projectName) {
                    store._setProjectName(projectName);
                  },
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                  },
                  labelText: localization.project_name,
                );
              },
            ),
            const SizedBox(height: 16),
            WStoreValueBuilder(
              watch: (store) => store.selectedColor,
              store: store,
              builder: (context, selectedColor) {
                return AddDialogDropdownMenu<ColorType>(
                  onChanged: (color) {
                    FocusScope.of(context).unfocus();
                    if (color is ColorType) {
                      store._setProjectColor(color);
                    } else {
                      throw Exception('Value has wrong type');
                    }
                  },
                  labelText: localization.color,
                  listValues: store.listProjectColors,
                  currentValue: selectedColor,
                );
              },
            ),
            const SizedBox(height: 16),
            WStoreValueBuilder(
              watch: (store) => store.markAsSnail,
              store: store,
              builder: (context, markAsSnail) {
                return AddDialogDropdownMenu<Nameable>(
                  onChanged: (postponingTaskDayCount) {
                    FocusScope.of(context).unfocus();
                    if (postponingTaskDayCount is Nameable) {
                      store._setMarkAsSnail(postponingTaskDayCount);
                    } else {
                      throw Exception('Value has wrong type');
                    }
                  },
                  labelText: localization.mark_tasks_as_snail,
                  listValues: store.listMarkAsSnail,
                  currentValue: store.listMarkAsSnail[markAsSnail],
                );
              },
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
  }
}
