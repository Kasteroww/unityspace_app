import 'package:flutter/material.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/tasks_page.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/utils/enums.dart';
import 'package:unityspace/utils/extensions/localization_extensions.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class PopUpTaskSortButton extends StatelessWidget {
  const PopUpTaskSortButton({
    required this.value,
    super.key,
  });

  final TaskSort value;

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
        overflow: TextOverflow.ellipsis,
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            onTap: () => store.setSortType(TaskSort.byDate),
            child: Text(
              TaskSort.byDate.localize(localization: localization),
            ),
          ),
          PopupMenuItem(
            onTap: () => store.setSortType(TaskSort.byStatus),
            child: Text(TaskSort.byStatus.localize(localization: localization)),
          ),
          PopupMenuItem(
            onTap: () => store.setSortType(TaskSort.byImportance),
            child: Text(
              TaskSort.byImportance.localize(localization: localization),
            ),
          ),
          PopupMenuItem(
            onTap: () => store.setSortType(TaskSort.defaultSort),
            child: Text(
              TaskSort.defaultSort.localize(localization: localization),
            ),
          ),
        ];
      },
    );
  }
}
