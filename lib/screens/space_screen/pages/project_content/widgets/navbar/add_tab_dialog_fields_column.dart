import 'package:flutter/material.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/navbar/add_tab_dialog.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class AddTabDialogFieldsColumn extends StatelessWidget {
  const AddTabDialogFieldsColumn({this.tabDescription, super.key});

  final String? tabDescription;

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Column(
      children: [
        Text(tabDescription ?? ''),
        const SizedBox(height: 15),
        if (context.wstore<AddTabDialogStore>().selectedCategory ==
            AddTabDialogTypes.categoryDocs)
          Text(localization.add_tab_body_text)
        else ...[
          WStoreBuilder(
            store: context.wstore<AddTabDialogStore>(),
            watch: (store) => [store.name],
            builder: (context, store) {
              return AddDialogInputField(
                initialValue: store.name,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.words,
                onChanged: (tabName) {
                  store.setTabName(tabName);
                },
                onEditingComplete: () {
                  FocusScope.of(context).unfocus();
                },
                labelText: localization.name,
              );
            },
          ),
          const SizedBox(height: 16),
          WStoreBuilder(
            store: context.wstore<AddTabDialogStore>(),
            watch: (store) => [store.url],
            builder: (context, store) {
              return AddDialogInputField(
                initialValue: store.url,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.words,
                onChanged: (tabLink) {
                  store.setTabLink(tabLink);
                },
                onEditingComplete: () {
                  FocusScope.of(context).unfocus();
                },
                labelText: localization.link,
              );
            },
          ),
        ],
      ],
    );
  }
}
