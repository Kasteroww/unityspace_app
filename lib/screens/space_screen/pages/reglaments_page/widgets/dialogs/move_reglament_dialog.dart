import 'package:flutter/material.dart';
import 'package:unityspace/models/reglament_models.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_dropdown_menu.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/store/reglaments_store.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

Future<void> showMoveReglamentDialog({
  required BuildContext context,
  required List<SpaceColumn> reglamentColumns,
  required Reglament columnReglament,
}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return MoveReglamentDialog(
        columnReglament: columnReglament,
        reglamentColumns: reglamentColumns,
      );
    },
  );
}

class MoveReglamentDialogStore extends WStore {
  int? selectedColumn;
  int? selectedSpace;
  List<SpaceColumn> reglamentColumns = [];

  List<Space> get spaces => computedFromStore(
        store: SpacesStore(),
        getValue: (store) => store.spaces,
        keyName: 'spaces',
      );

  Map<int, Space?> get spacesMap => computedFromStore(
        store: SpacesStore(),
        getValue: (store) => store.spacesMap,
        keyName: 'spacesMap',
      );

  void initData(List<SpaceColumn> reglamentColumns) {
    final space = spacesMap[reglamentColumns.first.spaceId];

    if (space != null) {
      setStore(() {
        this.reglamentColumns = space.reglamentColumns;
        selectedSpace = space.id;
        selectedColumn = reglamentColumns.first.id;
      });
    }
  }

  void setSelectedReglamentColumn(int columnId) {
    setStore(() {
      selectedColumn = columnId;
    });
  }

  void setSelectedSpace(int spaceId) {
    setStore(() {
      selectedSpace = spaceId;
      selectedColumn = getColumnsBySpaceId(spaceId).first.id;
    });
  }

  Future<void> moveReglament({
    required int reglamentId,
    double newOrder = 0,
  }) async {
    await ReglamentsStore().changeReglamentColumnAndOrder(
      reglamentId: reglamentId,
      newColumnId: selectedColumn!,
      newOrder: newOrder,
    );
  }

  List<SpaceColumn> getColumnsBySpaceId(int spaceId) {
    return spaces.firstWhere((space) => space.id == spaceId).reglamentColumns;
  }

  @override
  MoveReglamentDialog get widget => super.widget as MoveReglamentDialog;
}

class MoveReglamentDialog extends WStoreWidget<MoveReglamentDialogStore> {
  final List<SpaceColumn> reglamentColumns;
  final Reglament columnReglament;

  const MoveReglamentDialog({
    required this.columnReglament,
    required this.reglamentColumns,
    super.key,
  });

  @override
  MoveReglamentDialogStore createWStore() => MoveReglamentDialogStore()..initData(reglamentColumns);

  @override
  Widget build(BuildContext context, MoveReglamentDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return AppDialogWithButtons(
      title: localization.move_reglament,
      primaryButtonText: localization.move,
      onPrimaryButtonPressed: () {
        FocusScope.of(context).unfocus();
        if (store.selectedColumn == null) {
          logger.e(localization.column_id_null);
          return;
        }
        store.moveReglament(reglamentId: columnReglament.id);
        Navigator.pop(context);
      },
      secondaryButtonText: '',
      children: [
        // Выбор пространства
        AddDialogDropdownMenu<int?>(
          onChanged: (dynamic spaceId) {
            FocusScope.of(context).unfocus();
            if (spaceId != null) store.setSelectedSpace(spaceId);
          },
          labelText: localization.space,
          listValues: store.spaces.map((space) => (space.id, space.name)).toList(),
          currentValue: store.selectedSpace ?? store.spaces.first.id,
        ),
        const SizedBox(height: 16),
        // Выбор группы
        AddDialogDropdownMenu<int?>(
          onChanged: (dynamic reglamentColumnId) {
            if (reglamentColumnId != null) {
              store.setSelectedReglamentColumn(reglamentColumnId);
            }
            FocusScope.of(context).unfocus();
          },
          labelText: localization.group,
          listValues:
              store.getColumnsBySpaceId(store.selectedSpace!).map((column) => (column.id, column.name)).toList(),
          currentValue: store.selectedColumn,
        ),
      ],
    );
  }
}
