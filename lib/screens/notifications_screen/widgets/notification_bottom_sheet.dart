import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/notifications_screen/utils/notification_helper.dart';
import 'package:unityspace/screens/notifications_screen/utils/notifications_strings.dart';
import 'package:unityspace/screens/notifications_screen/widgets/notifications_info.dart';
import 'package:unityspace/screens/notifications_screen/widgets/notifications_list/parts/locations.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';

class NotificationBottomSheet extends StatelessWidget {
  NotificationBottomSheet({
    required this.notificationsGroup,
    super.key,
  });

  final NotificationsGroup notificationsGroup;
  final notificationHelper = NotificationHelper(userStore: UserStore());
  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final width = MediaQuery.of(context).size.width;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(217, 217, 217, 1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              if (notificationsGroup.type == NotificationType.task)
                Align(
                  alignment: const Alignment(-1, 0),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 20),
                    child: Locations(notificationsGroup: notificationsGroup),
                  ),
                )
              else
                const SizedBox(
                  height: 40,
                ),
              Align(
                alignment: const Alignment(-1, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      notificationHelper
                          .getPictureAssetByType(notificationsGroup),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        notificationsGroup.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          height: 23.44 / 20,
                          color: ColorConstants.grey02,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: width,
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        NotificationInfo(notificationGroup: notificationsGroup),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: width,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(194, 238, 213, 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${localization.go_to} ${NotificationsStrings.groupName(notificationsGroup, localization)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 20 / 14,
                      color: ColorConstants.grey02,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
