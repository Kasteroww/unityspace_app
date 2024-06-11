import 'package:flutter/material.dart';
import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/screens/notifications_screen/notifications_screen.dart';
import 'package:unityspace/utils/extensions/localization_extensions.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class Locations extends StatelessWidget {
  final NotificationsGroup notificationsGroup;

  const Locations({
    required this.notificationsGroup,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final locationGroups =
        context.wstore<NotificationsScreenStore>().groupLocations(
              notificationsGroup.locations,
            );
    final groupName =
        notificationsGroup.type.localize(localization: localization);
    const textStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Color.fromRGBO(102, 102, 102, 1),
    );
    final location = locationGroups.first;
    return Text(
      '${location.spaceName.isNotEmpty ? '${location.spaceName} / ' : ''}'
      '${location.projectName.isNotEmpty ? '${location.projectName} / ' : ''}'
      '$groupName',
      style: textStyle,
      overflow: TextOverflow.ellipsis,
    );
  }
}
