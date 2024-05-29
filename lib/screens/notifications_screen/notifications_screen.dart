import 'package:flutter/material.dart';
import 'package:unityspace/screens/app_navigation_drawer.dart';
import 'package:unityspace/screens/notifications_screen/pages/archived_notifications_page.dart';
import 'package:unityspace/screens/notifications_screen/pages/notifications_page.dart';
import 'package:unityspace/screens/notifications_screen/widgets/pop_up_notifications_button.dart';
import 'package:unityspace/screens/widgets/common/appbar.dart';
import 'package:unityspace/screens/widgets/tabs_list/tab_button.dart';
import 'package:unityspace/screens/widgets/tabs_list/tabs_list_row.dart';
import 'package:unityspace/store/notifications_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

enum NotificationErrors { none, loadingDataError }

class NotificationsScreenStore extends WStore {
  NotificationsScreenStore({
    NotificationsStore? notificationsStore,
  }) : notificationsStore = notificationsStore ?? NotificationsStore();

  NotificationsStore notificationsStore;
  NotificationsScreenTab selectedTab = NotificationsScreenTab.current;

  void selectTab(final NotificationsScreenTab tab) {
    setStore(() {
      selectedTab = tab;
    });
  }

  ///Удаляет все уведомления из архива
  void deleteAllNotifications() {
    notificationsStore.deleteAllNotifications();
  }

  ///Архивирует все уведомления
  void archiveAllNotifications() {
    notificationsStore.archiveAllNotifications();
  }

  ///Читает все уведомления
  void readAllNotifications() {
    notificationsStore.readAllNotifications();
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
        actions: const [PopUpNotificationsButton()],
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
                      NotificationsScreenTab.archived =>
                        localization.an_archive,
                      NotificationsScreenTab.current =>
                        localization.current_many
                    },
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
                  NotificationsScreenTab.archived =>
                    const ArchivedNotificationsPage(),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum NotificationsScreenTab { current, archived }
