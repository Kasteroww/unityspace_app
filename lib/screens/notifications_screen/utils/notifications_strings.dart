import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/screens/notifications_screen/utils/notification_helper.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/logger_plugin.dart';

/// Класс для работы со строками уведомлений
///
/// Конвертация строк/ Локализация/ все что связано в тем, как можно поменять строки
/// Уведомлений содержится тут
///
class NotificationsStrings {
  UserStore userStore;
  NotificationsStrings({
    required this.userStore,
  });

  static String groupName(
    NotificationsGroup notificationGroup,
    AppLocalizations localization,
  ) {
    switch (notificationGroup.type) {
      case NotificationType.task:
        return localization.tasks;
      case NotificationType.reglament:
        return localization.reglaments;
      case NotificationType.space:
        return localization.spaces;
      case NotificationType.achievement:
        return localization.achievements;
      case NotificationType.other:
        return localization.other;
    }
  }

  String notificationText(NotificationModel notification) {
    final List<OrganizationMember> organizationMembers =
        userStore.organization?.members ?? [];
    try {
      if (notification.notificationType == 'REGLAMENT_CREATED') {
        return 'Создал(а) регламент';
      }
      if (notification.notificationType == 'REGLAMENT_REQUIRED_SET') {
        return 'Отметил(а) регламент как обязательный';
      }
      if (notification.notificationType == 'REGLAMENT_REQUIRED_UNSET') {
        return 'Отметил(а) регламент как необязательный';
      }
      if (notification.notificationType == 'REGLAMENT_UPDATE') {
        const message =
            'Обновил(а) регламент и сбросил(а) участников, прошедших регламент';
        return notification.text.isNotEmpty
            ? '$message\r\n"${notification.text}"'
            : message;
      }
      if (notification.notificationType == 'MESSAGE') {
        // убираем кавычки в начале и в конце
        // заменяем упоминания на осмысленный текст
        final String message = notification.text
            .substring(1, notification.text.length - 1)
            .replaceAllMapped(RegExp(r'(?:^@|(?<=\s)@)\S+\w'), (match) {
          switch (match.group(0)) {
            case '@all':
              return '@Всем';
            case '@performer':
              return '@Исполнитель';
            default:
              final String? email = match.group(0)?.substring(1);
              final membersMap =
                  userStore.organizationMembersByEmailMap(userStore);
              final String? name = membersMap[email]?.name ?? email;
              return '@$name';
          }
        });
        return '"$message"';
      }
      if (notification.notificationType == 'TASK_CHANGED_RESPONSIBLE') {
        if (notification.text.startsWith('add responsible ')) {
          final int userId =
              int.parse(notification.text.substring('add responsible '.length));
          final member =
              NotificationHelper.findMemberById(organizationMembers, userId);
          return 'Установил(а) исполнителя: ${member?.name ?? ''}';
        }
        if (notification.text.startsWith('change responsible ')) {
          final int userId = int.parse(
            notification.text.substring('change responsible '.length),
          );
          final member =
              NotificationHelper.findMemberById(organizationMembers, userId);
          return 'Сменил(а) исполнителя на: ${member?.name ?? ''}';
        }
        return 'Сменил(а) исполнителя на: ${notification.text.substring('Новый исполнитель '.length)}';
      }
      if (notification.notificationType == 'TASK_DELETED_RESPONSIBLE') {
        final userId = int.tryParse(notification.text);

        if (userId != null) {
          final member =
              NotificationHelper.findMemberById(organizationMembers, userId);
          return 'Снял(а) исполнителя: ${member?.name ?? ''}';
        }
        return 'Снял(а) исполнителя';
      }
      if (notification.notificationType == 'TASK_COMPLETED') {
        return 'Завершил(а) задачу';
      }
      if (notification.notificationType == 'TASK_REJECTED') {
        return 'Отменил(а) задачу';
      }
      if (notification.notificationType == 'TASK_IN_WORK') {
        return 'Вернул(а) задачу в работу';
      }
      if (notification.notificationType == 'TASK_PROJECT_CHANGED') {
        return 'Перенес(ла) задачу в проект: ${notification.text}';
      }
      if (notification.notificationType == 'TASK_DELEGATED') {
        return 'Поручил(а) Вам задачу';
      }
      if (notification.notificationType == 'MEMBER_DELETED') {
        return 'Убрал(а) Вам доступ к пространству';
      }

      if (notification.notificationType == 'MEMBER_DELETED_FOR_OWNER') {
        if (notification.parentId == notification.initiatorId) {
          return 'Вышел(а) из пространства';
        }
        final member = NotificationHelper.findMemberById(
          organizationMembers,
          notification.parentId,
        );
        final memberName = member?.name;

        return 'Исключил(а) пользователя \'$memberName\' из пространства';
      }

      if (notification.notificationType == 'MEMBER_ADDED' &&
          !NotificationHelper.isUserOrganizationOwner(user: userStore.user)) {
        return 'Добавил(а) Вас в пространство';
      }

      if (notification.notificationType == 'MEMBER_ACCEPT_INVITE') {
        return 'Принял(а) приглашение в пространство';
      }

      if (notification.notificationType == 'MEMBER_ADDED_FROM_SPACE_LINK') {
        return 'Вступил(а) в пространство по ссылке';
      }

      if (notification.notificationType == 'MEMBER_ADDED_FOR_OWNER') {
        final member = NotificationHelper.findMemberById(
          organizationMembers,
          notification.parentId,
        );
        final memberName = member?.name;
        return 'Добавил(а) пользователя \'$memberName\' в пространство';
      }

      if (notification.notificationType == 'TASK_DELETED') {
        return 'Удалил(а) задачу';
      }

      if (notification.notificationType == 'TASK_SEND_TO_ARCHIVE') {
        return 'Отправил(а) задачу в архив';
      }

      if (notification.notificationType == 'TASK_MEMBER_REMOVED') {
        return 'Удалил(а) Вас из участников задачи';
      }

      return notification.text;
    } catch (e, stack) {
      logger.d(e, stackTrace: stack);
      throw Exception(e);
    }
  }
}
