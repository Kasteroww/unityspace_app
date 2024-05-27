import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_dropdown_menu.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:flutter/material.dart';
import 'package:unityspace/store/project_store.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> showUnarchiveProjectDialog(
    BuildContext context, int spaceId, int projectId) async {
  return showDialog(
    context: context,
    builder: (context) {
      return UnarchiveProjectDialog(
        spaceId: spaceId,
        projectId: projectId,
      );
    },
  );
}

class UnarchiveProjectDialogStore extends WStore {
  String unarchiveProjectError = '';
  WStoreStatus statusUnarchiveProject = WStoreStatus.init;
  List<Space> spaces = [];
  int selectedSpaceId = 0;
  late Space selectedSpace;
  int selectedColumnId = 0;

  List<SpaceColumn> getColumnNamesBySpaceId(int spaceId) {
    return spaces.where((el) => el.id == spaceId).first.columns;
  }

  void setSelectedSpaceId(int spaceId) {
    setStore(() {
      selectedSpaceId = spaceId;
    });
  }

  void setColumnIdToUnarchive(int columnId) {
    setStore(() {
      selectedColumnId = columnId;
    });
  }

  void initData(int spaceId) {
    setStore(() {
      spaces = SpacesStore().spaces;
      selectedSpace = spaces.where((el) => el.id == spaceId).first;
      selectedSpaceId = spaces.where((el) => el.id == spaceId).first.id;
      selectedColumnId = getColumnNamesBySpaceId(selectedSpaceId).first.id;
    });
  }

  void unarchiveProject(AppLocalizations localization, projectId) {
    if (statusUnarchiveProject == WStoreStatus.loading) return;
    setStore(() {
      statusUnarchiveProject = WStoreStatus.loading;
      unarchiveProjectError = '';
    });

    subscribe(
      future: ProjectStore().changeProjectColumn([projectId], selectedColumnId),
      subscriptionId: 1,
      onData: (_) {
        setStore(() {
          statusUnarchiveProject = WStoreStatus.loaded;
        });
      },
      onError: (error, stack) {
        logger.d(
            'UnarchiveProjectDialogStore.unarchiveProject error: $error stack: $stack');
        setStore(() {
          statusUnarchiveProject = WStoreStatus.error;
          unarchiveProjectError = localization.unarchive_project_error;
        });
      },
    );
  }

  @override
  UnarchiveProjectDialog get widget => super.widget as UnarchiveProjectDialog;
}

class UnarchiveProjectDialog extends WStoreWidget<UnarchiveProjectDialogStore> {
  final int spaceId;
  final int projectId;

  const UnarchiveProjectDialog({
    required this.spaceId,
    required this.projectId,
    super.key,
  });

  @override
  UnarchiveProjectDialogStore createWStore() =>
      UnarchiveProjectDialogStore()..initData(spaceId);

  @override
  Widget build(BuildContext context, UnarchiveProjectDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.statusUnarchiveProject,
      onStatusLoaded: (context) {
        Navigator.of(context).pop();
      },
      builder: (context, status) {
        final loading = status == WStoreStatus.loading;
        final error = status == WStoreStatus.error;
        return WStoreBuilder<UnarchiveProjectDialogStore>(
            watch: (store) => [store.selectedSpace],
            store: context.wstore(),
            builder: (context, store) {
              return AppDialogWithButtons(
                title: localization.move_project,
                primaryButtonText: localization.move,
                onPrimaryButtonPressed: () {
                  FocusScope.of(context).unfocus();
                  store.unarchiveProject(localization, projectId);
                },
                primaryButtonLoading: loading,
                secondaryButtonText: '',
                children: [
                  AddDialogDropdownMenu<Space>(
                    onChanged: (spaceId) {
                      FocusScope.of(context).unfocus();
                      store.setSelectedSpaceId(spaceId);
                      store.getColumnNamesBySpaceId(spaceId);
                    },
                    labelText: localization.space,
                    listValues: store.spaces,
                    currentSpace: store.selectedSpace,
                  ),
                  const SizedBox(height: 16),
                  AddDialogDropdownMenu<SpaceColumn>(
                    onChanged: (value) {
                      FocusScope.of(context).unfocus();
                      store.setColumnIdToUnarchive(value);
                    },
                    labelText: localization.group,
                    listValues:
                        store.getColumnNamesBySpaceId(store.selectedSpaceId),
                  ),
                  if (error)
                    Text(
                      store.unarchiveProjectError,
                      style: const TextStyle(
                        color: Color(0xFFD83400),
                      ),
                    ),
                ],
              );
            });
      },
    );
  }
}
