import 'package:flutter/material.dart';

import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/screens/notifications_screen/utils/notification_helper.dart';
import 'package:unityspace/screens/widgets/user_avatar_widget.dart';
import 'package:unityspace/utils/date_time_converter.dart';
import 'package:unityspace/utils/localization_helper.dart';

/// Список дней уведомлений
class NotificationsList extends StatelessWidget {
  final List<NotificationModel> items;
  final void Function(List<NotificationModel> list) onArchiveButtonTap;
  final void Function(List<NotificationModel> list) onOptionalButtonTap;
  NotificationsList({
    super.key,
    required this.onArchiveButtonTap,
    required this.items,
    required this.onOptionalButtonTap,
  });

  final notificationHelper = NotificationHelper();
  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final dayLists = notificationHelper.groupNotificationsByDay(items);
    return ListView.builder(
        itemCount: dayLists.length,
        itemBuilder: (BuildContext context, int index) {
          final dayList = dayLists[index];
          final List<NotificationsGroup> typeList =
              notificationHelper.groupNotificationsByObject(
            dayList,
          );

          /// Виджет с содержимым одного дня уведомлений
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateTimeConverter.formatDateEEEEdMMMM(
                      locale: localization.localeName,
                      date: dayList.first.createdAt,
                      localizations: localization),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(102, 102, 102, 1)),
                ),
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: typeList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final type = typeList[index];
                      final notifications =
                          _sortNotificationsByDateTime(type.notifications);
                      return Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(8))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Разработка Spaces/Регламенты',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            Color.fromRGBO(102, 102, 102, 1))),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      type.title,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color:
                                              Color.fromRGBO(102, 102, 102, 1)),
                                    )),
                                    if (_checkIfUnreadAndNotInArchive(
                                        type.notifications))
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                    Text(
                                      DateTimeConverter.formatTimeHHmm(
                                          notifications.last.createdAt),
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color:
                                              Color.fromRGBO(102, 102, 102, 1)),
                                    ),
                                  ],
                                ),
                                ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: type.notifications.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final notification = notifications[index];
                                      final member =
                                          notificationHelper.findMemberById(
                                              notificationHelper
                                                  .getOrganizationMembers(),
                                              notification.initiatorId);
                                      return Container(
                                        decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                249, 249, 249, 1),
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: Row(
                                          children: [
                                            if (member != null)
                                              UserAvatar(
                                                member: member,
                                                width: 30,
                                                height: 30,
                                                fontSize: 10,
                                              ),
                                            Expanded(
                                              child: Text(
                                                notificationHelper
                                                    .notificationText(
                                                        notification),
                                                maxLines:
                                                    2, // Ограничиваем текст двумя строками
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    })
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ],
            ),
          );
        });
  }

  /// Проверяет, что уведомление не архивировано и есть непрочитанные сообщения
  bool _checkIfUnreadAndNotInArchive(List<NotificationModel> typeList) {
    return (typeList.any((element) => element.archived) == false &&
        typeList.any((element) => element.unread));
  }

  List<NotificationModel> _sortNotificationsByDateTime(
      List<NotificationModel> notifications) {
    List<NotificationModel> sortedNotifications = notifications;
    // сортировка уведомлений от новейшего к более старому
    sortedNotifications.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return sortedNotifications;
  }
}
