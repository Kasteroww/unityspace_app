import 'package:flutter/material.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/resources/l10n/app_localizations.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/store/groups_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

Future<int?> showRenameSpacesGroupDialog({
  required BuildContext context,
  required int groupId,
  required String currentName,
}) async {
  return showDialog<int?>(
    context: context,
    builder: (_) {
      return RenameSpacesGroupDialog(
        groupId: groupId,
        currentName: currentName,
      );
    },
  );
}

class RenameSpacesGroupStore extends WStore {
  WStoreStatus status = WStoreStatus.init;
  RenameSpacesGroupErrors renameGroupError = RenameSpacesGroupErrors.none;

  bool isChangingName = false;
  String newName = '';

  GroupsStore groupsStore = GroupsStore();

  void setNewName(String value) {
    setStore(() {
      newName = value;
    });
  }

  void renameSpacesGroup() {
    if (status == WStoreStatus.loading) return;
    //
    setStore(() {
      renameGroupError = RenameSpacesGroupErrors.none;
      status = WStoreStatus.loading;
    });
    //
    final String name = newName.trim();
    if (name.isEmpty) {
      setStore(() {
        status = WStoreStatus.error;
        renameGroupError = RenameSpacesGroupErrors.emptyName;
      });
      return;
    }
    if (name == widget.currentName) {
      setStore(() {
        status = WStoreStatus.error;
        renameGroupError = RenameSpacesGroupErrors.newNameMatchesOld;
      });
      return;
    }

    subscribe(
      future: groupsStore.updateGroupName(id: widget.groupId, newName: newName),
      subscriptionId: 1,
      onData: (id) {
        setStore(() {
          status = WStoreStatus.loaded;
        });
      },
      onError: (error, __) {
        setStore(() {
          status = WStoreStatus.error;
          renameGroupError = RenameSpacesGroupErrors.renameSpacesGroupError;
        });
      },
    );
  }

  @override
  RenameSpacesGroupDialog get widget => super.widget as RenameSpacesGroupDialog;
}

class RenameSpacesGroupDialog extends WStoreWidget<RenameSpacesGroupStore> {
  const RenameSpacesGroupDialog({
    required this.groupId,
    required this.currentName,
    super.key,
  });
  final int groupId;
  final String currentName;

  String getErrorLocalization({
    required RenameSpacesGroupErrors error,
    required AppLocalizations localization,
  }) {
    switch (error) {
      case RenameSpacesGroupErrors.emptyName:
        return localization.rename_spaces_group_empty_name;
      case RenameSpacesGroupErrors.newNameMatchesOld:
        return localization.rename_spaces_group_new_name_matches_old;
      case RenameSpacesGroupErrors.renameSpacesGroupError:
        return localization.rename_spaces_group_error;
      default:
        return '';
    }
  }

  @override
  RenameSpacesGroupStore createWStore() => RenameSpacesGroupStore();

  @override
  Widget build(BuildContext context, RenameSpacesGroupStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStatusBuilder<RenameSpacesGroupStore>(
      store: store,
      watch: (store) => store.status,
      onStatusLoaded: (context) {
        if (context.mounted) {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        }
      },
      builder: (context, status) {
        final loading = status == WStoreStatus.loading;
        final error = status == WStoreStatus.error;
        return AppDialogWithButtons(
          title: localization.rename_spaces_group_dialog_title,
          primaryButtonText: localization.save,
          onPrimaryButtonPressed: () {
            FocusScope.of(context).unfocus();
            store.renameSpacesGroup();
          },
          primaryButtonLoading: loading,
          secondaryButtonText: '',
          children: [
            AddDialogInputField(
              labelText: localization.spaces_group_name,
              autofocus: true,
              initialValue: currentName,
              onChanged: (value) => store.setNewName(value),
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
                store.renameSpacesGroup();
              },
            ),
            if (error)
              Text(
                switch (store.renameGroupError) {
                  RenameSpacesGroupErrors.emptyName =>
                    localization.rename_spaces_group_empty_name,
                  RenameSpacesGroupErrors.newNameMatchesOld =>
                    localization.rename_spaces_group_new_name_matches_old,
                  RenameSpacesGroupErrors.renameSpacesGroupError =>
                    localization.rename_spaces_group_error,
                  RenameSpacesGroupErrors.none => '',
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
