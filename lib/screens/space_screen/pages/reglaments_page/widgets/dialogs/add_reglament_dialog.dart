import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:flutter/material.dart';
import 'package:wstore/wstore.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> showAddReglamentDialog(BuildContext context, int columnId) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AddReglamentDialog(
        columnId: columnId,
      );
    },
  );
}

class AddReglamentDialogStore extends WStore {
  String reglamentName = '';
  String createReglamentError = '';
  WStoreStatus statusCreateReglament = WStoreStatus.init;

  void setReglamentName(String value) {
    setStore(() {
      reglamentName = value;
    });
  }

  void createReglament(AppLocalizations localization) {
    if (statusCreateReglament == WStoreStatus.loading) return;
    setStore(() {
      statusCreateReglament = WStoreStatus.loading;
      createReglamentError = '';
    });
    if (reglamentName.isEmpty) {
      setStore(() {
        createReglamentError = localization.empty_reglament_name_error;
        statusCreateReglament = WStoreStatus.error;
      });
      return;
    }
  }

  @override
  AddReglamentDialog get widget => super.widget as AddReglamentDialog;
}

class AddReglamentDialog extends WStoreWidget<AddReglamentDialogStore> {
  final int columnId;

  const AddReglamentDialog({
    required this.columnId,
    super.key,
  });

  @override
  AddReglamentDialogStore createWStore() => AddReglamentDialogStore();

  @override
  Widget build(BuildContext context, AddReglamentDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.statusCreateReglament,
      onStatusLoaded: (context) {
        Navigator.of(context).pop();
      },
      builder: (context, status) {
        final loading = status == WStoreStatus.loading;
        final error = status == WStoreStatus.error;
        return AppDialogWithButtons(
          title: localization.add_reglament,
          primaryButtonText: localization.create,
          onPrimaryButtonPressed: () {
            FocusScope.of(context).unfocus();
            store.createReglament(localization);
          },
          primaryButtonLoading: loading,
          secondaryButtonText: '',
          children: [
            AddDialogInputField(
              autofocus: true,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                store.setReglamentName(value);
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
                store.createReglament(localization);
              },
              labelText: '${localization.reglament_name}:',
            ),
            if (error)
              Text(
                store.createReglamentError,
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
