import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/screens/widgets/common/paddings.dart';
import 'package:unityspace/store/tasks_store.dart';
import 'package:unityspace/utils/constants.dart';
import 'package:unityspace/utils/errors.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

class TasksPageStore extends WStore {
  TasksErrors error = TasksErrors.none;
  WStoreStatus status = WStoreStatus.init;
  TasksStore tasksStore = TasksStore();
  int spaceId = 0;

  /// геттер задач из TasksStore
  List<Task>? get tasks => computedFromStore(
      store: tasksStore, getValue: (store) => store.tasks, keyName: 'tasks');

  /// загрузка задач по пространству и статусам
  Future<void> loadData() async {
    if (status == WStoreStatus.loading) return;
    setStore(() {
      status = WStoreStatus.loading;
      error = TasksErrors.none;
    });
    try {
      await tasksStore.getSpaceTasks(
        spaceId: spaceId,
        statuses: [TaskStatuses.inWork.value],
      );
      setStore(() {
        status = WStoreStatus.loaded;
      });
    } catch (e, stack) {
      logger.d('on AllTasksPage'
          'TasksStore loadData error=$e\nstack=$stack');
      setStore(() {
        status = WStoreStatus.error;
        error = TasksErrors.loadingDataError;
      });
    }
  }

  /// spaceId для получения задач, вызывается сразу после создания сторы
  initValues({required int currentSpaceId}) {
    setStore(() {
      spaceId = currentSpaceId;
    });
  }

  @override
  TasksPage get widget => super.widget as TasksPage;
}

class TasksPage extends WStoreWidget<TasksPageStore> {
  const TasksPage({
    required this.spaceId,
    super.key,
  });

  final int spaceId;

  @override
  TasksPageStore createWStore() => TasksPageStore()
    ..initValues(currentSpaceId: spaceId)
    ..loadData();

  @override
  Widget build(BuildContext context, TasksPageStore store) {
    return WStoreStatusBuilder<TasksPageStore>(
      store: store,
      watch: (store) => store.status,
      builder: (context, store) {
        return const SizedBox.shrink();
      },
      builderLoading: (context) {
        return Center(
          child: Lottie.asset(
            ConstantIcons.mainLoader,
            width: 200,
            height: 200,
          ),
        );
      },
      builderLoaded: (context) {
        return PaddingAll(
          20,
          child: WStoreValueBuilder<TasksPageStore, List<Task>?>(
              builder: (context, store) {
                if (store != null) {
                  return ListView.separated(
                      itemBuilder: (context, index) {
                        return Text(store[index].name);
                      },
                      separatorBuilder: (context, index) {
                        return const PaddingTop(8);
                      },
                      itemCount: store.length);
                } else {
                  return const Text('tasks is empty');
                }
              },
              watch: (store) => store.tasks),
        );
      },
    );
  }
}
