import 'package:collection/collection.dart';

import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/store/project_store.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/helpers.dart';

class NotificationHelper {
  UserStore userStore;
  NotificationHelper({
    required this.userStore,
  });

  /// Является ли пользователь владельцем организации
  static bool isUserOrganizationOwner({required User? user}) {
    return user?.id == UserStore().organization?.ownerId;
  }

  /// Поиск пользователя по id
  static OrganizationMember? findMemberById(
      List<OrganizationMember> members, int id) {
    return members.firstWhereOrNull((member) => member.id == id);
  }

  /// Группировка Списка уведомлений по дням
  ///
  /// Если уведомления произоши в один день, то они будут в одном списке
  List<List<NotificationModel>> groupNotificationsByDay(
      List<NotificationModel> notifications) {
    // Словарь для хранения уведомлений, сгруппированных по дате
    Map<String, List<NotificationModel>> groupedByDay = {};

    for (var notification in notifications) {
      // Преобразование даты в строку в формате yyyy-MM-dd
      String day =
          '${notification.createdAt.year}-${notification.createdAt.month}-${notification.createdAt.day}';

      // Если такого дня еще нет в словаре, добавляем
      if (!groupedByDay.containsKey(day)) {
        groupedByDay[day] = [];
      }

      // Добавляем уведомление в соответствующий список
      groupedByDay[day]!.add(notification);
    }

    // Возвращаем значения словаря как список списков
    return groupedByDay.values.toList();
  }

  List<OrganizationMember> getOrganizationMembers() {
    return userStore.organization?.members ?? [];
  }

  ///Сортировка пользователей по ParentData
  List<NotificationsGroup> groupNotificationsByObject(
    List<NotificationModel> notifications,
  ) {
    List<NotificationsGroup> groups = [];
    Map<String, NotificationsGroup> groupsMap = {};

    for (var notification in notifications) {
      String groupId = '';
      if (notification.parentType == 'TASK') {
        groupId = 'task-${notification.parentId}';
        if (groupsMap.containsKey(groupId)) {
          groupsMap[groupId]!.notifications.add(notification);
        } else {
          NotificationsGroup newGroup = NotificationsGroup(
            groupId: groupId,
            locations: notification.locations,
            createdAt: notification.createdAt,
            title: notification.taskName ?? '',
            type: NotificationType.task,
            notifications: [notification],
            showNotifications: true,
          );
          groups.add(newGroup);
          groupsMap[newGroup.groupId] = newGroup;
        }
      } else if (notification.parentType == 'REGLAMENT') {
        groupId = 'reglament-${notification.parentId}';
        if (groupsMap.containsKey(groupId)) {
          groupsMap[groupId]!.notifications.add(notification);
        } else {
          String reglamentName =
              //TODO: сделать ReglamentStore
              //reglamentsStore[notification.parentId]?.name ??
              notification.text;
          NotificationsGroup newGroup = NotificationsGroup(
            groupId: groupId,
            locations: notification.locations,
            createdAt: notification.createdAt,
            title: reglamentName,
            type: NotificationType.reglament,
            notifications: [notification],
            showNotifications: true,
          );
          groups.add(newGroup);
          groupsMap[newGroup.groupId] = newGroup;
        }
      } else if (notification.parentType == 'MEMBER') {
        groupId = 'space-${notification.locations[0].spaceId}';
        if (groupsMap.containsKey(groupId)) {
          groupsMap[groupId]!.notifications.add(notification);
        } else {
          final spacesMap = createMapById(SpacesStore().spaces);
          String spaceName =
              spacesMap[notification.locations[0].spaceId]?.name ??
                  notification.text;
          NotificationsGroup newGroup = NotificationsGroup(
            groupId: groupId,
            locations: [],
            createdAt: notification.createdAt,
            title: spaceName,
            type: NotificationType.space,
            notifications: [notification],
            showNotifications: true,
          );
          groups.add(newGroup);
          groupsMap[newGroup.groupId] = newGroup;
        }
      } else if (notification.parentType == 'ACHIEVEMENT') {
        groupId = 'achievement-${notification.id}';
        NotificationsGroup newGroup = NotificationsGroup(
          groupId: groupId,
          locations: [],
          createdAt: notification.createdAt,
          title: notification.text,
          type: NotificationType.achievement,
          notifications: [notification],
          showNotifications: false,
        );
        groups.add(newGroup);
        groupsMap[newGroup.groupId] = newGroup;
      } else {
        groupId = 'other-${notification.id}';
        NotificationsGroup newGroup = NotificationsGroup(
          groupId: groupId,
          locations: [],
          createdAt: notification.createdAt,
          title: notification.text,
          type: NotificationType.other,
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
      case NotificationType.achievement:
        return 'assets/icons/notifications/achievement.svg';
      case NotificationType.task:
        return 'assets/icons/notifications/task.svg';
      case NotificationType.space:
        return 'assets/icons/notifications/space.svg';
      case NotificationType.reglament:
        return 'assets/icons/notifications/reglament.svg';
      case NotificationType.other:
        return 'assets/icons/notifications/other.svg';
    }
  }

  List<LocationGroup> groupLocations(
    List<NotificationLocation> locations,
    SpacesStore spacesStore,
    ProjectStore projectStore,
  ) {
    if (locations.isEmpty) {
      return [
        LocationGroup(
            key: 'null',
            spaceId: null,
            spaceName: '',
            projectId: null,
            projectName: '')
      ];
    }

    final spacesStoreMap = createMapById(spacesStore.spaces);
    final projectsStoreMap = createMapById(projectStore.projects);

    return locations.map((location) {
      final space = spacesStoreMap[location.spaceId];
      final spaceName = space?.name ?? '';
      final project = location.projectId != null
          ? projectsStoreMap[location.projectId!]
          : null;
      final projectName = project?.name ?? '';

      return LocationGroup(
          key: '${location.spaceId}/${location.projectId}',
          spaceId: location.spaceId,
          spaceName: spaceName,
          projectId: location.projectId,
          projectName: projectName);
    }).toList();
  }
}
