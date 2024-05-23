import 'package:flutter/material.dart';

import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/screens/notifications_screen/utils/notification_helper.dart';
import 'package:unityspace/screens/notifications_screen/utils/notifications_strings.dart';
import 'package:unityspace/store/project_store.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';

class Locations extends StatelessWidget {
  final NotificationsGroup notificationsGroup;

  Locations({
    super.key,
    required this.notificationsGroup,
  });

  final notificationHelper = NotificationHelper(userStore: UserStore());
  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final locationGroups = notificationHelper.groupLocations(
        notificationsGroup.locations, SpacesStore(), ProjectStore());
    final groupName =
        NotificationsStrings.groupName(notificationsGroup, localization);
    const textStyle = TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Color.fromRGBO(102, 102, 102, 1));
    final location = locationGroups.first;
    return Row(
      children: [
        if (location.spaceName.isNotEmpty)
          Text('${location.spaceName} / ', style: textStyle),
        if (location.projectName.isNotEmpty)
          Text('${location.projectName} / ', style: textStyle),
        Text(
          groupName,
          style: textStyle,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
