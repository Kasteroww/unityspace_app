import 'package:flutter/material.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/resources/constants.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/account_screen/pages/actions_page/widgets/action_card.dart';
import 'package:unityspace/screens/account_screen/pages/actions_page/widgets/action_skeleton_card.dart';
import 'package:unityspace/screens/widgets/paddings.dart';
import 'package:unityspace/screens/widgets/skeleton/skeleton_listview.dart';
import 'package:unityspace/store/tasks_store.dart';
import 'package:unityspace/utils/date_time_converter.dart';
import 'package:unityspace/utils/helpers.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

class ActionsPageStore extends WStore {
  WStoreStatus status = WStoreStatus.init;
  ActionsErrors error = ActionsErrors.none;
  int maxPagesCount = 1;
  int currentPage = 1;

  @override
  ActionsPage get widget => super.widget as ActionsPage;

  List<TaskHistory>? get history => computedFromStore(
        store: TasksStore(),
        getValue: (store) => store.history,
        keyName: 'history',
      );

  bool get needToLoadNextPage => computed<bool>(
        watch: () => [currentPage, maxPagesCount],
        getValue: () => currentPage < maxPagesCount,
        keyName: 'needToLoadNextPage',
      );

  void nextPage() {
    if (needToLoadNextPage) {
      setStore(() {
        currentPage += 1;
      });
      loadNextPage();
    }
  }

  String? getTaskNameById(int id) {
    return TasksStore().getTaskById(id)?.name;
  }

  Future<void> loadNextPage() async {
    final int newMaxPageCount = await TasksStore().getTasksHistory(currentPage);
    setStore(() {
      maxPagesCount = newMaxPageCount;
    });
  }

  Future<void> loadData() async {
    if (status == WStoreStatus.loading) return;
    setStore(() {
      status = WStoreStatus.loading;
      error = ActionsErrors.none;
    });
    try {
      final int pages = await TasksStore().getTasksHistory(currentPage);
      setStore(() {
        maxPagesCount = pages;
        status = WStoreStatus.loaded;
      });
    } catch (e, stack) {
      logger.d('on ActionsPage'
          'ActionsPage loadData error=$e\nstack=$stack');
      setStore(() {
        status = WStoreStatus.error;
        error = ActionsErrors.loadingDataError;
      });
    }
  }

  @override
  void dispose() {
    TasksStore().clear();
    super.dispose();
  }
}

class ActionsPage extends WStoreWidget<ActionsPageStore> {
  const ActionsPage({
    super.key,
  });

  @override
  ActionsPageStore createWStore() => ActionsPageStore()..loadData();

  @override
  Widget build(BuildContext context, ActionsPageStore store) {
    return PaddingHorizontal(
      20,
      child: WStoreStatusBuilder(
        store: store,
        watch: (store) => store.status,
        builder: (context, _) {
          return const SizedBox.shrink();
        },
        builderLoaded: (context) {
          return const ActionsList();
        },
        builderLoading: (context) {
          return const SkeletonListView(
            skeletonCard: ActionSkeletonCard(),
          );
        },
        builderError: (context) {
          return const Text(ConstantStrings.error);
        },
      ),
    );
  }
}

class ActionsList extends StatefulWidget {
  const ActionsList({
    super.key,
  });

  @override
  State<ActionsList> createState() => _ActionsListState();
}

class _ActionsListState extends State<ActionsList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    if (context.wstore<ActionsPageStore>().needToLoadNextPage) {
      debugPrint('Load more items');
      context.wstore<ActionsPageStore>().nextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreBuilder<ActionsPageStore>(
      watch: (store) => [store.history, store.needToLoadNextPage],
      store: context.wstore<ActionsPageStore>(),
      builder: (context, store) {
        final List<TaskHistory> history = store.history ?? [];
        return ListView.builder(
          controller: _scrollController,
          itemCount:
              store.needToLoadNextPage ? history.length + 1 : history.length,
          itemBuilder: (context, index) {
            if (index == history.length) {
              return const ActionSkeletonCard();
            }
            final action = history[index];
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, _) {
                    if (index == 0 ||
                        (dateFromDateTime(action.updateDate) !=
                            dateFromDateTime(history[index - 1].updateDate))) {
                      return Column(
                        children: [
                          const PaddingTop(12),
                          Text(
                            DateTimeConverter.formatDateEEEEdMMMM(
                              date: action.updateDate,
                              localization: localization,
                              locale: localization.localeName,
                            ),
                            style: textTheme.bodyMedium?.copyWith(
                              color: ColorConstants.grey04,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const PaddingTop(12),
                        ],
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                PaddingBottom(
                  12,
                  child: ActionCard(
                    isSelected: false,
                    data: (
                      history: action,
                      taskName: context
                          .wstore<ActionsPageStore>()
                          .getTaskNameById(action.id)
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
