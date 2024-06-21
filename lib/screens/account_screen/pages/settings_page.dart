import 'package:flutter/material.dart';
import 'package:unityspace/screens/widgets/stubs/work_in_progress_stub.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class SettingsPageStore extends WStore {
  bool isWorkInProgress = true;

  @override
  SettingsPage get widget => super.widget as SettingsPage;
}

class SettingsPage extends WStoreWidget<SettingsPageStore> {
  const SettingsPage({
    super.key,
  });

  @override
  SettingsPageStore createWStore() => SettingsPageStore();

  @override
  Widget build(BuildContext context, SettingsPageStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return store.isWorkInProgress
        ? const WorkInProgressStub()
        : Text(localization.settings);
  }
}
