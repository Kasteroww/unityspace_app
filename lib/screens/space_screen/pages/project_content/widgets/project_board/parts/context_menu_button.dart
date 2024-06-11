import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_board/parts/context_menu_item.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_board/project_boards.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class ContextMenuButton extends StatelessWidget {
  const ContextMenuButton({
    required this.stage,
    required this.task,
    required this.tasks,
    super.key,
  });

  final ProjectStage stage;
  final Task task;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final store = context.wstore<ProjectBoardsStore>();
    return PopupMenuButton<String>(
      elevation: 1,
      child: SvgPicture.asset(AppIcons.settings),
      itemBuilder: (BuildContext context) {
        final currentTaskIndex = tasks.indexOf(task);
        final lastTaskIndex = tasks.length - 1;
        final List<PopupMenuEntry<String>> items = [];
        if (currentTaskIndex == 0 && lastTaskIndex > 0) {
          items.add(
            PopupMenuItem(
              onTap: () => store.moveTaskDownOfStage(
                currentStageId: stage.id,
                taskId: task.id,
                lastTask: tasks.lastOrNull,
              ),
              child: ContextMenuItem(
                text: localization.move_it_to_bottom_column,
              ),
            ),
          );
        } else if (currentTaskIndex > 0 && lastTaskIndex == currentTaskIndex) {
          items.add(
            PopupMenuItem(
              onTap: () => store.moveTaskUpOfStage(
                currentStageId: stage.id,
                taskId: task.id,
                firstTask: tasks.firstOrNull,
              ),
              child: ContextMenuItem(
                text: localization.move_it_to_top_column,
              ),
            ),
          );
        } else if (currentTaskIndex != lastTaskIndex) {
          items.addAll([
            PopupMenuItem(
              onTap: () => store.moveTaskUpOfStage(
                currentStageId: stage.id,
                taskId: task.id,
                firstTask: tasks.firstOrNull,
              ),
              child: ContextMenuItem(
                text: localization.move_it_to_top_column,
              ),
            ),
            PopupMenuItem(
              onTap: () => store.moveTaskDownOfStage(
                currentStageId: stage.id,
                taskId: task.id,
                lastTask: tasks.lastOrNull,
              ),
              child: ContextMenuItem(
                text: localization.move_it_to_bottom_column,
              ),
            ),
          ]);
        }
        items.addAll([
          PopupMenuItem(
            child: ContextMenuItem(
              text: localization.move,
            ),
          ),
          PopupMenuItem(
            child: ContextMenuItem(
              text: localization.copy_task_link,
            ),
          ),
          PopupMenuItem(
            child: ContextMenuItem(
              text: localization.copy_task_number,
            ),
          ),
          PopupMenuItem(
            child: ContextMenuItem(
              text: localization.duplicate_task,
            ),
          ),
          PopupMenuItem(
            child: ContextMenuItem(
              text: localization.to_archive,
            ),
          ),
          PopupMenuItem(
            onTap: () => store.deleteTaskFromStage(
              taskId: task.id,
              stageId: stage.id,
            ),
            child: ContextMenuItem(
              text: localization.delete,
              color: Colors.red,
            ),
          ),
        ]);
        return items;
      },
    );
  }
}
