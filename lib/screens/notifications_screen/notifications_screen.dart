import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/screens/app_navigation_drawer.dart';
import 'package:unityspace/screens/notifications_screen/pages/archived_notifications_page.dart';
import 'package:unityspace/screens/notifications_screen/pages/notifications_page.dart';
import 'package:unityspace/screens/widgets/common/appbar.dart';
import 'package:unityspace/screens/widgets/tabs_list/tab_button.dart';
import 'package:unityspace/screens/widgets/tabs_list/tabs_list_row.dart';
import 'package:wstore/wstore.dart';
import 'package:unityspace/utils/localization_helper.dart';

enum NotificationErrors { none, loadingDataError }

class NotificationsScreenStore extends WStore {
  NotificationsScreenTab selectedTab = NotificationsScreenTab.current;

  void selectTab(final NotificationsScreenTab tab) {
    setStore(() {
      selectedTab = tab;
    });
  }

  List<NotificationsScreenTab> get currentUserTabs =>
      NotificationsScreenTab.values.toList();
  @override
  NotificationsScreen get widget => super.widget as NotificationsScreen;
}

class NotificationsScreen extends WStoreWidget<NotificationsScreenStore> {
  const NotificationsScreen({
    super.key,
  });

  @override
  NotificationsScreenStore createWStore() => NotificationsScreenStore();

  @override
  Widget build(BuildContext context, NotificationsScreenStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Scaffold(
      drawer: const AppNavigationDrawer(),
      appBar: CustomAppBar(
        titleText: localization.notifications,
        actions: [
          InkWell(
            child: SizedBox(
              height: 55,
              width: 55,
              child: SvgPicture.asset('assets/icons/settings.svg')),
          )
        ],
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
                    title: tab.title,
                    onPressed: () {
                      store.selectTab(tab);
                    },
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
                    NotificationsScreenTab.current => const NotificationsPage(),
                    NotificationsScreenTab.achievements =>
                      const ArchivedNotificationsPage(),
                  };
                }),
          ),
        ],
      ),
    );
  }
}

enum NotificationsScreenTab {
  current(
    title: 'Текущие',
  ),
  achievements(
    title: 'Архив',
  );

  const NotificationsScreenTab({
    required this.title,
  });

  final String title;
}
