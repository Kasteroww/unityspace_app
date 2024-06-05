import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/resources/l10n/app_localizations.dart';
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
      case NotificationCategory.task:
        return localization.tasks;
      case NotificationCategory.reglament:
        return localization.reglaments;
      case NotificationCategory.space:
        return localization.spaces;
      case NotificationCategory.achievement:
        return localization.achievements;
      case NotificationCategory.other:
        return localization.other;
    }
  }

  String notificationText(NotificationModel notification) {
    final List<OrganizationMember> organizationMembers =
        userStore.organization?.members ?? [];
    try {
      if (notification.notificationType == NotificationType.reglamentCreated) {
        return 'Создал(а) регламент';
      }
      if (notification.notificationType ==
          NotificationType.reglamentRequiredSet) {
        return 'Отметил(а) регламент как обязательный';
      }
      if (notification.notificationType ==
          NotificationType.reglamentRequiredUnset) {
        return 'Отметил(а) регламент как необязательный';
      }
      if (notification.notificationType == NotificationType.reglamentUpdate) {
        const message =
            'Обновил(а) регламент и сбросил(а) участников, прошедших регламент';
        return notification.text.isNotEmpty
            ? '$message\r\n"${notification.text}"'
            : message;
      }
      if (notification.notificationType == NotificationType.message) {
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
      if (notification.notificationType ==
          NotificationType.taskChangedResponsible) {
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
      if (notification.notificationType ==
          NotificationType.taskDeletedResponsible) {
        final userId = int.tryParse(notification.text);

        if (userId != null) {
          final member =
              NotificationHelper.findMemberById(organizationMembers, userId);
          return 'Снял(а) исполнителя: ${member?.name ?? ''}';
        }
        return 'Снял(а) исполнителя';
      }
      if (notification.notificationType == NotificationType.taskCompleted) {
        return 'Завершил(а) задачу';
      }
      if (notification.notificationType == NotificationType.taskRejected) {
        return 'Отменил(а) задачу';
      }
      if (notification.notificationType == NotificationType.taskInWork) {
        return 'Вернул(а) задачу в работу';
      }
      if (notification.notificationType ==
          NotificationType.taskProjectChanged) {
        return 'Перенес(ла) задачу в проект: ${notification.text}';
      }
      if (notification.notificationType == NotificationType.taskDelegated) {
        return 'Поручил(а) Вам задачу';
      }
      if (notification.notificationType == NotificationType.memberDeleted) {
        return 'Убрал(а) Вам доступ к пространству';
      }

      if (notification.notificationType ==
          NotificationType.memberDeletedForOwner) {
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

      if (notification.notificationType == NotificationType.memberAdded &&
          !NotificationHelper.isUserOrganizationOwner(user: userStore.user)) {
        return 'Добавил(а) Вас в пространство';
      }

      if (notification.notificationType ==
          NotificationType.memberAcceptInvite) {
        return 'Принял(а) приглашение в пространство';
      }

      if (notification.notificationType ==
          NotificationType.memberAddedFromSpaceLink) {
        return 'Вступил(а) в пространство по ссылке';
      }

      if (notification.notificationType ==
          NotificationType.memberAddedForOwner) {
        final member = NotificationHelper.findMemberById(
          organizationMembers,
          notification.parentId,
        );
        final memberName = member?.name;
        return 'Добавил(а) пользователя \'$memberName\' в пространство';
      }

      if (notification.notificationType == NotificationType.taskDeleted) {
        return 'Удалил(а) задачу';
      }

      if (notification.notificationType == NotificationType.taskSentToArchive) {
        return 'Отправил(а) задачу в архив';
      }

      if (notification.notificationType == NotificationType.taskMemberRemoved) {
        return 'Удалил(а) Вас из участников задачи';
      }

      return notification.text;
    } catch (e, stack) {
      logger.d(e, stackTrace: stack);
      throw Exception(e);
    }
  }
}
