import 'package:flutter/material.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog.dart';
import 'package:unityspace/utils/localization_helper.dart';

Future<void> showDeleteNoRulesDialog(
  BuildContext context,
  OrganizationMember? owner,
) async {
  final localization = LocalizationHelper.getLocalizations(context);
  return showDialog(
    context: context,
    builder: (context) {
      return AppDialog(
        title: localization.delete_project_no_rights_error,
        buttons: const [],
        children: const [],
      );
    },
  );
}
