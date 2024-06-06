import 'package:flutter/material.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_dropdown_menu.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/store/projects_store.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

Future<void> showMoveProjectDialog(
  BuildContext context,
  SpaceColumn selectedColumn,
  int projectId,
) async {
  return showDialog(
    context: context,
    builder: (context) {
      return MoveProjectDialog(
        selectedColumn: selectedColumn,
        projectId: projectId,
      );
    },
  );
}

class MoveProjectDialogStore extends WStore {
  MoveProjectErrors moveProjectError = MoveProjectErrors.none;
  WStoreStatus statusMoveProject = WStoreStatus.init;
  int? selectedSpaceId;
  int? selectedColumnId;

  List<Space> get spaces => computedFromStore(
        store: SpacesStore(),
        keyName: 'spaces',
        getValue: (store) => store.spaces,
      );

  List<SpaceColumn> getColumnsBySpaceId(int? spaceId) {
    return spaces.firstWhere((space) => space.id == spaceId).columns;
  }

  void initData(SpaceColumn column) {
    selectedSpaceId =
        spaces.firstWhere((space) => space.id == column.spaceId).id;
    selectedColumnId = column.id;
  }

  void setSelectedSpace(int? spaceId) {
    if (spaceId != null) {
      setStore(() {
        selectedSpaceId = spaceId;
        selectedColumnId = getColumnsBySpaceId(spaceId).first.id;
      });
    }
  }

  void setSelectedColumn(int? columnId) {
    if (columnId != null) {
      setStore(() {
        selectedColumnId = columnId;
      });
    }
  }

  void moveProject(int projectId) {
    if (statusMoveProject == WStoreStatus.loading) return;

    if (selectedColumnId == null) {
      setStore(() {
        statusMoveProject = WStoreStatus.error;
        moveProjectError = MoveProjectErrors.columnIdIsNull;
        return;
      });
    }

    setStore(() {
      statusMoveProject = WStoreStatus.loading;
      moveProjectError = MoveProjectErrors.none;
    });

    subscribe(
      future:
          ProjectsStore().changeProjectColumn([projectId], selectedColumnId!),
      subscriptionId: 1,
      onData: (_) {
        setStore(() {
          statusMoveProject = WStoreStatus.loaded;
        });
      },
      onError: (error, stack) {
        logger.d(
          'MoveProjectDialogStore.moveProject error: $error stack: $stack',
        );
        setStore(() {
          statusMoveProject = WStoreStatus.error;
          moveProjectError = MoveProjectErrors.moveProjectError;
        });
      },
    );
  }

  @override
  MoveProjectDialog get widget => super.widget as MoveProjectDialog;
}

class MoveProjectDialog extends WStoreWidget<MoveProjectDialogStore> {
  final SpaceColumn selectedColumn;
  final int projectId;

  const MoveProjectDialog({
    required this.selectedColumn,
    required this.projectId,
    super.key,
  });

  @override
  MoveProjectDialogStore createWStore() =>
      MoveProjectDialogStore()..initData(selectedColumn);

  @override
  Widget build(BuildContext context, MoveProjectDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.statusMoveProject,
      onStatusLoaded: (context) {
        Navigator.of(context).pop();
      },
      builder: (context, status) {
        final loading = status == WStoreStatus.loading;
        final error = status == WStoreStatus.error;
        return WStoreBuilder<MoveProjectDialogStore>(
          watch: (store) => [store.selectedSpaceId],
          store: context.wstore(),
          builder: (context, store) {
            return AppDialogWithButtons(
              title: localization.move_project,
              primaryButtonText: localization.move,
              onPrimaryButtonPressed: () {
                FocusScope.of(context).unfocus();
                store.moveProject(projectId);
              },
              primaryButtonLoading: loading,
              secondaryButtonText: '',
              children: [
                AddDialogDropdownMenu<int?>(
                  onChanged: (spaceId) {
                    FocusScope.of(context).unfocus();
                    store.setSelectedSpace(spaceId);
                  },
                  labelText: localization.space,
                  listValues: store.spaces
                      .map((space) => (space.id, space.name))
                      .toList(),
                  currentValue: store.selectedSpaceId,
                ),
                const SizedBox(height: 16),
                AddDialogDropdownMenu<int?>(
                  onChanged: (int? columnId) {
                    FocusScope.of(context).unfocus();
                    store.setSelectedColumn(columnId);
                  },
                  labelText: localization.group,
                  listValues: store
                      .getColumnsBySpaceId(store.selectedSpaceId)
                      .map((column) => (column.id, column.name))
                      .toList(),
                  currentValue: store.selectedColumnId,
                ),
                if (error)
                  Text(
                    switch (store.moveProjectError) {
                      MoveProjectErrors.columnIdIsNull =>
                        localization.column_id_null,
                      MoveProjectErrors.moveProjectError =>
                        localization.move_project_error,
                      MoveProjectErrors.none => ''
                    },
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
