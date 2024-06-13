import 'package:flutter/material.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_dropdown_menu.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/store/projects_store.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

Future<void> showMoveTaskDialog(
  BuildContext context,
  int projectId,
  int stageId,
) async {
  return showDialog(
    context: context,
    builder: (context) => MoveTaskDialog(
      projectId: projectId,
      stageId: stageId,
    ),
  );
}

class MoveTaskDialogStore extends WStore {
  MoveProjectErrors moveProjectError = MoveProjectErrors.none;
  int? currentSpaceId;
  int? currentProjectId;
  int? currentStageId;

  @override
  MoveTaskDialog get widget => super.widget as MoveTaskDialog;

  Spaces get spaces => computedFromStore(
        store: SpacesStore(),
        keyName: 'spaces',
        getValue: (store) => store.spaces,
      );
  Project? get currentProject => computedFromStore(
        store: ProjectsStore(),
        keyName: 'project',
        getValue: (store) {
          return store.getProjectById(widget.projectId);
        },
      );

  List<Project> get allProjects => computedFromStore(
        store: ProjectsStore(),
        getValue: (store) {
          return store.projects.list;
        },
        keyName: 'allProjects',
      );

  /// Получаем все простраства и ковертируем в Record.
  List<(int?, String)> get getAllSpaces => spaces.list
      .map(
        (space) => (space.id, space.name),
      )
      .toList();

  /// Получаем все колонки этапов и ковертируем в Record.
  List<(int?, String)> get getProjectStages =>
      currentProject?.stages
          .map(
            (stage) => (stage.id, stage.name),
          )
          .toList() ??
      [];

  /// Получаем все проекты и ковертируем в Record.
  List<(int?, String)> get getAllProject => allProjects
      .map(
        (project) => (
          project.id,
          project.name.length > 25
              ? '${project.name.substring(0, 25)}...'
              : project.name,
        ),
      )
      .toList();

  void initData() {
    setStore(() {
      currentSpaceId = currentProject?.spaceId;
      currentProjectId = currentProject?.id;
      currentStageId = widget.stageId;
    });
  }

  void setSelectedSpaceId(int? spaceId) {
    if (spaceId != null) {
      setStore(() {
        currentSpaceId = spaceId;
      });
    }
  }

  void setSelectedProjectId(int? projectId) {
    if (projectId != null) {
      setStore(() {
        currentProjectId = projectId;
      });
    }
  }

  void setSelectedStageId(int? stageId) {
    if (stageId != null) {
      setStore(() {
        currentStageId = stageId;
      });
    }
  }
}

class MoveTaskDialog extends WStoreWidget<MoveTaskDialogStore> {
  const MoveTaskDialog({
    required this.projectId,
    required this.stageId,
    super.key,
  });

  final int projectId;
  final int stageId;

  @override
  MoveTaskDialogStore createWStore() => MoveTaskDialogStore();

  @override
  void initWStore(MoveTaskDialogStore store) {
    store.initData();
  }

  @override
  Widget build(BuildContext context, MoveTaskDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreBuilder<MoveTaskDialogStore>(
      watch: (store) {
        return [
          store.currentSpaceId,
          store.currentProjectId,
          store.currentStageId,
        ];
      },
      builder: (context, store) {
        return AppDialogWithButtons(
          title: localization.move_task,
          primaryButtonText: localization.move,
          onPrimaryButtonPressed: () {},
          secondaryButtonText: '',
          children: [
            AddDialogDropdownMenu<int?>(
              onChanged: (dynamic spaceId) {
                FocusScope.of(context).unfocus();
                store.setSelectedSpaceId(spaceId);
              },
              labelText: localization.space,
              listValues: store.getAllSpaces,
              currentValue: store.currentSpaceId ?? store.spaces.list.first.id,
            ),
            AddDialogDropdownMenu<int?>(
              onChanged: (dynamic projectId) {
                FocusScope.of(context).unfocus();
                store.setSelectedProjectId(projectId);
              },
              labelText: localization.project,
              listValues: store.getAllProject,
              currentValue:
                  store.currentProjectId ?? store.spaces.list.first.id,
            ),
            AddDialogDropdownMenu<int?>(
              onChanged: (dynamic spaceId) {
                FocusScope.of(context).unfocus();
                store.setSelectedStageId(stageId);
              },
              labelText: localization.column,
              listValues: store.getProjectStages,
              currentValue: store.currentStageId,
            ),
          ],
        );
      },
    );
  }
}
