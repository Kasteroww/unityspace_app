import 'package:flutter/material.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/screens/dialogs/unknown_error_dialog.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

Future<void> showAddSpaceColumnDialog(
  BuildContext context,
  int? spaceId,
) async {
  return showDialog(
    context: context,
    builder: (context) {
      if (spaceId != null) {
        return AddProjectDialog(
          spaceId: spaceId,
        );
      } else {
        return const UnknownErrorDialog();
      }
    },
  );
}

class AddProjectDialogStore extends WStore {
  String columnName = '';
  CreateSpaceColumnErrors createColumnError = CreateSpaceColumnErrors.none;
  WStoreStatus statusCreateColumn = WStoreStatus.init;

  void setColumnName(String value) {
    setStore(() {
      columnName = value;
    });
  }

  ///Получение конкретного пространства по id
  Space? get currentSpace => computedFromStore(
        store: SpacesStore(),
        getValue: (store) => store.spaces[widget.spaceId],
        keyName: 'currentSpace',
      );

  /// Получение колонок с Проектами
  List<SpaceColumn> get projectColumns => computed(
        getValue: () => _getColumns(currentSpace: currentSpace),
        watch: () => [currentSpace],
        keyName: 'projectColumns',
      );

  /// Сортировка колонок проектов по order
  List<SpaceColumn> _getColumns({required Space? currentSpace}) {
    final cols = currentSpace?.columns ?? [];
    cols.sort((a, b) => a.order.compareTo(b.order));
    return cols;
  }

  double _getNextOrder() {
    return projectColumns
            .map((column) => column.order)
            .reduce((max, order) => max > order ? max : order) +
        1;
  }

  void createSpaceColumn() {
    if (statusCreateColumn == WStoreStatus.loading) return;
    setStore(() {
      statusCreateColumn = WStoreStatus.loading;
      createColumnError = CreateSpaceColumnErrors.none;
    });
    if (columnName.isEmpty) {
      setStore(() {
        createColumnError = CreateSpaceColumnErrors.emptyName;
        statusCreateColumn = WStoreStatus.error;
      });
      return;
    }

    subscribe(
      future: SpacesStore().createSpaceColumn(
        spaceId: widget.spaceId,
        name: columnName,
        order: _getNextOrder(),
      ),
      subscriptionId: 1,
      onData: (_) {
        setStore(() {
          statusCreateColumn = WStoreStatus.loaded;
        });
      },
      onError: (error, stack) {
        logger.d(
          'CreateSpaceColumnDialogStore.createSpaceColumn error: $error stack: $stack',
        );
        setStore(() {
          statusCreateColumn = WStoreStatus.error;
          createColumnError = CreateSpaceColumnErrors.createError;
        });
      },
    );
  }

  @override
  AddProjectDialog get widget => super.widget as AddProjectDialog;
}

class AddProjectDialog extends WStoreWidget<AddProjectDialogStore> {
  final int spaceId;

  const AddProjectDialog({
    required this.spaceId,
    super.key,
  });

  @override
  AddProjectDialogStore createWStore() => AddProjectDialogStore();

  @override
  Widget build(BuildContext context, AddProjectDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.statusCreateColumn,
      onStatusLoaded: (context) {
        Navigator.of(context).pop();
      },
      builder: (context, status) {
        final loading = status == WStoreStatus.loading;
        final error = status == WStoreStatus.error;
        return AppDialogWithButtons(
          title: localization.new_group,
          primaryButtonText: localization.create,
          onPrimaryButtonPressed: () {
            FocusScope.of(context).unfocus();
            store.createSpaceColumn();
          },
          primaryButtonLoading: loading,
          secondaryButtonText: '',
          children: [
            AddDialogInputField(
              autofocus: true,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                store.setColumnName(value);
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
                store.createSpaceColumn();
              },
              labelText: '${localization.group_name}:',
            ),
            if (error)
              Text(
                switch (store.createColumnError) {
                  CreateSpaceColumnErrors.emptyName =>
                    localization.empty_group_name_error,
                  CreateSpaceColumnErrors.createError =>
                    localization.create_group_error,
                  CreateSpaceColumnErrors.none => '',
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
