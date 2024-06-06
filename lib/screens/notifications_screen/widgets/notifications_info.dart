import 'package:flutter/material.dart';
import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/screens/notifications_screen/utils/notification_helper.dart';
import 'package:unityspace/screens/widgets/user_avatar_widget.dart';
import 'package:unityspace/utils/extensions/localization_extensions.dart';
import 'package:unityspace/utils/localization_helper.dart';

class NotificationInfo extends StatelessWidget {
  NotificationInfo({
    required this.notificationGroup,
    super.key,
  });

  final NotificationsGroup notificationGroup;

  final notificationHelper = NotificationHelper();
  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final notifications = notificationGroup.notifications;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notificationGroup.notifications.length,
      itemBuilder: (BuildContext context, int index) {
        final notification = notifications[index];
        final member = NotificationHelper.findMemberById(
          notification.initiatorId,
        );
        return DecoratedBox(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(249, 249, 249, 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              if (member != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: UserAvatarWidget(
                    id: member.id,
                    width: 20,
                    height: 20,
                    fontSize: 10,
                  ),
                ),
              Expanded(
                child: Text(
                  notification.notificationType.localize(
                    notification: notification,
                    localization: localization,
                  ),
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
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
