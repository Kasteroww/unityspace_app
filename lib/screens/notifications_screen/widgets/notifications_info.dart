import 'package:flutter/material.dart';
import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/screens/notifications_screen/utils/notification_helper.dart';
import 'package:unityspace/screens/notifications_screen/utils/notifications_strings.dart';
import 'package:unityspace/screens/widgets/user_avatar_widget.dart';
import 'package:unityspace/store/user_store.dart';

class NotificationInfo extends StatelessWidget {
  NotificationInfo({
    super.key,
    required this.notificationGroup,
  });

  final NotificationsGroup notificationGroup;

  final notificationHelper = NotificationHelper(userStore: UserStore());
  final notificationStrings = NotificationsStrings(userStore: UserStore());
  @override
  Widget build(BuildContext context) {
    final notifications = notificationGroup.notifications;
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: notificationGroup.notifications.length,
        itemBuilder: (BuildContext context, int index) {
          final notification = notifications[index];
          final member = NotificationHelper.findMemberById(
              notificationHelper.getOrganizationMembers(),
              notification.initiatorId);
          return Container(
            decoration: BoxDecoration(
                color: const Color.fromRGBO(249, 249, 249, 1),
                borderRadius: BorderRadius.circular(4)),
            child: Row(
              children: [
                if (member != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: UserAvatar(
                      member: member,
                      width: 20,
                      height: 20,
                      fontSize: 10,
                    ),
                  ),
                Expanded(
                  child: Text(
                    notificationStrings.notificationText(notification),
                    maxLines: 2, // Ограничиваем текст двумя строками
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color.fromRGBO(
                          26,
                          26,
                          26,
                          1,
                        ),
                        height: 16.41 / 14,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
