import 'package:flutter/material.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/utils/date_time_helper.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/widgets/divider.dart';
import 'package:unityspace/screens/widgets/paddings.dart';
import 'package:unityspace/screens/widgets/user_avatar_widget.dart';
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
        final List<Widget> reponsibleAvatars =
            _getResponsibleAvatars(sortedTask.task.responsibleUsersId);

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
                                TasksListDateTimeHelper.getFormattedEndDate(
                                  endDate: taskEndDate,
                                  locale: localization.localeName,
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: TasksListDateTimeHelper
                                              .isPastDeadline(
                                        sortedTask.task.dateEnd!,
                                      )
                                          ? Colors.red
                                          : ColorConstants.grey04,
                                    ),
                              ),
                            ),
                          if (sortedTask.task.blockReason != null &&
                              sortedTask.task.blockReason!.isNotEmpty)
                            const TaskIconWidget(
                              icon: Icons.front_hand,
                              color: Colors.red,
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
                          if (sortedTask.task.responsibleUsersId.isNotEmpty)
                            PaddingRight(
                              8,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: reponsibleAvatars,
                              ),
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

  List<Widget> _getResponsibleAvatars(List<int> responsibleIds) {
    final List<Widget> avatars = [];

    for (final int responsibleId in responsibleIds) {
      avatars.add(
        UserAvatarWidget(
          id: responsibleId,
          width: 20,
          height: 20,
          fontSize: 10,
        ),
      );

      // если аватар не последний в списке, добавить отступ
      if (responsibleId != responsibleIds.last) {
        avatars.add(const SizedBox(width: 8));

      }
    }
    return avatars;
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
