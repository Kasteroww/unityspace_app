import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/resources/l10n/app_localizations.dart';
import 'package:unityspace/screens/administration_screen/helpers/organization_role_enum.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/utils/enums.dart';

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
/// для каждого возможного значения NotificationGroupType
/// возвращает его локализованное значение
extension NotificationGroupLocalization on NotificationGroupType {
  String localize({required AppLocalizations localization}) {
    switch (this) {
      case NotificationGroupType.task:
        return localization.tasks;
      case NotificationGroupType.reglament:
        return localization.reglament;
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
      case OrganizationRoleEnum.invite:
        return localization.invite;
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
