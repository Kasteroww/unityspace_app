import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unityspace/screens/space_screen/pages/edit_reglament_page/edit_reglament_page.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/store/reglament_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

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
  WStoreStatus status = WStoreStatus.init;
  late int columnId;
  String createReglamentError = '';
  String reglamentName = '';

  void setReglamentName(String value) {
    setStore(() {
      reglamentName = value;
    });
  }

  Future<void> createReglament(AppLocalizations localization) async {
    if (status == WStoreStatus.loading) return;
    setStore(() {
      status = WStoreStatus.loading;
      createReglamentError = '';
    });

    if (reglamentName.isEmpty) {
      setStore(() {
        createReglamentError = localization.empty_reglament_name_error;
        status = WStoreStatus.error;
      });
      return;
    }
    try {
      await ReglamentsStore().createReglament(
        name: reglamentName,
        columnId: columnId,
        content: '',
      );
      setStore(() {
        status = WStoreStatus.loaded;
        createReglamentError = '';
      });
    } catch (e, stack) {
      logger.d('''
          on Add Reglament Dialog
          'NotificationsStore loadData error=$e\nstack=$stack
        ''');
      setStore(() {
        status = WStoreStatus.error;
        createReglamentError = localization.problem_uploading_data_try_again;
      });
    }
  }

  void initValues(int columnId) {
    this.columnId = columnId;
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
  AddReglamentDialogStore createWStore() =>
      AddReglamentDialogStore()..initValues(columnId);

  @override
  Widget build(BuildContext context, AddReglamentDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.status,
      builder: (context, status) {
        return AppDialogWithButtons(
          title: localization.add_reglament,
          primaryButtonLoading: status == WStoreStatus.loading,
          primaryButtonText: localization.create,
          onPrimaryButtonPressed: () async {
            FocusScope.of(context).unfocus();
            await store.createReglament(localization);
            if (store.status == WStoreStatus.loaded && context.mounted) {
              Navigator.pop(context);
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditReglamentPage(
                    reglamentName: store.reglamentName,
                    columnId: columnId,
                  ),
                ),
              );
            }
          },
          secondaryButtonText: '',
          children: [
            AddDialogInputField(
              autocorrect: false,
              autofocus: true,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                store.setReglamentName(value);
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
              },
              labelText: '${localization.reglament_name}:',
            ),
            if (store.createReglamentError.isNotEmpty)
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
