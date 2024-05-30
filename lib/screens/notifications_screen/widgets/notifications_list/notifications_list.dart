import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/screens/notifications_screen/pages/notifications_page.dart';
import 'package:unityspace/screens/notifications_screen/utils/notification_helper.dart';
import 'package:unityspace/screens/notifications_screen/widgets/notification_bottom_sheet.dart';
import 'package:unityspace/screens/notifications_screen/widgets/notifications_list/parts/dismissible_background.dart';
import 'package:unityspace/screens/notifications_screen/widgets/notifications_list/parts/notifications_day_text.dart';
import 'package:unityspace/screens/notifications_screen/widgets/notifications_list/parts/notifications_info_card.dart';
import 'package:unityspace/screens/notifications_screen/widgets/skeleton_listview/notification_skeleton_card.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

/// Список дней уведомлений
class NotificationsList extends StatelessWidget {
  final bool needToLoadNextPage;
  final List<NotificationModel> items;
  final void Function(List<NotificationModel> list) onDismissEvent;
  final void Function(List<NotificationModel> list) onLongPressButtonTap;
  final void Function() onScrolledDown;
  NotificationsList({
    required this.onDismissEvent,
    required this.items,
    required this.onLongPressButtonTap,
    required this.needToLoadNextPage,
    required this.onScrolledDown,
    super.key,
  });

  final notificationHelper = NotificationHelper(userStore: UserStore());

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final dayLists = notificationHelper.groupNotificationsByDay(items);
    return ListView.builder(
      itemCount: needToLoadNextPage ? dayLists.length + 1 : dayLists.length,
      itemBuilder: (BuildContext context, int index) {
        if (index == dayLists.length) {
          _loadMoreItems();
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: NotificationSkeletonCard(),
          );
        }
        final dayList = dayLists[index];
        final List<NotificationsGroup> typeList =
            notificationHelper.groupNotificationsByObject(
          dayList,
        );

        // Виджет с содержимым одного дня уведомлений
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NotificationsDayText(
                localization: localization,
                date: dayList.first.createdAt,
              ),
              const SizedBox(
                height: 16,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: typeList.length,
                itemBuilder: (BuildContext context, int index) {
                  final NotificationsGroup notificationsGroup = typeList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onLongPressStart: (LongPressStartDetails details) {
                        showCustomMenu(
                          context: context,
                          position: details.globalPosition,
                          list: notificationsGroup.notifications,
                          localization: localization,
                        );
                      },
                      onTap: () {
                        showNotificationInfo(
                          context: context,
                          notificationsGroup: notificationsGroup,
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Dismissible(
                          key: Key(UniqueKey().toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            onDismissEvent(
                              notificationsGroup.notifications,
                            );
                          },
                          background: DismissibleBackground(
                            notificationsGroup: notificationsGroup,
                          ),
                          child: NotificationsInfoCard(
                            notificationsGroup: notificationsGroup,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadMoreItems() async {
    if (needToLoadNextPage) {
      debugPrint('Load more items');
      onScrolledDown();
    }
  }

  Future<void> showCustomMenu({
    required BuildContext context,
    required Offset position,
    required List<NotificationModel> list,
    required AppLocalizations localization,
  }) async {
    final RenderBox? overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;

    if (overlay != null) {
      await showMenu(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        context: context,
        position: RelativeRect.fromRect(
          position & const Size(40, 40), // размер и позиция меню
          Offset.zero & overlay.size,
        ),
        items: [
          PopupMenuItem(
            onTap: () {
              onLongPressButtonTap(list);
            },
            child: Text(
              list.any((element) => element.archived)
                  ? localization.restore_from_archive
                  : list.any((element) => element.unread)
                      ? localization.mark_as_read
                      : localization.mark_as_unread,
              style: const TextStyle(
                color: Color.fromRGBO(51, 51, 51, 1),
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ).then((value) {});
    }
  }

  void showNotificationInfo({
    required BuildContext context,
    required NotificationsGroup notificationsGroup,
  }) {
    // Отмечаем уведомления как прочитанные
    if (notificationsGroup.notifications
        .any((element) => element.unread && !element.archived)) {
      context
          .wstore<NotificationPageStore>()
          .changeReadStatusNotification(notificationsGroup.notifications, true);
    }

    // Отображаем нижнюю панель с информацией
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return NotificationBottomSheet(notificationsGroup: notificationsGroup);
      },
    );
  }
}
