import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:unityspace/models/notification_models.dart';

class DismissibleBackground extends StatelessWidget {
  final NotificationsGroup notificationsGroup;
  const DismissibleBackground({required this.notificationsGroup, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(230, 230, 230, 1),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 24,
        width: 24,
        child: SvgPicture.asset(
          _checkIfArchived(notificationsGroup.notifications)
              ? 'assets/icons/notifications/recycle_bin_2.svg'
              : 'assets/icons/notifications/download_box_1.svg',
        ),
      ),
    );
  }

  bool _checkIfArchived(
    List<NotificationModel> list,
  ) {
    return list.any((element) => element.archived);
  }
}
