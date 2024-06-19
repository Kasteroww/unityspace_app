import 'package:flutter/material.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/add_field_button_component.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/bottom_navigations_button_component.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/color_component.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/date_component.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/header_component.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/importance_component.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/messages_component.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/responsible/responsible_part.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/shortcuts_component.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/status_component.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/task_location/task_location_component.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/tasks_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

class ProjectDetailStore extends WStore {
  ProjectErrors error = ProjectErrors.none;
  WStoreStatus status = WStoreStatus.init;

  int get taskId => widget.taskId;

  Tasks get tasks => computedFromStore(
        store: TasksStore(),
        getValue: (store) => store.tasks,
        keyName: 'tasks',
      );
  Task? get task => computed(
        getValue: () => tasks[taskId],
        watch: () => [tasks],
        keyName: 'task',
      );

  Histories get histories => computedFromStore(
        store: TasksStore(),
        getValue: (store) => store.histories,
        keyName: 'histories',
      );

  List<TaskHistory>? get currentHistory => computed(
        watch: () => [histories],
        getValue: () => _getCurrentHistory(histories),
        keyName: 'currentHistory ',
      );

  /// Получение списка исполнителей по задаче
  List<int> get responsibleUsers => computed(
        watch: () => [task],
        getValue: () => task?.responsibleUsersId ?? [],
        keyName: 'responsibleUsers',
      );

  Spaces get spaces => computedFromStore(
        store: SpacesStore(),
        getValue: (store) => store.spaces,
        keyName: 'spaces',
      );

  Space? get space => computed(
        watch: () => [spaces],
        getValue: () => spaces[widget.spaceId ?? 0],
        keyName: 'space',
      );

  /// Получение списка членов пространства
  List<SpaceMember> get spaceMembers => computed(
        watch: () => [space, responsibleUsers],
        getValue: () => space?.members ?? [],
        keyName: 'spaceMembers',
      );

  Future<void> loadData(int taskId) async {
    if (status == WStoreStatus.loading) return;
    setStore(() {
      status = WStoreStatus.loading;
      error = ProjectErrors.none;
    });
    try {
      await TasksStore().getTaskHistory(taskId);
      setStore(() {
        status = WStoreStatus.loaded;
      });
    } catch (e, stack) {
      logger.e('on ProjectDetail'
          'ProjectDetailStore loadData error=$e\nstack=$stack');
      setStore(() {
        status = WStoreStatus.error;
        error = ProjectErrors.loadingDataError;
      });
    }
  }

  OrganizationMembers get members => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.organizationMembers,
        keyName: 'members',
      );
  String getUserNameById(int id) => members[id]?.name ?? '';

  List<TaskHistory> _getCurrentHistory(Histories histories) {
    final allHistory = histories.iterable;
    return allHistory.where((history) => history.taskId == taskId).toList();
  }

  @override
  ProjectDetail get widget => super.widget as ProjectDetail;
}

class ProjectDetail extends WStoreWidget<ProjectDetailStore> {
  final int taskId;
  final int? spaceId;

  const ProjectDetail({
    required this.taskId,
    required this.spaceId,
    super.key,
  });

  @override
  ProjectDetailStore createWStore() => ProjectDetailStore()..loadData(taskId);

  @override
  Widget build(BuildContext context, ProjectDetailStore store) {
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.status,
      builder: (context, _) {
        return const SizedBox.shrink();
      },
      builderLoading: (context) {
        return const SizedBox.expand();
      },
      builderLoaded: (context) {
        return WStoreBuilder<ProjectDetailStore>(
          watch: (store) => [store.task],
          builder: (context, store) {
            return SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HeaderComponent(task: store.task),
                      const StatusComponent(),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          store.task?.name ?? '',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const TaskLocationComponent(),
                      const SizedBox(height: 20),
                      ResponsiblePart(
                        spaceId: spaceId,
                        taskId: store.task?.id,
                      ),
                      const SizedBox(height: 10),
                      ImportanceComponent(task: store.task),
                      const SizedBox(height: 10),
                      const ColorComponent(),
                      const SizedBox(height: 10),
                      const DateComponent(),
                      const SizedBox(height: 10),
                      const ShortcutsComponent(),
                      const AddFieldButtonComponent(),
                      Text('history Length: ${store.currentHistory?.length}'),
                      const MessagesComponent(),
                      BottomNavigationButtonComponent(
                        focusNode: FocusNode(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
