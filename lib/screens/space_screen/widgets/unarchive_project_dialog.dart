import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_dropdown_menu.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/store/project_store.dart';
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
  String moveProjectError = '';
  WStoreStatus statusMoveProject = WStoreStatus.init;
  List<Space> spaces = [];
  int selectedSpaceId = 0;
  int selectedColumnId = 0;
  late Space selectedSpace;
  late SpaceColumn selectedColumn;

  List<SpaceColumn> getColumnsBySpaceId(int spaceId) {
    return spaces.where((el) => el.id == spaceId).first.columns;
  }

  void setSelectedSpaceId(int spaceId) {
    setStore(() {
      selectedSpaceId = spaceId;
    });
  }

  void setSelectedColumnId(int columnId) {
    setStore(() {
      selectedColumnId = columnId;
    });
  }

  void initData(SpaceColumn column) {
    setStore(() {
      spaces = SpacesStore().spaces;
      selectedSpace = spaces.where((el) => el.id == column.spaceId).first;
      selectedColumn = column;
      selectedSpaceId = selectedSpace.id;
      selectedColumnId = column.id;
    });
  }

  void moveProject(AppLocalizations localization, int projectId) {
    if (statusMoveProject == WStoreStatus.loading) return;
    setStore(() {
      statusMoveProject = WStoreStatus.loading;
      moveProjectError = '';
    });

    subscribe(
      future: ProjectStore().changeProjectColumn([projectId], selectedColumnId),
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
          moveProjectError = localization.move_project_error;
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
          watch: (store) => [store.selectedSpace],
          store: context.wstore(),
          builder: (context, store) {
            return AppDialogWithButtons(
              title: localization.move_project,
              primaryButtonText: localization.move,
              onPrimaryButtonPressed: () {
                FocusScope.of(context).unfocus();
                store.moveProject(localization, projectId);
              },
              primaryButtonLoading: loading,
              secondaryButtonText: '',
              children: [
                AddDialogDropdownMenu<Space>(
                  onChanged: (space) {
                    FocusScope.of(context).unfocus();
                    if (space is Space) {
                      store.setSelectedSpaceId(space.id);
                    }
                  },
                  labelText: localization.space,
                  listValues: store.spaces,
                  currentValue: store.selectedSpace,
                ),
                const SizedBox(height: 16),
                AddDialogDropdownMenu<SpaceColumn>(
                  onChanged: (value) {
                    FocusScope.of(context).unfocus();
                    if (value is SpaceColumn) {
                      store.setSelectedColumnId(value.id);
                    } else {
                      throw Exception('Value has wrong type');
                    }
                  },
                  labelText: localization.group,
                  listValues: store.getColumnsBySpaceId(store.selectedSpaceId),
                ),
                if (error)
                  Text(
                    store.moveProjectError,
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
