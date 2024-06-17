import 'dart:async';

import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/service/notification_service.dart' as api;
import 'package:unityspace/utils/helpers.dart';
import 'package:wstore/wstore.dart';

class NotificationsStore extends GStore {
  static NotificationsStore? _instance;

  factory NotificationsStore() => _instance ??= NotificationsStore._();

  NotificationsStore._();

  List<NotificationModel> notifications = [];

  Map<int, NotificationModel?> get notificationModelMap {
    return createMapById(notifications);
  }

  /// Возвращает отформатированный список,
  /// из которого уже убраны отформатированные/вернувшиеся из форматирования
  /// уведомления
  List<NotificationModel> _removeFromListLocally({
    required List<NotificationResponse> notificationsToRemove,
    required List<NotificationModel> notifications,
  }) {
    final List<int> notificationIdsToRemove =
        notificationsToRemove.map((e) => e.id).toList();
    return notifications
        .where(
          (notification) => !notificationIdsToRemove.contains(notification.id),
        )
        .toList();
  }

  /// Возвращает отформатированный список,
  /// в котором обновлен статус прочитано/непрочитано у
  /// уведомления
  void readLocally({
    required int id,
    required bool status,
  }) {
    final notificationList = notifications.map((notification) {
      if (notification.id == id) {
        return notification.copyWith(unread: status);
      } else {
        return notification;
      }
    }).toList();
    setStore(() {
      notifications = notificationList;
    });
  }

  /// Возвращает отформатированный список,
  /// из которого уже убраны отформатированные/вернувшиеся из форматирования
  /// уведомления
  List<NotificationModel> _deleteLocally({
    required List<NotificationModel> notifications,
    required List<int> notificationIdsToRemove,
  }) {
    return notifications
        .where(
          (notification) => !notificationIdsToRemove.contains(notification.id),
        )
        .toList();
  }

  Future<int> getNotificationsData({
    required int page,
    bool isArchived = false,
  }) async {
    // Получение данных уведомлений
    final PaginatedNotifications notificationsData = isArchived
        ? await api.getArchivedNotificationsOnPage(page: page)
        : await api.getNotificationsOnPage(page: page);

    // Преобразование ответа в список моделей NotificationModel
    final List<NotificationModel> newNotifications = notificationsData
        .notifications
        .map((notification) => NotificationModel.fromResponse(notification))
        .toList();
    notifications.addAll(newNotifications);
    final copyNotifications = [...notifications];

    // Обновление списка уведомлений в сторе
    setStore(() {
      notifications = copyNotifications;
    });

    // Возврат максимального количества страниц
    return notificationsData.maxPagesCount;
  }

  /// Меняет статус по Архивированию уведомлений по id тех уведомлений,
  /// которые мы укажем
  Future<void> changeArchiveStatusNotifications(
    List<int> notificationIds,
    bool isArchived,
  ) async {
    final archivedList = await api.archiveNotification(
      notificationIds: notificationIds,
      isArchived: !isArchived,
    );
    setStore(() {
      notifications = _removeFromListLocally(
        notificationsToRemove: archivedList,
        notifications: notifications,
      );
    });
  }

  /// Меняет статус по Прочтению уведомлений по id тех уведомлений,
  /// которые мы укажем
  Future<void> changeReadStatusNotification(
    List<int> notificationIds,
    bool isUnread,
  ) async {
    final readList = await api.readNotification(
      notificationIds: notificationIds,
      status: !isUnread,
    );
    for (final notification in readList) {
      readLocally(id: notification.id, status: !isUnread);
    }
  }

  /// Удаляет уведомления по id тех уведомлений,
  /// которые мы укажем
  Future<void> deleteNotifications(List<int> notificationIds) async {
    await api.deleteNotification(
      notificationIds: notificationIds,
    );
    setStore(() {
      notifications = _deleteLocally(
        notifications: notifications,
        notificationIdsToRemove: notificationIds,
      );
    });
  }

  /// Архивирует все уведомления
  Future<void> archiveAllNotifications() async {
    final archivedList = await api.archiveAllNotifications();
    setStore(() {
      notifications = _removeFromListLocally(
        notificationsToRemove: archivedList,
        notifications: notifications,
      );
    });
  }

  /// Читает все уведомления
  Future<void> readAllNotifications() async {
    final readList = await api.readAllNotifications();
    for (final notification in readList) {
      readLocally(id: notification.id, status: false);
    }
  }

  /// Удаляет все уведомления
  Future<void> deleteAllNotifications() async {
    await api.deleteAllNotifications();
    setStore(() {
      notifications = [];
    });
  }

  @override
  void clear() {
    super.clear();
    setStore(() {
      notifications = [];
    });
  }
}
