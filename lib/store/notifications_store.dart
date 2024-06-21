import 'dart:async';

import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/service/notification_service.dart' as api;
import 'package:wstore/wstore.dart';

class Notifications with GStoreChangeObjectMixin {
  final Map<int, NotificationModel> _notificationsMap = {};

  Notifications();

  void add(NotificationModel notification) {
    _setNotification(notification);
    incrementObjectChangeCount();
  }

  void addAll(Iterable<NotificationModel> all) {
    if (all.isNotEmpty) {
      for (final notification in all) {
        _setNotification(notification);
      }
      incrementObjectChangeCount();
    }
  }

  void remove(int notificationId) {
    _removeNotification(notificationId);
    incrementObjectChangeCount();
  }

  void clear() {
    if (_notificationsMap.isNotEmpty) {
      _notificationsMap.clear();
      incrementObjectChangeCount();
    }
  }

  void _setNotification(NotificationModel notification) {
    _removeNotification(notification.id);
    _notificationsMap[notification.id] = notification;
  }

  void _removeNotification(int id) {
    _notificationsMap.remove(id);
  }

  NotificationModel? operator [](int id) => _notificationsMap[id];

  Iterable<NotificationModel> get iterable => _notificationsMap.values;

  List<NotificationModel> get list => _notificationsMap.values.toList();

  // Сортировка уведомлений от старого к новому
  List<NotificationModel> get sortedlist =>
      list..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  // Сортировка уведомлений от нового к старому
  List<NotificationModel> get reverseSortedlist => sortedlist.reversed.toList();

  int get length => _notificationsMap.length;
}

class NotificationsStore extends GStore {
  static NotificationsStore? _instance;

  factory NotificationsStore() => _instance ??= NotificationsStore._();

  NotificationsStore._();

  Notifications notifications = Notifications();

  Map<int, NotificationModel?> get notificationMap =>
      notifications._notificationsMap;

  /// Возвращает отформатированный список,
  /// из которого уже убраны отформатированные/вернувшиеся из форматирования
  /// уведомления
  void removeFromListLocally({required int notificationId}) {
    setStore(() {
      notifications.remove(notificationId);
    });
  }

  /// Возвращает отформатированный список,
  /// в котором обновлен статус прочитано/непрочитано у
  /// уведомления
  void changeReadStatusLocally({
    required int id,
    required bool status,
  }) {
    final notification = notifications[id];
    if (notification != null) {
      final updatedNotification = notification.copyWith(unread: status);
      setStore(() {
        notifications.add(updatedNotification);
      });
    }
  }

  /// Возвращает отформатированный список,
  /// из которого уже убраны отформатированные/вернувшиеся из форматирования
  /// уведомления
  void _deleteLocally({required int notificationId}) {
    setStore(() {
      notifications.remove(notificationId);
    });
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
    final loadedNotifications = notificationsData.notifications
        .map((notification) => NotificationModel.fromResponse(notification));
    setStore(() {
      notifications.addAll(loadedNotifications);
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
    for (final notification in archivedList) {
      removeFromListLocally(notificationId: notification.id);
    }
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
      changeReadStatusLocally(id: notification.id, status: !isUnread);
    }
  }

  /// Удаляет уведомления по id тех уведомлений,
  /// которые мы укажем
  Future<void> deleteNotifications(List<int> notificationIds) async {
    await api.deleteNotification(notificationIds: notificationIds);
    for (final id in notificationIds) {
      _deleteLocally(notificationId: id);
    }
  }

  /// Архивирует все уведомления
  Future<void> archiveAllNotifications() async {
    final archivedList = await api.archiveAllNotifications();
    for (final notification in archivedList) {
      removeFromListLocally(notificationId: notification.id);
    }
  }

  /// Читает все уведомления
  Future<void> readAllNotifications() async {
    final readList = await api.readAllNotifications();
    for (final notification in readList) {
      changeReadStatusLocally(id: notification.id, status: false);
    }
  }

  /// Удаляет все уведомления
  Future<void> deleteAllNotifications() async {
    await api.deleteAllNotifications();
    setStore(() {
      notifications.clear();
    });
  }

  /// Обновляет или создает уведомление из socket
  void updateNotificationsLocally(NotificationModel notification) {
    setStore(() {
      notifications.add(notification);
    });
  }

  /// Получает массив с 1 непрочитанный уведомлением
  /// чтобы отображать индикатор непрочитанных уведомлений
  Future<void> getFirstUnreadNotification() async {
    final loadedUnreadList = await api.getFirstUnreadNotification();
    if (loadedUnreadList.isNotEmpty) {
      final unreadList = loadedUnreadList
          .map((notification) => NotificationModel.fromResponse(notification));
      updateNotificationsLocally(unreadList.first);
    }
  }

  void empty() {
    setStore(() {
      notifications.clear();
    });
  }
}
