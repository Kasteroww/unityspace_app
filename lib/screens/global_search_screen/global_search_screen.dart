import 'package:flutter/material.dart';
import 'package:unityspace/screens/app_navigation_drawer.dart';
import 'package:unityspace/screens/widgets/stubs/work_in_progress_stub.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class GlobalSearchScreenStore extends WStore {
  bool isWorkInProgress = true;

  @override
  GlobalSearchScreen get widget => super.widget as GlobalSearchScreen;
}

class GlobalSearchScreen extends WStoreWidget<GlobalSearchScreenStore> {
  const GlobalSearchScreen({
    super.key,
  });

  @override
  GlobalSearchScreenStore createWStore() => GlobalSearchScreenStore();

  @override
  Widget build(BuildContext context, GlobalSearchScreenStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Scaffold(
      drawer: const AppNavigationDrawer(),
      appBar: AppBar(
        title: Text(localization.search),
      ),
      body: store.isWorkInProgress
          ? const WorkInProgressStub()
          : const SizedBox.shrink(),
    );
  }
}
