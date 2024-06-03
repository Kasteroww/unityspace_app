import 'package:flutter/material.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/tasks_page.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/widgets/divider.dart';
import 'package:unityspace/screens/widgets/common/paddings.dart';
import 'package:unityspace/src/theme/theme.dart';
import 'package:wstore/wstore.dart';

class TasksList extends StatelessWidget {
  const TasksList({
    required this.tasks,
    super.key,
    this.projectId,
  });

  final List<Task> tasks;
  final int? projectId;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, taskIndex) {
        return IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                flex: 8,
                child: PaddingLeft(
                  16,
                  child: Text(
                    tasks[taskIndex].name,
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
                    child: Text(
                      projectId != null
                          ? context
                              .wstore<TasksPageStore>()
                              .getStageNameByProjectId(
                                stages: tasks[taskIndex].stages,
                                projectId: projectId,
                              )
                          : context
                              .wstore<TasksPageStore>()
                              .getStagesNames(stages: tasks[taskIndex].stages),
                    ),
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
