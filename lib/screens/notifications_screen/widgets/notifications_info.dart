import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/notifications_screen/notifications_screen.dart';
import 'package:unityspace/screens/notifications_screen/utils/notification_helper.dart';
import 'package:unityspace/screens/widgets/user_avatar_widget.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/date_time_converter.dart';
import 'package:unityspace/utils/extensions/localization_extensions.dart';
import 'package:unityspace/utils/helpers.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';

class NotificationInfo extends StatelessWidget {
  NotificationInfo({
    required this.notificationGroup,
    required this.store,
    this.isShowCreatedAt = false,
    super.key,
  });

  final bool isShowCreatedAt;
  final NotificationsGroup notificationGroup;
  final NotificationsScreenStore store;

  final notificationHelper = NotificationHelper();

  String getNotificationTypeLocalization({
    required BuildContext context,
    required NotificationModel notification,
  }) {
    final localization = LocalizationHelper.getLocalizations(context);
    final store = this.store;
    try {
      switch (notification.notificationType) {
        case NotificationType.reglamentCreated:
          return localization.reglament_created;
        case NotificationType.reglamentRequiredSet:
          return localization.reglament_required_set;
        case NotificationType.reglamentDeleted:
          return localization.reglament_deleted;
        case NotificationType.reglamentArchived:
          return localization.reglament_archived;
        case NotificationType.reglamentMoved:
          return localization.reglament_moved(
            notification.text.isNotEmpty ? notification.text : '???',
          );
        case NotificationType.reglamentRequiredUnset:
          return localization.reglament_required_unset;
        case NotificationType.reglamentUpdate:
          final message = localization.reglament_update;
          return notification.text.isNotEmpty
              ? '$message\r\n"${notification.text}"'
              : message;
        case NotificationType.newAchievement:
          return notification.text.isNotEmpty ? notification.text : '???';
        case NotificationType.message:
          // убираем кавычки в начале и в конце
          // заменяем упоминания на осмысленный текст
          final String message = notification.text
              .substring(1, notification.text.length - 1)
              .replaceAllMapped(RegExp(r'(?:^@|(?<=\s)@)\S+\w'), (match) {
            switch (match.group(0)) {
              case '@all':
                return localization.ping_to_all;
              case '@performer':
                return localization.ping_to_performer;

              default:
                final String? email = match.group(0)?.substring(1);
                if (email == null) return '@???';
                final String name = store.userNameByEmail(email);
                return '@$name';
            }
          });
          return '"$message"'.trim();
        case NotificationType.taskChangedResponsible:
          if (notification.text.startsWith('add responsible ')) {
            final int userId = int.parse(
              notification.text.substring('add responsible '.length),
            );
            final member = store.getMemberById(userId);
            return localization.task_added_responsible(member?.name ?? '');
          }
          if (notification.text.startsWith('change responsible ')) {
            final int userId = int.parse(
              notification.text.substring('change responsible '.length),
            );
            final member = store.getMemberById(userId);
            return localization.task_changed_responsible(member?.name ?? '');
          }
          return localization.task_changed_responsible(
            notification.text.substring(localization.new_responsible.length),
          );
        case NotificationType.taskDeletedResponsible:
          final userId = int.tryParse(notification.text);

          if (userId != null) {
            final member = store.getMemberById(userId);
            return localization.task_deleted_responsible(member?.name ?? '');
          }
          return localization.task_deleted_unknown_responsible;
        case NotificationType.taskCompleted:
          return localization.task_completed;
        case NotificationType.taskRejected:
          return localization.task_rejected;
        case NotificationType.taskInWork:
          return localization.task_in_work;
        case NotificationType.taskProjectChanged:
          return localization.task_project_chagned(notification.text);
        case NotificationType.taskBlockReason:
          if (notification.text.isEmpty) {
            return localization.task_block_reason_unset;
          }
          return localization.task_block_reason_set(notification.text);
        case NotificationType.taskImportance:
          if (notification.text.isNotEmpty) {
            try {
              final TaskImportance importance = getEnumValue(
                int.parse(notification.text),
                enumValues: TaskImportance.values,
              );
              return localization.task_importance(
                importance.localize(localization: localization),
              );
            } catch (e, stack) {
              logger.e('''
                  Error getting NotificationType localization: 
                  notificaiton.text, that is meant to represent a TaskImportance value 
                  is not convertable to int. \n Error: $e, \n Stack: $stack''');
            }
          }
          return localization.task_importance(notification.text);

        case NotificationType.taskDelegated:
          localization.task_delegated;
        case NotificationType.taskStageChanged:
          return localization.task_stage_chagned(
            notification.text.isNotEmpty ? notification.text : '???',
          );
        case NotificationType.memberDeleted:
          localization.member_deleted;
        case NotificationType.memberDeletedForOwner:
          if (notification.parentId == notification.initiatorId) {
            return localization.member_deleted_themselves_for_owner;
          }
          final member = store.getMemberById(
            notification.parentId,
          );
          return localization.member_deleted_for_owner(member?.name ?? '');
        case NotificationType.memberAdded:
          if (!store.isUserOrganizationOwner(
            user: UserStore().user,
          )) {
            return localization.member_added;
          }
        case NotificationType.memberAcceptInvite:
          return localization.member_accept_invite;
        case NotificationType.memberAddedFromSpaceLink:
          return localization.member_added_from_space_link;
        case NotificationType.memberAddedForOwner:
          final member = store.getMemberById(
            notification.parentId,
          );
          return localization.member_added_for_owner(member?.name ?? '');
        case NotificationType.taskDeleted:
          return localization.task_deleted;
        case NotificationType.taskSentToArchive:
          return localization.task_sent_to_archive;
        case NotificationType.taskMemberRemoved:
          return localization.task_member_removed;
      }
      return notification.text;
    } catch (e, stack) {
      logger.d(e, stackTrace: stack);
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = notificationGroup.notifications;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notificationGroup.notifications.length,
      itemBuilder: (BuildContext context, int index) {
        final notification = notifications[index];
        final member = store.getMemberById(notification.initiatorId);
        return DecoratedBox(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(249, 249, 249, 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    getNotificationTypeLocalization(
                      notification: notification,
                      context: context,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
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
              ),
              // время создания уведомления
              if (isShowCreatedAt)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    DateTimeConverter.formatTimeHHmm(notification.createdAt),
                    style: const TextStyle(
                      color: ColorConstants.grey04,
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      height: 11.72 / 10,
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
