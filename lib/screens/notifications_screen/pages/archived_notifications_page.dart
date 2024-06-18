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

class ArchivedNotificationPageStore extends WStore {
  //
  ArchivedNotificationPageStore({
    required NotificationsStore notificationsStore,
    required UserStore userStore,
  })  : _notificationsStore = notificationsStore,
        _userStore = userStore;

  final NotificationsStore _notificationsStore;
  final UserStore _userStore;

  //
  bool isArchived = true;
  NotificationErrors error = NotificationErrors.none;
  WStoreStatus status = WStoreStatus.init;
  int maxPageCount = 1;
  int currentPage = 1;

  List<NotificationModel> get notifications => computedFromStore(
        store: _notificationsStore,
        getValue: (store) => store.notifications.reverseSortedlist,
        keyName: 'notifications',
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
      maxPageCount = await _notificationsStore.getNotificationsData(
        page: currentPage,
        isArchived: isArchived,
      );
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

  ///Удаляет уведомления из списка
  void deleteNotifications(List<NotificationModel> notificationList) {
    final notificationIds =
        notificationList.map((notification) => notification.id).toList();
    _notificationsStore.deleteNotifications(notificationIds);
  }

  ///Загрузка уведомлений
  Future<void> loadData() async {
    if (status == WStoreStatus.loading) return;
    setStore(() {
      status = WStoreStatus.loading;
      error = NotificationErrors.none;
    });
    try {
      maxPageCount = await _notificationsStore.getNotificationsData(
        page: currentPage,
        isArchived: isArchived,
      );
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
  ArchivedNotificationsPage get widget =>
      super.widget as ArchivedNotificationsPage;
}

class ArchivedNotificationsPage
    extends WStoreWidget<ArchivedNotificationPageStore> {
  const ArchivedNotificationsPage({
    super.key,
  });

  @override
  ArchivedNotificationPageStore createWStore() => ArchivedNotificationPageStore(
        notificationsStore: NotificationsStore(),
        userStore: UserStore(),
      )..loadData();

  @override
  Widget build(BuildContext context, ArchivedNotificationPageStore store) {
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
        return WStoreBuilder(
          store: store,
          watch: (store) => [store.notifications],
          builder: (context, store) {
            final List<NotificationModel> notifications = store.notifications;
            if (notifications.isEmpty) {
              return EmptyNotificationsStub(
                isArchivePage: store.isArchived,
              );
            }
            return NotificationsList(
              needToLoadNextPage: store.needToLoadNextPage,
              items: notifications,
              onDismissEvent: (List<NotificationModel> list) {
                store.deleteNotifications(
                  list,
                );
              },
              onLongPressButtonTap: (List<NotificationModel> list) {
                store.changeArchiveStatusNotifications(
                  list,
                  list.any((element) => element.archived),
                );
              },
              onScrolledDown: store.nextPage,
            );
          },
        );
      },
    );
  }
}
