import 'package:flutter/material.dart';
import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/screens/notifications_screen/widgets/empty_notifications_stub.dart';
import 'package:unityspace/screens/notifications_screen/widgets/notifications_list/notifications_list.dart';
import 'package:unityspace/screens/notifications_screen/widgets/skeleton_listview/notification_skeleton_card.dart';
import 'package:unityspace/screens/widgets/paddings.dart';
import 'package:unityspace/screens/widgets/skeleton/skeleton_listview.dart';
import 'package:unityspace/store/notifications_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

/// Стор страницы уведомлений
///
/// Слой логики
///
/// Содержит в себе методы получения и обработки уведомлений пользователя
class NotificationPageStore extends WStore {
  //
  NotificationPageStore({
    required NotificationsStore notificationsStore,
    required UserStore userStore,
  })  : _notificationsStore = notificationsStore,
        _userStore = userStore;

  final NotificationsStore _notificationsStore;
  final UserStore _userStore;

  //
  NotificationErrors error = NotificationErrors.none;
  WStoreStatus status = WStoreStatus.init;
  int currentPage = 1;
  int maxPageCount = 1;

  List<NotificationModel> get notifications => computedFromStore(
        store: _notificationsStore,
        getValue: (store) => store.notifications.reverseSortedlist,
        keyName: 'notifications',
      );

  // Получение актуальных уведомлений
  List<NotificationModel> get unarchivedNotifications => computed(
        getValue: () =>
            notifications.where((notify) => !notify.archived).toList(),
        watch: () => [notifications],
        keyName: 'unarchivedNotifications',
      );

  OrganizationMembers get organizationMembers => computedFromStore(
        store: _userStore,
        getValue: (store) => store.organizationMembers,
        keyName: 'organizationMembers',
      );

  bool get needToLoadNextPage => computed<bool>(
        watch: () => [currentPage, maxPageCount],
        getValue: () => currentPage < maxPageCount,
        keyName: 'needToLoadNextPage',
      );

  /// Переход на следующую страницу уведомлений
  Future<void> nextPage() async {
    if (needToLoadNextPage) {
      setStore(() {
        currentPage += 1;
      });
      maxPageCount =
          await _notificationsStore.getNotificationsData(page: currentPage);
    }
  }

  ///Изменяет статус архивирования уведомлений из списка
  void changeArchiveStatusNotifications(
    List<NotificationModel> notificationList,
    bool archived,
  ) {
    final notificationIds =
        notificationList.map((notification) => notification.id).toList();
    _notificationsStore.changeArchiveStatusNotifications(
      notificationIds,
      archived,
    );
  }

  ///Изменяет статус прочтения уведомлений из спика
  void changeReadStatusNotification(
    List<NotificationModel> notificationList,
    bool unread,
  ) {
    final notificationIds =
        notificationList.map((notification) => notification.id).toList();
    _notificationsStore.changeReadStatusNotification(notificationIds, unread);
  }

  ///Загрузка уведомлений
  Future<void> loadData() async {
    if (status == WStoreStatus.loading) return;

    setStore(() {
      status = WStoreStatus.loading;
      error = NotificationErrors.none;
    });
    try {
      maxPageCount =
          await _notificationsStore.getNotificationsData(page: currentPage);
      setStore(() {
        status = WStoreStatus.loaded;
      });
    } catch (e, stack) {
      logger.e('on NotificationsPage'
          'NotificationsStore loadData error=$e\nstack=$stack');
      setStore(() {
        status = WStoreStatus.error;
        error = NotificationErrors.loadingDataError;
      });
    }
  }

  @override
  NotificationsPage get widget => super.widget as NotificationsPage;
}

/// Страница Уведомлений
///
/// UI Слой
///
/// Наследуется от WstoreWidget,
class NotificationsPage extends WStoreWidget<NotificationPageStore> {
  const NotificationsPage({
    super.key,
  });

  @override
  NotificationPageStore createWStore() => NotificationPageStore(
        notificationsStore: NotificationsStore(),
        userStore: UserStore(),
      )..loadData();

  @override
  Widget build(BuildContext context, NotificationPageStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.status,
      builderError: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Text(
            switch (store.error) {
              NotificationErrors.none => '',
              NotificationErrors.loadingDataError =>
                localization.problem_uploading_data_try_again
            },
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF111012).withOpacity(0.8),
              fontSize: 20,
              height: 1.2,
            ),
          ),
        );
      },
      builderLoading: (context) {
        return const PaddingHorizontal(
          20,
          child: SkeletonListView(
            skeletonCard: NotificationSkeletonCard(),
          ),
        );
      },
      builder: (context, _) {
        return const SizedBox.shrink();
      },
      builderLoaded: (context) {
        return WStoreBuilder<NotificationPageStore>(
          watch: (store) => [store.unarchivedNotifications],
          store: context.wstore<NotificationPageStore>(),
          builder: (context, store) {
            final List<NotificationModel> notifications =
                store.unarchivedNotifications;
            if (notifications.isEmpty) {
              return const EmptyNotificationsStub(
                isArchivePage: false,
              );
            }
            return NotificationsList(
              needToLoadNextPage: store.needToLoadNextPage,
              items: notifications,
              onLongPressButtonTap: (List<NotificationModel> list) {
                store.changeReadStatusNotification(
                  list,
                  list.any((element) => element.unread),
                );
              },
              onDismissEvent: (List<NotificationModel> list) {
                store.changeArchiveStatusNotifications(
                  list,
                  list.any((element) => element.archived),
                );
              },
              onScrolledDown: context.wstore<NotificationPageStore>().nextPage,
            );
          },
        );
      },
    );
  }
}
