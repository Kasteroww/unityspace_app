import 'package:flutter/material.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/tasks_page.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/utils/enums.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/widgets/close_icon.dart';
import 'package:unityspace/screens/widgets/pop_up_button.dart/default_pop_up_button.dart';
import 'package:unityspace/utils/extensions/localization_extensions.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class PopupTaskFilterButton extends StatelessWidget {
  const PopupTaskFilterButton({required this.value, super.key});

  final TaskFilter value;

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final store = context.wstore<TasksPageStore>();
    return DefaultPopUpButton(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => store.setFilterType(TaskFilter.allTasks),
            child: const SmallCloseIcon(),
          ),
          const SizedBox(
            width: 4,
          ),
          Flexible(
            child: Text(
              value.localize(localization: localization),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
