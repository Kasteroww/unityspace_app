import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/resources/l10n/app_localizations.dart';
import 'package:unityspace/screens/administration_screen/helpers/organization_role_enum.dart';
import 'package:unityspace/screens/notifications_screen/utils/notification_helper.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/utils/enums.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/logger_plugin.dart';

extension GroupLocalization on TaskGrouping {
  String localize({required AppLocalizations localization}) {
    switch (this) {
      case TaskGrouping.byProject:
        return localization.group_tasks_by_project;
      case TaskGrouping.byDate:
        return localization.group_tasks_by_date;
      case TaskGrouping.byUser:
        return localization.group_tasks_by_user;
      case TaskGrouping.noGroup:
        return localization.do_not_group;
    }
  }
}

/// extension с методом локализации
/// для каждого возможного значения TaskSort
/// возвращает его локализованное значение
extension SortLocalization on TaskSort {
  String localize({required AppLocalizations localization}) {
    switch (this) {
      case TaskSort.byDate:
        return localization.sort_tasks_by_date;
      case TaskSort.byStatus:
        return localization.sort_tasks_by_status;
      case TaskSort.byImportance:
        return localization.sort_tasks_by_importance;
      case TaskSort.defaultSort:
        return localization.default_tasks_sort;
    }
  }
}

/// extension с методом локализации
/// для каждого возможного значения TaskFilter
/// возвращает его локализованное значение
extension FilterLocalization on TaskFilter {
  String localize({required AppLocalizations localization}) {
    switch (this) {
      case TaskFilter.onlyActive:
        return localization.filter_active_tasks;
      case TaskFilter.onlyCompleted:
        return localization.filter_completed_tasks;
      case TaskFilter.allTasks:
        return localization.all_tasks;
    }
  }
}

/// extension с методом локализации
/// для каждого возможного значения NotificationTypeLocalization
/// возвращает его локализованное значение
extension NotificationTypeLocalization on NotificationType {
  String localize({
    required NotificationModel notification,
    required AppLocalizations localization,
  }) {
    try {
      switch (this) {
        case NotificationType.reglamentCreated:
          return localization.reglament_created;
        case NotificationType.reglamentRequiredSet:
          return localization.reglament_required_set;
        case NotificationType.reglamentRequiredUnset:
          return localization.reglament_required_unset;
        case NotificationType.reglamentUpdate:
          final message = localization.reglament_update;
          return notification.text.isNotEmpty
              ? '$message\r\n"${notification.text}"'
              : message;
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
                final String? name =
                    UserStore().organizationMembersByEmailMap[email]?.name ??
                        email;
                return '@$name';
            }
          });
          return '"$message"';
        case NotificationType.taskChangedResponsible:
          if (notification.text.startsWith('add responsible ')) {
            final int userId = int.parse(
              notification.text.substring('add responsible '.length),
            );
            final member = NotificationHelper.findMemberById(userId);
            return localization.task_added_responsible(member?.name ?? '');
          }
          if (notification.text.startsWith('change responsible ')) {
            final int userId = int.parse(
              notification.text.substring('change responsible '.length),
            );
            final member = NotificationHelper.findMemberById(userId);
            return localization.task_changed_responsible(member?.name ?? '');
          }
          return localization.task_changed_responsible(
            notification.text.substring(localization.new_responsible.length),
          );
        case NotificationType.taskDeletedResponsible:
          final userId = int.tryParse(notification.text);

          if (userId != null) {
            final member = NotificationHelper.findMemberById(userId);
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
        case NotificationType.taskDelegated:
          localization.task_delegated;
        case NotificationType.memberDeleted:
          localization.member_deleted;
        case NotificationType.memberDeletedForOwner:
          if (notification.parentId == notification.initiatorId) {
            return localization.member_deleted_themselves_for_owner;
          }
          final member = NotificationHelper.findMemberById(
            notification.parentId,
          );
          return localization.member_deleted_for_owner(member?.name ?? '');
        case NotificationType.memberAdded:
          if (!NotificationHelper.isUserOrganizationOwner(
            user: UserStore().user,
          )) {
            return localization.member_added;
          }
        case NotificationType.memberAcceptInvite:
          return localization.member_accept_invite;
        case NotificationType.memberAddedFromSpaceLink:
          return localization.member_added_from_space_link;
        case NotificationType.memberAddedForOwner:
          final member = NotificationHelper.findMemberById(
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
}

/// extension с методом локализации
/// для каждого возможного значения NotificationGroupType
/// возвращает его локализованное значение
extension NotificationGroupLocalization on NotificationGroupType {
  String localize({required AppLocalizations localization}) {
    switch (this) {
      case NotificationGroupType.task:
        return localization.tasks;
      case NotificationGroupType.reglament:
        return localization.reglaments;
      case NotificationGroupType.space:
        return localization.spaces;
      case NotificationGroupType.achievement:
        return localization.achievements;
      case NotificationGroupType.other:
        return localization.other;
    }
  }
}

extension OrganizationRoleEnumExt on OrganizationRoleEnum {
  String localize({required AppLocalizations localization}) {
    switch (this) {
      case OrganizationRoleEnum.owner:
        return localization.owner;
      case OrganizationRoleEnum.admin:
        return localization.admin;
      case OrganizationRoleEnum.worker:
        return localization.worker;
    }
  }
}

/// extension с методом локализации
/// для каждого возможного значения TaskImportance
/// возвращает его локализованное значение
extension ImportanceLocalization on TaskImportance {
  String localize({required AppLocalizations localization}) {
    switch (this) {
      case TaskImportance.high:
        return localization.high;
      case TaskImportance.normal:
        return localization.normal;
      case TaskImportance.low:
        return localization.low;
    }
  }
}
