import 'package:intl/intl.dart';

import 'package:unityspace/models/notification_models.dart';

class NotificationHelper {
  NotificationHelper();

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
}
