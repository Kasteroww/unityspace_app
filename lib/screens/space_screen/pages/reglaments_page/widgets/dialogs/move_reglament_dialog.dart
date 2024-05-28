import 'package:unityspace/models/reglament_models.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_dropdown_menu.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:flutter/material.dart';
import 'package:unityspace/store/reglament_store.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:wstore/wstore.dart';
import 'package:unityspace/utils/localization_helper.dart';

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
  late SpaceColumn selectedColumn;
  late Space selectedSpace;
  List<SpaceColumn> reglamentColumns = [];

  List<Space> get spaces => computedFromStore(
        store: SpacesStore(),
        getValue: (store) => store.spaces,
        keyName: 'spaces',
      );

  void initData(List<SpaceColumn> reglamentColumns) {
    setStore(() {
      this.reglamentColumns = reglamentColumns;
      selectedColumn = reglamentColumns.first;
      selectedSpace = spaces.first;
    });
  }

  void setSelectedReglamentColumn(SpaceColumn column) {
    setStore(() {
      selectedColumn = column;
    });
  }

  void setSelectedSpace(Space space) {
    setStore(() {
      selectedSpace = space;
    });
  }

  Future<void> moveReglament({
    required int reglamentId,
    int newOrder = 0,
  }) async {
    ReglamentsStore().changeReglamentColumnAndOrder(
        reglamentId: reglamentId,
        newColumnId: selectedColumn.id,
        newOrder: newOrder);
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
  MoveReglamentDialogStore createWStore() =>
      MoveReglamentDialogStore()..initData(reglamentColumns);

  @override
  Widget build(BuildContext context, MoveReglamentDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return AppDialogWithButtons(
      title: localization.move_reglament,
      primaryButtonText: localization.move,
      onPrimaryButtonPressed: () {
        FocusScope.of(context).unfocus();
        store.moveReglament(reglamentId: columnReglament.id);
        Navigator.pop(context);
      },
      secondaryButtonText: '',
      children: [
        //Выбор пространства
        AddDialogDropdownMenu<Space>(
          onChanged: (space) {
            store.setSelectedSpace(space);
            FocusScope.of(context).unfocus();
          },
          labelText: localization.space,
          listValues: store.spaces,
          currentValue: store.spaces.first,
        ),
        const SizedBox(height: 16),
        //Выбор группы
        AddDialogDropdownMenu<SpaceColumn>(
          onChanged: (reglamentColumn) {
            store.setSelectedReglamentColumn(reglamentColumn);
            FocusScope.of(context).unfocus();
          },
          labelText: localization.group,
          listValues: store.getColumnsBySpaceId(store.selectedSpace.id),
        ),
      ],
    );
  }
}
