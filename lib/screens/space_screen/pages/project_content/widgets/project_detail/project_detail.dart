import 'package:flutter/material.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/models/task_message_models.dart';
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
import 'package:unityspace/store/task_messages_store.dart';
import 'package:unityspace/store/tasks_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:unityspace/utils/mixins/copy_to_clipboard_mixin.dart';
import 'package:wstore/wstore.dart';

class ChatItem {
  String id;
  TaskMessage? message;
  TaskHistory? history;
  DateTime date;

  ChatItem({
    required this.id,
    required this.date,
    this.message,
    this.history,
  });
}

class ProjectDetailStore extends WStore with CopyToClipboardMixin {
  @override
  String message = '';
  String taskNumberText = '';
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

  ///Все истории, что есть в сторе
  Histories get histories => computedFromStore(
        store: TasksStore(),
        getValue: (store) => store.histories,
        keyName: 'histories',
      );

  /// Истории, которые только в этом проекте
  List<TaskHistory> get projectHistory => computed(
        watch: () => [histories],
        getValue: () => _getProjectHistory(histories),
        keyName: 'projectHistory',
      );

  ///Все сообщения, что есть в сторе
  TaskMessages get taskMessages => computedFromStore(
        store: TaskMessagesStore(),
        getValue: (store) => store.taskMessages,
        keyName: 'taskMessages',
      );

  /// Сообщения, которые только в этом проекте
  List<TaskMessage> get projectMessages => computed(
        watch: () => [taskMessages],
        getValue: () => _getProjectMessages(taskMessages),
        keyName: 'projectMessages',
      );

  List<ChatItem> get chatItems => computed(
        watch: () => [
          projectHistory,
          projectMessages,
        ],
        getValue: () {
          // получение сообщений
          final messages = projectMessages.map(
            (message) => ChatItem(
              id: 'message-${message.id}',
              date: message.createdAt,
              message: message,
            ),
          );
          // получение историй
          final history = projectHistory.map(
            (item) => ChatItem(
              id: 'history-${item.id}',
              date: item.updateDate,
              history: item,
            ),
          );
          // Объединение
          final combinedList = [
            ...messages,
            ...history,
          ];

          // Сортировка по дате:
          combinedList.sort((a, b) => a.date.compareTo(b.date));

          return combinedList;
        },
        keyName: 'chatItems',
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
      await TasksStore().getTaskHistory(taskId: taskId);
      await TaskMessagesStore().getMessages(taskId: taskId);
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

  void setTaskNumberText(String newText) {
    setStore(() {
      taskNumberText = newText;
    });
  }

  OrganizationMembers get members => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.organizationMembers,
        keyName: 'members',
      );
  String getUserNameById(int id) => members[id]?.name ?? '';

  /// История конкретой задачи
  List<TaskHistory> _getProjectHistory(
    Histories histories,
  ) {
    final allHistory = histories.iterable;
    return allHistory
        .where(
          (history) =>
              history.taskId == taskId &&
              history.type != TaskChangesTypes.sendMessage &&
              history.type != TaskChangesTypes.createTask,
        )
        .toList();
  }

  /// История конкретой задачи
  List<TaskMessage> _getProjectMessages(TaskMessages messages) {
    final allMessages = messages.iterable;
    return allMessages.where((message) => message.taskId == taskId).toList();
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
    final localization = LocalizationHelper.getLocalizations(context);
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
        store.setTaskNumberText(
          '#${store.task?.id}',
        );
        return WStoreBuilder<ProjectDetailStore>(
          watch: (store) => [
            store.task,
          ],
          builder: (context, store) {
            return WStoreStringListener<ProjectDetailStore>(
              watch: (store) => store.message,
              reset: (store) => store.message = '',
              onNotEmpty: (context, message) async {
                store.setTaskNumberText(
                  localization.copied,
                );
                Future.delayed(const Duration(seconds: 3), () {
                  store.setTaskNumberText(
                    '#${store.task?.id}',
                  );
                });
              },
              child: Column(
                children: [
                  WStoreBuilder<ProjectDetailStore>(
                    watch: (store) => [
                      store.taskNumberText,
                    ],
                    builder: (context, store) {
                      return HeaderComponent(
                        taskText: store.taskNumberText,
                        onCopyButtonTap: () {
                          store.copy(
                            text: '#${store.task?.id}',
                            successMessage: localization.task_number_copied,
                            errorMessage: localization.copy_error,
                          );
                        },
                      );
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            top: 16,
                            right: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                              ColorComponent(
                                color: store.task?.color,
                              ),
                              const SizedBox(height: 10),
                              const DateComponent(),
                              const SizedBox(height: 10),
                              const ShortcutsComponent(),
                              const AddFieldButtonComponent(),
                              const MessagesComponent(),
                              BottomNavigationButtonComponent(
                                focusNode: FocusNode(),
                                userIds: store.task?.members ?? [],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
