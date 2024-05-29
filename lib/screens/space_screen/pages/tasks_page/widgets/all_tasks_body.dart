import 'package:flutter/material.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/tasks_page.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/widgets/divider.dart';
import 'package:unityspace/screens/space_screen/pages/tasks_page/widgets/tasks_list.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/common/paddings.dart';
import 'package:unityspace/src/theme/theme.dart';
import 'package:unityspace/store/tasks_store.dart';
import 'package:unityspace/utils/errors.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class SearchTaskStore extends WStore {
  final SearchTaskErrors error = SearchTaskErrors.none;
  WStoreStatus status = WStoreStatus.init;

  /// режим поиска, от него зависит отображается ли
  /// результат поиска или список всех задач
  bool isSearching = false;

  // для пагинации результата
  int tasksPage = 1;
  int tasksMaxPagesCount = 0;
  int tasksCount = 0;

  final TasksStore tasksStore = TasksStore();

  /// геттер задач из TasksStore
  List<Task>? get tasks => computedFromStore(
        store: tasksStore,
        getValue: (store) => store.tasks,
        keyName: 'tasks',
      );

  /// поиск задач по строке
  Future<void> searchTasks({required String searchString}) async {
    tasksStore.clearSearchedTasksStateLocally();
    if (searchString.isNotEmpty) {
      setStore(() {
        isSearching = true;
        status = WStoreStatus.loading;
      });

      final searchResult = await tasksStore.searchTasks(
        searchText: searchString,
        page: tasksPage,
      );

      setStore(() {
        tasksMaxPagesCount = searchResult.maxPagesCount;
        tasksCount = searchResult.tasksCount;
      });
    } else {
      setStore(() {
        isSearching = false;
      });
    }
  }

  @override
  void dispose() {
    tasksStore.clear();
    super.dispose();
  }

  @override
  AllTasksBody get widget => super.widget as AllTasksBody;
}

class AllTasksBody extends WStoreWidget<SearchTaskStore> {
  const AllTasksBody({
    super.key,
  });

  @override
  SearchTaskStore createWStore() => SearchTaskStore();

  @override
  Widget build(BuildContext context, SearchTaskStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Column(
      children: [
        AddDialogInputField(
          labelText: 'Найти',
          onChanged: (value) {
            store.searchTasks(searchString: value);
          },
        ),
        const PaddingTop(20),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                flex: 8,
                child: Text(
                  localization.task_name,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              const DividerWithoutPadding(
                isHorisontal: false,
                color: ColorConstants.grey04,
              ),
              Flexible(
                flex: 2,
                child: PaddingLeft(
                  8,
                  child: Text(
                    localization.column,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const DividerWithoutPadding(
          color: ColorConstants.grey04,
        ),
        WStoreValueBuilder<SearchTaskStore, bool>(
          watch: (store) => store.isSearching,
          builder: (context, store) {
            return Expanded(
              child: store
                  ? WStoreValueBuilder<TasksPageStore, List<TasksGroup>?>(
                      builder: (context, store) {
                        if (store != null) {
                          return TasksList(
                            tasksList: store,
                          );
                        } else {
                          return const Text('tasks is empty');
                        }
                      },
                      watch: (store) => store.searchTasksByProject,
                    )
                  : WStoreValueBuilder<TasksPageStore, List<TasksGroup>?>(
                      builder: (context, store) {
                        if (store != null) {
                          return TasksList(
                            tasksList: store,
                          );
                        } else {
                          return const Text('tasks is empty');
                        }
                      },
                      watch: (store) => store.tasksByProject,
                    ),
            );
          },
        ),
      ],
    );
  }
}
