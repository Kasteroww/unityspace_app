import 'package:flutter/material.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/tasks_page.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/utils/enums.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/utils/extensions.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class PopupTaskFilterButton extends StatelessWidget {
  const PopupTaskFilterButton({required this.value, super.key});

  final TaskFilter value;

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final store = context.wstore<TasksPageStore>();
    return PopupMenuButton<String>(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      child: Text(
        value.localize(localization: localization),
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            onTap: () => store.setFilterType(TaskFilter.onlyActive),
            child: Text(
              TaskFilter.onlyActive.localize(localization: localization),
            ),
          ),
          PopupMenuItem(
            onTap: () => store.setFilterType(TaskFilter.onlyCompleted),
            child: Text(
              TaskFilter.onlyCompleted.localize(localization: localization),
            ),
          ),
          PopupMenuItem(
            onTap: () => store.setFilterType(TaskFilter.allTasks),
            child: Text(
              TaskFilter.allTasks.localize(localization: localization),
            ),
          ),
        ];
      },
    );
  }
}
