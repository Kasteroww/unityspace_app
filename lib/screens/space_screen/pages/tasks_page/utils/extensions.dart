import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
