import 'package:flutter/material.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/tasks_page.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/utils/enums.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/utils/extensions.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/widgets/close_icon.dart';
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => store.setGroupingType(TaskGrouping.noGroup),
            child: const SmallCloseIcon(),
          ),
          const SizedBox(
            width: 4,
          ),
          Flexible(
            child: Text(
              value == TaskGrouping.noGroup
                  ? localization.do_not_group
                  : '${localization.group_tasks} ${value.localize(localization: localization).toLowerCase()}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
