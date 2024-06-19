import 'package:flutter/material.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/resources/l10n/app_localizations.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_primary_button.dart';
import 'package:unityspace/service/exceptions/http_exceptions.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

Future<int?> showAddSpaceDialog(BuildContext context) async {
  return showDialog<int?>(
    context: context,
    builder: (context) {
      return const AddSpaceDialog();
    },
  );
}

class AddSpaceDialogStore extends WStore {
  final TextEditingController textEditingController = TextEditingController();
  WStoreStatus status = WStoreStatus.init;
  AddSpaceErrors addSpaceError = AddSpaceErrors.none;
  int newSpaceId = 0;

  void addSpace() {
    if (status == WStoreStatus.loading) return;
    //
    setStore(() {
      newSpaceId = 0;
      addSpaceError = AddSpaceErrors.none;
      status = WStoreStatus.loading;
    });
    //
    final String title = textEditingController.text.trim();
    if (title.isEmpty) {
      setStore(() {
        status = WStoreStatus.error;
        addSpaceError = AddSpaceErrors.emptyName;
      });
      return;
    }
    //
    subscribe(
      future: SpacesStore().createSpace(title),
      subscriptionId: 1,
      onData: (id) {
        setStore(() {
          newSpaceId = id;
          status = WStoreStatus.loaded;
        });
      },
      onError: (error, __) {
        AddSpaceErrors currentError = AddSpaceErrors.createError;
        if (error is SpacesCannotAddPaidTariffHttpException) {
          currentError = AddSpaceErrors.paidTariffError;
        }
        setStore(() {
          status = WStoreStatus.error;
          addSpaceError = currentError;
        });
      },
    );
  }

  @override
  AddSpaceDialog get widget => super.widget as AddSpaceDialog;

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
}

class AddSpaceDialog extends WStoreWidget<AddSpaceDialogStore> {
  const AddSpaceDialog({
    super.key,
  });

  String getErrorLocalization({
    required AddSpaceErrors error,
    required AppLocalizations localization,
  }) {
    switch (error) {
      case AddSpaceErrors.emptyName:
        return localization.empty_space_error;
      case AddSpaceErrors.createError:
        return localization.create_space_error;
      case AddSpaceErrors.paidTariffError:
        return localization.paid_tariff_error;
      default:
        return '';
    }
  }

  @override
  AddSpaceDialogStore createWStore() => AddSpaceDialogStore();

  @override
  Widget build(BuildContext context, AddSpaceDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return AppDialog(
      title: localization.add_space,
      buttons: [
        WStoreStatusBuilder(
          store: store,
          watch: (store) => store.status,
          builder: (context, status) {
            final loading = status == WStoreStatus.loading;
            return AppDialogPrimaryButton(
              onPressed: () {
                store.addSpace();
              },
              text: localization.add_space,
              loading: loading,
            );
          },
          onStatusLoaded: (context) {
            Navigator.of(context).pop(store.newSpaceId);
          },
        ),
      ],
      children: [
        Text(
          localization.create_a_space_and_add_your_colleagues,
        ),
        const SizedBox(height: 12),
        Text(
          localization.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        TextField(
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          controller: store.textEditingController,
          onEditingComplete: () {
            store.addSpace();
          },
        ),
        WStoreValueBuilder(
          store: store,
          watch: (store) => store.addSpaceError,
          builder: (context, error) {
            final String errorText =
                getErrorLocalization(error: error, localization: localization);
            if (errorText.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                errorText,
                style: const TextStyle(
                  color: Color(0xFFBE4500),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
