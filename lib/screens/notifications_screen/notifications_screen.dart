import 'package:flutter/material.dart';
import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/models/reglament_models.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/screens/app_navigation_drawer.dart';
import 'package:unityspace/screens/notifications_screen/pages/archived_notifications_page.dart';
import 'package:unityspace/screens/notifications_screen/pages/notifications_page.dart';
import 'package:unityspace/screens/notifications_screen/widgets/pop_up_notifications_button.dart';
import 'package:unityspace/screens/widgets/appbar.dart';
import 'package:unityspace/screens/widgets/tabs_list/tab_button.dart';
import 'package:unityspace/screens/widgets/tabs_list/tabs_list_row.dart';
import 'package:unityspace/store/notifications_store.dart';
import 'package:unityspace/store/projects_store.dart';
import 'package:unityspace/store/reglaments_store.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/user_store.dart';
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

  OrganizationMembers get organizationMembers => computedFromStore(
        store: UserStore(),
        getValue: (store) {
          return store.organizationMembers;
        },
        keyName: 'organizationMembers',
      );

  Map<int, Reglament> get reglamentsMap => computedFromStore(
        store: ReglamentsStore(),
        getValue: (store) => store.reglamentsMap,
        keyName: 'reglamentsMap',
      );

  Spaces get spaces => computedFromStore(
        store: SpacesStore(),
        getValue: (store) => store.spaces,
        keyName: 'spaces',
      );

  Space? getSpaceById(int spaceId) => computedFromStore(
        store: SpacesStore(),
        getValue: (store) => store.spaces[spaceId],
        keyName: 'getSpaceById',
      );

  Project? getProjectById(int projectId) => computedFromStore(
        store: ProjectsStore(),
        getValue: (store) => store.projectsMap[projectId],
        keyName: 'getProjectById',
      );

  /// Является ли пользователь владельцем организации
  bool isUserOrganizationOwner({required User? user}) => computedFromStore(
        store: UserStore(),
        getValue: (store) => user?.id == store.organizationOwnerId,
        keyName: 'isUserOrganizationOwner',
      );

  String userNameByEmail(String email) =>
      organizationMembers.getByEmail(email)?.name ?? email;

  /// Поиск пользователя по id
  OrganizationMember? getMemberById(int id) => organizationMembers[id];

  String? getSpaceNameById(int spaceId) => spaces[spaceId]?.name;

  String? reglamentNameByNotificationParentId(int parentId) =>
      reglamentsMap[parentId]?.name;

  List<LocationGroup> groupLocations(
    List<NotificationLocation> locations,
  ) {
    if (locations.isEmpty) {
      return [
        LocationGroup(
          key: 'null',
          spaceName: '',
          projectName: '',
        ),
      ];
    }

    return locations.map((location) {
      final space = getSpaceById(location.spaceId);
      final spaceName = space?.name ?? '';
      final project = location.projectId != null
          ? getProjectById(location.projectId!)
          : null;
      final projectName = project?.name ?? '';

      return LocationGroup(
        key: '${location.spaceId}/${location.projectId}',
        spaceId: location.spaceId,
        spaceName: spaceName,
        projectId: location.projectId,
        projectName: projectName,
      );
    }).toList();
  }

  ///Группировка уведомлений по ParentData
  List<NotificationsGroup> groupNotificationsByObject(
    List<NotificationModel> notifications,
  ) {
    final List<NotificationsGroup> groups = [];
    final Map<String, NotificationsGroup> groupsMap = {};

    for (final notification in notifications) {
      String groupId = '';
      if (notification.parentType == NotificationParentType.task) {
        groupId = 'task-${notification.parentId}';
        if (groupsMap.containsKey(groupId)) {
          groupsMap[groupId]?.notifications.add(notification);
        } else {
          final NotificationsGroup newGroup = NotificationsGroup(
            groupId: groupId,
            locations: notification.locations,
            createdAt: notification.createdAt,
            title: notification.taskName ?? '',
            type: NotificationGroupType.task,
            notifications: [notification],
            showNotifications: true,
          );
          groups.add(newGroup);
          groupsMap[newGroup.groupId] = newGroup;
        }
      } else if (notification.parentType == NotificationParentType.reglament) {
        groupId = 'reglament-${notification.parentId}';
        if (groupsMap.containsKey(groupId)) {
          groupsMap[groupId]?.notifications.add(notification);
        } else {
          final String reglamentName =
              reglamentNameByNotificationParentId(notification.parentId) ??
                  notification.text;
          final NotificationsGroup newGroup = NotificationsGroup(
            groupId: groupId,
            locations: notification.locations,
            createdAt: notification.createdAt,
            title: reglamentName,
            type: NotificationGroupType.reglament,
            notifications: [notification],
            showNotifications: true,
          );
          groups.add(newGroup);
          groupsMap[newGroup.groupId] = newGroup;
        }
      } else if (notification.parentType == NotificationParentType.member) {
        groupId = 'space-${notification.locations[0].spaceId}';
        if (groupsMap.containsKey(groupId)) {
          groupsMap[groupId]?.notifications.add(notification);
        } else {
          final String spaceName =
              getSpaceNameById(notification.locations[0].spaceId) ??
                  notification.text;
          final NotificationsGroup newGroup = NotificationsGroup(
            groupId: groupId,
            locations: [],
            createdAt: notification.createdAt,
            title: spaceName,
            type: NotificationGroupType.space,
            notifications: [notification],
            showNotifications: true,
          );
          groups.add(newGroup);
          groupsMap[newGroup.groupId] = newGroup;
        }
      } else if (notification.parentType ==
          NotificationParentType.achievement) {
        groupId = 'achievement-${notification.id}';
        final NotificationsGroup newGroup = NotificationsGroup(
          groupId: groupId,
          locations: [],
          createdAt: notification.createdAt,
          title: notification.text,
          type: NotificationGroupType.achievement,
          notifications: [notification],
          showNotifications: false,
        );
        groups.add(newGroup);
        groupsMap[newGroup.groupId] = newGroup;
      } else {
        groupId = 'other-${notification.id}';
        final NotificationsGroup newGroup = NotificationsGroup(
          groupId: groupId,
          locations: [],
          createdAt: notification.createdAt,
          title: notification.text,
          type: NotificationGroupType.other,
          notifications: [notification],
          showNotifications: false,
        );
        groups.add(newGroup);
        groupsMap[newGroup.groupId] = newGroup;
      }
    }
    return groups;
  }

  ///Удаляет все уведомления из архива
  void deleteAllNotifications() {
    notificationsStore.deleteAllNotifications();
  }

  ///Архивирует все уведомления
  void archiveAllNotifications() {
    notificationsStore.archiveAllNotifications();
    readAllNotifications();
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
          const SizedBox(height: 16),
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
          const SizedBox(height: 24),
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
