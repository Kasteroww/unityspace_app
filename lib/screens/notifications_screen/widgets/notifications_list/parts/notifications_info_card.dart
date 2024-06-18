import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/screens/notifications_screen/utils/notification_helper.dart';
import 'package:unityspace/screens/notifications_screen/widgets/notifications_info.dart';
import 'package:unityspace/screens/notifications_screen/widgets/notifications_list/parts/locations.dart';
import 'package:unityspace/utils/date_time_converter.dart';
import 'package:unityspace/utils/helpers.dart';

class NotificationsInfoCard extends StatelessWidget {
  NotificationsInfoCard({
    required this.notificationsGroup,
    super.key,
  });

  final NotificationsGroup notificationsGroup;

  final notificationHelper = NotificationHelper();

  @override
  Widget build(BuildContext context) {
    final notifications =
        _sortNotificationsByDateTime(notificationsGroup.notifications);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ColoredBox(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Locations(
                      notificationsGroup: notificationsGroup,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      DateTimeConverter.formatTimeHHmm(
                        notifications.last.createdAt,
                      ),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(102, 102, 102, 1),
                      ),
                    ),
                  ),
                  if (_checkIfUnreadAndNotInArchive(
                    notificationsGroup.notifications,
                  ))
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(
                          239,
                          68,
                          68,
                          1,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  SizedBox(
                    height: 14,
                    width: 14,
                    child: SvgPicture.asset(
                      notificationHelper
                          .getPictureAssetByType(notificationsGroup),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Text(
                      notificationsGroup.title.removeLineBreaksAndTabs(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(102, 102, 102, 1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              NotificationInfo(notificationGroup: notificationsGroup),
            ],
          ),
        ),
      ),
    );
  }

  /// Проверяет, что уведомление не архивировано и есть непрочитанные сообщения
  bool _checkIfUnreadAndNotInArchive(List<NotificationModel> typeList) {
    return typeList.any((element) => element.archived) == false &&
        typeList.any((element) => element.unread);
  }

  List<NotificationModel> _sortNotificationsByDateTime(
    List<NotificationModel> notifications,
  ) {
    final List<NotificationModel> sortedNotifications = notifications;
    // сортировка уведомлений в списке от старого к более новому
    sortedNotifications.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return sortedNotifications;
  }
}
