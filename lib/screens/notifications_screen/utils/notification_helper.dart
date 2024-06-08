import 'package:intl/intl.dart';

import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/store/projects_store.dart';
import 'package:unityspace/store/reglaments_store.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/user_store.dart';

class NotificationHelper {
  NotificationHelper();

  /// Является ли пользователь владельцем организации
  static bool isUserOrganizationOwner({required User? user}) {
    return user?.id == UserStore().organization?.ownerId;
  }

  /// Поиск пользователя по id
  static OrganizationMember? findMemberById(
    int id,
  ) {
    return UserStore().organizationMembersMap[id];
  }

  static List<OrganizationMember> get getOrganizationMembers {
    return UserStore().organization?.members ?? [];
  }

  /// Группировка Списка уведомлений по дням
  ///
  /// Если уведомления произошли в один день, то они будут в одном списке
  List<List<NotificationModel>> groupNotificationsByDay(
    List<NotificationModel> notifications,
  ) {
    // Словарь для хранения уведомлений, сгруппированных по дате
    final Map<String, List<NotificationModel>> groupedByDay = {};

    for (final notification in notifications) {
      // Преобразование даты в строку в формате yyyy-MM-dd
      final String day = DateFormat.yMd().format(notification.createdAt);

      // Если такого дня еще нет в словаре, добавляем
      if (!groupedByDay.containsKey(day)) {
        groupedByDay[day] = [];
      }

      // Добавляем уведомление в соответствующий список
      groupedByDay[day]?.add(notification);
    }

    // Возвращаем значения словаря как список списков
    return groupedByDay.values.toList();
  }

  ///Сортировка пользователей по ParentData
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
              ReglamentsStore().reglamentsMap[notification.parentId]?.name ??
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
              SpacesStore().spaces[notification.locations[0].spaceId]?.name ??
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

  String getPictureAssetByType(NotificationsGroup notificationGroup) {
    switch (notificationGroup.type) {
      case NotificationGroupType.achievement:
        return 'assets/icons/notifications/achievement.svg';
      case NotificationGroupType.task:
        return 'assets/icons/notifications/task.svg';
      case NotificationGroupType.space:
        return 'assets/icons/notifications/space.svg';
      case NotificationGroupType.reglament:
        return 'assets/icons/notifications/reglament.svg';
      case NotificationGroupType.other:
        return 'assets/icons/notifications/other.svg';
    }
  }

  List<LocationGroup> groupLocations(
    List<NotificationLocation> locations,
    SpacesStore spacesStore,
    ProjectsStore projectStore,
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
      final space = SpacesStore().spaces[location.spaceId];
      final spaceName = space?.name ?? '';
      final project = location.projectId != null
          ? ProjectsStore().projectsMap[location.projectId!]
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
}
