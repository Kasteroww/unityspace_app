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
  String projectName = '';
  CreateProjectErrors createProjectError = CreateProjectErrors.none;
  WStoreStatus statusCreateProject = WStoreStatus.init;

  void setProjectName(String value) {
    setStore(() {
      projectName = value;
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
    if (statusCreateProject == WStoreStatus.loading) return;
    setStore(() {
      statusCreateProject = WStoreStatus.loading;
      createProjectError = CreateProjectErrors.none;
    });
    if (projectName.isEmpty) {
      setStore(() {
        createProjectError = CreateProjectErrors.emptyName;
        statusCreateProject = WStoreStatus.error;
      });
      return;
    }

    subscribe(
      future: SpacesStore().createSpaceColumn(
        spaceId: widget.spaceId,
        name: projectName,
        order: _getNextOrder(),
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
          createProjectError = CreateProjectErrors.createError;
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
      watch: (store) => store.statusCreateProject,
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
                store.setProjectName(value);
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
                store.createSpaceColumn();
              },
              labelText: '${localization.title}:',
            ),
            if (error)
              Text(
                switch (store.createProjectError) {
                  CreateProjectErrors.emptyName =>
                    localization.empty_project_name_error,
                  CreateProjectErrors.createError =>
                    localization.create_project_error,
                  CreateProjectErrors.none => '',
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
