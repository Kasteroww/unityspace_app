import 'package:flutter/material.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/widgets/divider.dart';
import 'package:unityspace/screens/widgets/paddings.dart';
import 'package:unityspace/utils/extensions/color_extension.dart';

class TasksList extends StatelessWidget {
  const TasksList({
    required this.tasks,
    super.key,
  });

  final List<SortedTask> tasks;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, taskIndex) {
        final SortedTask sortedTask = tasks[taskIndex];
        final Color? taskColor =
            (sortedTask.task.color != null && sortedTask.task.color!.isNotEmpty)
                ? HexColor.fromHex(sortedTask.task.color!)
                : null;
        return IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                flex: 8,
                child: PaddingLeft(
                  16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          sortedTask.task.name,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: (taskColor != null)
                              ? Icon(
                                  Icons.water_drop,
                                  color: taskColor,
                                  size: 20,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const DividerWithoutPadding(
                isHorisontal: false,
                color: ColorConstants.grey04,
              ),
              Expanded(
                flex: 2,
                child: PaddingLeft(
                  8,
                  child: PaddingBottom(
                    8,
                    child: Text(sortedTask.stageName),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
