import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/widgets/divider.dart';
import 'package:unityspace/screens/widgets/paddings.dart';
import 'package:unityspace/utils/extensions/color_extension.dart';
import 'package:unityspace/utils/localization_helper.dart';

class TasksList extends StatelessWidget {
  const TasksList({
    required this.tasks,
    super.key,
  });

  final List<SortedTask> tasks;

  Color? getImportanceColor(TaskImportance importance) {
    switch (importance) {
      case TaskImportance.high:
        return Colors.red;
      case TaskImportance.low:
        return Colors.black;
      default:
        return null;
    }
  }

  String getFormattedEndDate({
    required DateTime endDate,
    required String locale,
  }) {
    return DateFormat('d MMM', locale).format(endDate);
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
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
        final taskImportance = sortedTask.task.importance;
        final taskEndDate = sortedTask.task.dateEnd;

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
                      const SizedBox(
                        width: 24,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (taskEndDate != null)
                            PaddingRight(
                              8,
                              child: Text(
                                getFormattedEndDate(
                                  endDate: taskEndDate,
                                  locale: localization.localeName,
                                ),
                              ),
                            ),
                          if (sortedTask.task.hasMessages)
                            const TaskIconWidget(
                              icon: Icons.message,
                            ),
                          if (sortedTask.task.hasDescription)
                            const TaskIconWidget(icon: Icons.description),
                          if (sortedTask.task.tags.isNotEmpty)
                            const TaskIconWidget(icon: Icons.tag),
                          if (taskImportance != TaskImportance.normal)
                            TaskIconWidget(
                              icon: Icons.flag,
                              color: getImportanceColor(taskImportance),
                            ),
                          if (taskColor != null)
                            TaskIconWidget(
                              icon: Icons.water_drop,
                              color: taskColor,
                            ),
                        ],
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

class TaskIconWidget extends StatelessWidget {
  const TaskIconWidget({
    required this.icon,
    this.color = ColorConstants.grey04,
    super.key,
  });

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return PaddingRight(
      8,
      child: SizedBox(
        width: 20,
        height: 20,
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }
}
