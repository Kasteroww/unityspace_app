import 'package:flutter/material.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/widgets/divider.dart';
import 'package:unityspace/screens/widgets/common/paddings.dart';

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
        return IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                flex: 8,
                child: PaddingLeft(
                  16,
                  child: Text(
                    sortedTask.task.name,
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
