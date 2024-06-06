import 'package:flutter/material.dart';
import 'package:unityspace/screens/administration_screen/pages/users_in_organization_page.dart';
import 'package:unityspace/screens/app_navigation_drawer.dart';
import 'package:unityspace/screens/widgets/appbar.dart';
import 'package:unityspace/screens/widgets/tabs_list/tab_button.dart';
import 'package:unityspace/screens/widgets/tabs_list/tabs_list_row.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class AdministrationScreenStore extends WStore {
  AdministrationScreenTab selectedTab = AdministrationScreenTab.users;

  List<AdministrationScreenTab> get currentUserTabs =>
      AdministrationScreenTab.values.toList();
  @override
  AdministrationScreen get widget => super.widget as AdministrationScreen;
}

class AdministrationScreen extends WStoreWidget<AdministrationScreenStore> {
  const AdministrationScreen({
    super.key,
  });

  @override
  AdministrationScreenStore createWStore() => AdministrationScreenStore();

  @override
  Widget build(BuildContext context, AdministrationScreenStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Scaffold(
      drawer: const AppNavigationDrawer(),
      appBar: CustomAppBar(
        titleText: localization.administration,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WStoreBuilder(
            store: store,
            watch: (store) => [store.selectedTab, store.currentUserTabs],
            builder: (context, store) => TabsListRow(
              children: [
                ...store.currentUserTabs.map(
                  (tab) => TabButton(
                    title: switch (tab) {
                      AdministrationScreenTab.users =>
                        localization.members_of_the_organization
                    },
                    onPressed: () {},
                    selected: tab == store.selectedTab,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: WStoreValueBuilder(
              store: store,
              watch: (store) => store.selectedTab,
              builder: (context, selectedTab) {
                return switch (selectedTab) {
                  AdministrationScreenTab.users =>
                    const UsersInOrganizationPage(),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum AdministrationScreenTab { users }
