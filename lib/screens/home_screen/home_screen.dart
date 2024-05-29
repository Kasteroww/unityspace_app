import 'package:flutter/material.dart';
import 'package:unityspace/screens/app_navigation_drawer.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class HomeScreenStore extends WStore {
  // TODO: add data here...

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
      body: Container(),
    );
  }
}
