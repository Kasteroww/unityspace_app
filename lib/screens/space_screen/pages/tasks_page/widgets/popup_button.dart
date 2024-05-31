import 'package:flutter/material.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/tasks_page.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class PopUpTaskGroupingButton extends StatelessWidget {
  const PopUpTaskGroupingButton({
    required this.value,
    super.key,
  });

  final TaskGrouping value;

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
        value == TaskGrouping.noGroup
            ? localization.do_not_group
            : '${localization.group_tasks} ${value.localize(localization: localization).toLowerCase()}',
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            onTap: () => store.setGroupingType(TaskGrouping.byProject),
            child: Text(
              TaskGrouping.byProject.localize(localization: localization),
            ),
          ),
          PopupMenuItem(
            onTap: () => store.setGroupingType(TaskGrouping.byDate),
            child:
                Text(TaskGrouping.byDate.localize(localization: localization)),
          ),
          PopupMenuItem(
            onTap: () => store.setGroupingType(TaskGrouping.byUser),
            child:
                Text(TaskGrouping.byUser.localize(localization: localization)),
          ),
          PopupMenuItem(
            onTap: () => store.setGroupingType(TaskGrouping.noGroup),
            child:
                Text(TaskGrouping.noGroup.localize(localization: localization)),
          ),
        ];
      },
    );
  }
}
