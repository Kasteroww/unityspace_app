import 'package:flutter/material.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/tasks_page.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/widgets/tasks_list.dart';
import 'package:unityspace/screens/widgets/paddings.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class GroupedTasksList extends StatelessWidget {
  const GroupedTasksList({
    required this.tasksList,
    super.key,
  });

  final List<ITasksGroup> tasksList;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasksList.length,
      itemBuilder: (context, groupIndex) {
        final tasks = tasksList[groupIndex].tasks;
        return TaskGroup(
          tasks: tasks,
          groupTitle: tasksList[groupIndex].groupTitle,
          projectId: (tasksList[groupIndex] is TasksProjectGroup)
              ? (tasksList[groupIndex] as TasksProjectGroup).id
              : null,
        );
      },
    );
  }
}

class TaskGroupStore extends WStore {
  bool isListVisible = true;

  void toggleVisibility() {
    setStore(() {
      isListVisible = !isListVisible;
    });
  }

  @override
  TaskGroup get widget => super.widget as TaskGroup;
}

class TaskGroup extends WStoreWidget<TaskGroupStore> {
  const TaskGroup({
    required this.tasks,
    required this.groupTitle,
    this.projectId,
    super.key,
  });

  final List<Task> tasks;
  final String groupTitle;
  final int? projectId;

  @override
  TaskGroupStore createWStore() => TaskGroupStore();

  @override
  Widget build(BuildContext context, TaskGroupStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            store.toggleVisibility();
          },
          child: Row(
            children: [
              WStoreValueBuilder<TaskGroupStore, bool>(
                watch: (store) => store.isListVisible,
                builder: (context, store) {
                  return store
                      ? const Icon(Icons.arrow_downward)
                      : const Icon(Icons.arrow_forward);
                },
              ),
              const PaddingLeft(20),
              Flexible(
                child: Text(
                  (groupTitle == 'No responsible')
                      ? localization.no_responsible
                      : groupTitle,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const PaddingTop(8),
        WStoreValueBuilder<TaskGroupStore, bool>(
          watch: (store) => store.isListVisible,
          builder: (context, store) {
            return PaddingVertical(
              16,
              child: Visibility(
                maintainState: true,
                visible: store,
                child: TasksList(
                  tasks: context.wstore<TasksPageStore>().sortTasks(tasks),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
