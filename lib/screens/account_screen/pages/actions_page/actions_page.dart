import 'package:flutter/material.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/screens/account_screen/pages/actions_page/widgets/action_card.dart';
import 'package:unityspace/screens/account_screen/pages/actions_page/widgets/action_skeleton_card.dart';
import 'package:unityspace/screens/widgets/common/skeleton/skeleton_listview.dart';
import 'package:unityspace/utils/constants.dart';
import 'package:unityspace/utils/date_time_converter.dart';
import 'package:unityspace/utils/errors.dart';
import 'package:unityspace/screens/widgets/common/paddings.dart';
import 'package:unityspace/store/tasks_store.dart';
import 'package:unityspace/utils/helpers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:unityspace/src/theme/theme.dart';
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

  void nextPage() {
    if (currentPage < maxPagesCount) {
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

class ActionsList extends StatelessWidget {
  const ActionsList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localization =
        LocalizationHelper.getLocalizations(context);
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        if (notification.metrics.atEdge) {
          // if have scrolled to the bottom
          if (notification.metrics.pixels != 0) {
            context.wstore<ActionsPageStore>().nextPage();
          }
        }
        return true;
      },
      child: WStoreValueBuilder<ActionsPageStore, List<TaskHistory>>(
        watch: (store) => store.history ?? [],
        store: context.wstore<ActionsPageStore>(),
        builder: (context, history) {
          return ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final action = history[index];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(builder: (context, _) {
                      if (index == 0 ||
                          (dateFromDateTime(action.updateDate) !=
                              dateFromDateTime(
                                  history[index - 1].updateDate))) {
                        return Column(
                          children: [
                            const PaddingTop(12),
                            Text(
                                DateTimeConverter.formatDateEEEEdMMMM(
                                    date: action.updateDate,
                                    localization: localization,
                                    locale: localization.localeName),
                                style: textTheme.bodyMedium!.copyWith(
                                    color: ColorConstants.grey04,
                                    fontWeight: FontWeight.w400)),
                            const PaddingTop(12),
                          ],
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
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
              });
        },
      ),
    );
  }
}
