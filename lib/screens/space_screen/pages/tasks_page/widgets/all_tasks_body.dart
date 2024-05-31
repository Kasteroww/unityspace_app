import 'package:flutter/material.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/tasks_page.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/widgets/divider.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/widgets/popup_button.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/widgets/tasks_list.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/common/paddings.dart';
import 'package:unityspace/src/theme/theme.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class AllTasksBody extends StatelessWidget {
  const AllTasksBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: WStoreValueBuilder<TasksPageStore, TaskGrouping>(
                watch: (store) => store.groupingType,
                builder: (BuildContext context, value) {
                  return PopUpTaskGroupingButton(
                    value: value,
                  );
                },
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Flexible(
              child: AddDialogInputField(
                labelText: localization.find,
                onChanged: (value) {
                  context.wstore<TasksPageStore>().setSearchString(value);
                },
                onEditingComplete: () {
                  context.wstore<TasksPageStore>().searchTasks();
                },
              ),
            ),
          ],
        ),
        const PaddingTop(20),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                flex: 8,
                child: Text(
                  localization.task_name,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              const DividerWithoutPadding(
                isHorisontal: false,
                color: ColorConstants.grey04,
              ),
              Flexible(
                flex: 2,
                child: PaddingLeft(
                  8,
                  child: Text(
                    localization.column,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const DividerWithoutPadding(
          color: ColorConstants.grey04,
        ),
        Expanded(
          child: WStoreBuilder<TasksPageStore>(
            builder: (context, store) {
              return TasksList(
                tasksList: store.groupedTasks,
              );
            },
            watch: (store) => [store.groupingType],
          ),
        ),
      ],
    );
  }
}
