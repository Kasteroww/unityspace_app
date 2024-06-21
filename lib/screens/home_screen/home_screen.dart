import 'package:flutter/material.dart';
import 'package:unityspace/screens/app_navigation_drawer.dart';
import 'package:unityspace/screens/widgets/stubs/work_in_progress_stub.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class HomeScreenStore extends WStore {
  bool isWorkInProgress = true;

  @override
  HomeScreen get widget => super.widget as HomeScreen;
}

class HomeScreen extends WStoreWidget<HomeScreenStore> {
  const HomeScreen({
    super.key,
  });

  @override
  HomeScreenStore createWStore() => HomeScreenStore();

  @override
  Widget build(BuildContext context, HomeScreenStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Scaffold(
      drawer: const AppNavigationDrawer(),
      appBar: AppBar(
        title: Text(localization.main),
      ),
      body: store.isWorkInProgress
          ? const WorkInProgressStub()
          : const SizedBox.shrink(),
    );
  }
}
