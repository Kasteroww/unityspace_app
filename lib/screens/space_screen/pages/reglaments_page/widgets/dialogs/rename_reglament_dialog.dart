import 'package:flutter/material.dart';
import 'package:unityspace/models/reglament_models.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/resources/l10n/app_localizations.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/service/data_exceptions.dart';
import 'package:unityspace/store/reglaments_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

Future<void> showRenameReglamentDialog(
  BuildContext context,
  Reglament reglament,
) async {
  return showDialog(
    context: context,
    builder: (context) {
      return RenameReglamentDialog(
        reglament: reglament,
      );
    },
  );
}

class RenameReglamentDialogStore extends WStore {
  WStoreStatus status = WStoreStatus.init;
  late Reglament reglament;
  RenameReglamentErrors renameReglamentError = RenameReglamentErrors.none;
  String reglamentName = '';

  void setReglamentName(String value) {
    setStore(() {
      reglamentName = value;
    });
  }

  Future<void> renameReglament() async {
    if (status == WStoreStatus.loading) return;
    setStore(() {
      status = WStoreStatus.loading;
      renameReglamentError = RenameReglamentErrors.none;
    });

    if (reglamentName.isEmpty) {
      setStore(() {
        renameReglamentError = RenameReglamentErrors.emptyName;
        status = WStoreStatus.error;
      });
      return;
    }
    try {
      await ReglamentsStore()
          .renameReglament(reglamentId: reglament.id, name: reglamentName);
      setStore(() {
        status = WStoreStatus.loaded;
        renameReglamentError = RenameReglamentErrors.none;
      });
    } catch (e, stack) {
      logger.d('''
          on RenameReglamentDialog loadData error=$e\nstack=$stack
        ''');
      setStore(() {
        status = WStoreStatus.error;
        renameReglamentError = RenameReglamentErrors.problemUploadingData;
      });
      throw LoadDataException(
        'on rename reglament excetpion',
        e,
        stack,
      );
    }
  }

  void initValues(Reglament reglament) {
    this.reglament = reglament;
  }

  @override
  RenameReglamentDialog get widget => super.widget as RenameReglamentDialog;
}

class RenameReglamentDialog extends WStoreWidget<RenameReglamentDialogStore> {
  final Reglament reglament;

  const RenameReglamentDialog({
    required this.reglament,
    super.key,
  });

  @override
  RenameReglamentDialogStore createWStore() =>
      RenameReglamentDialogStore()..initValues(reglament);

  String getErrorLocalization({
    required RenameReglamentErrors error,
    required AppLocalizations localization,
  }) {
    switch (error) {
      case RenameReglamentErrors.emptyName:
        return localization.empty_reglament_name_error;
      case RenameReglamentErrors.problemUploadingData:
        return localization.problem_uploading_data_try_again;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context, RenameReglamentDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.status,
      builder: (context, status) {
        final error = getErrorLocalization(
          error: store.renameReglamentError,
          localization: localization,
        );
        return AppDialogWithButtons(
          title: localization.rename_reglament,
          primaryButtonLoading: status == WStoreStatus.loading,
          primaryButtonText: localization.save,
          onPrimaryButtonPressed: () async {
            FocusScope.of(context).unfocus();
            await store.renameReglament();
            if (store.status == WStoreStatus.loaded && context.mounted) {
              Navigator.pop(context);
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
            if (error.isNotEmpty)
              Text(
                error,
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
