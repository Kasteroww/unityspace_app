import 'package:flutter/material.dart';

import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/screens/notifications_screen/utils/notification_helper.dart';
import 'package:unityspace/screens/notifications_screen/widgets/notification_bottom_sheet.dart';
import 'package:unityspace/screens/notifications_screen/widgets/notifications_list/parts/dismissible_background.dart';
import 'package:unityspace/screens/notifications_screen/widgets/notifications_list/parts/notifications_day_text.dart';
import 'package:unityspace/screens/notifications_screen/widgets/notifications_list/parts/notifications_info_card.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Список дней уведомлений
class NotificationsList extends StatelessWidget {
  final List<NotificationModel> items;
  final void Function(List<NotificationModel> list) onDismissEvent;
  final void Function(List<NotificationModel> list) onLongPressButtonTap;
  NotificationsList({
    super.key,
    required this.onDismissEvent,
    required this.items,
    required this.onLongPressButtonTap,
  });

  final notificationHelper = NotificationHelper();
  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final dayLists = notificationHelper.groupNotificationsByDay(items);
    return ListView.builder(
        itemCount: dayLists.length,
        itemBuilder: (BuildContext context, int index) {
          final dayList = dayLists[index];
          final List<NotificationsGroup> typeList =
              notificationHelper.groupNotificationsByObject(
            dayList,
          );

          /// Виджет с содержимым одного дня уведомлений
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NotificationsDayText(
                    localization: localization, date: dayList.first.createdAt),
                const SizedBox(
                  height: 16,
                ),
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: typeList.length,
                    itemBuilder: (BuildContext context, int index) {
                      NotificationsGroup notificationsGroup = typeList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onLongPressStart: (LongPressStartDetails details) {
                            showCustomMenu(
                                context: context,
                                position: details.globalPosition,
                                list: notificationsGroup.notifications,
                                localization: localization);
                          },
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return NotificationBottomSheet(
                                    notificationsGroup: notificationsGroup);
                              },
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Dismissible(
                              key: Key(UniqueKey().toString()),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                onDismissEvent(
                                    notificationsGroup.notifications);
                              },
                              background: DismissibleBackground(
                                  notificationsGroup: notificationsGroup),
                              child: NotificationsInfoCard(
                                  notificationGroup: notificationsGroup),
                            ),
                          ),
                        ),
                      );
                    }),
              ],
            ),
          );
        });
  }

  void showCustomMenu(
      {required BuildContext context,
      required Offset position,
      required List<NotificationModel> list,
      required,
      required AppLocalizations localization}) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

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
                fontSize: 12),
          ),
        ),
      ],
    ).then((value) {});
  }
}
