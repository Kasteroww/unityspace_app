import 'package:flutter/material.dart';

import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/screens/notifications_screen/widgets/notifications_info.dart';
import 'package:unityspace/src/theme/theme.dart';

class NotificationBottomSheet extends StatelessWidget {
  const NotificationBottomSheet({
    super.key,
    required this.notificationsGroup,
  });

  final NotificationsGroup notificationsGroup;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
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
            const SizedBox(
              height: 8,
            ),
            Align(
                alignment: const Alignment(-1, 0),
                child: Text(
                  notificationsGroup.title,
                  style: const TextStyle(
                    fontFamily: 'roboto',
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    height: 23.44 / 20,
                    color: ColorConstants.grey03,
                  ),
                )),
            const SizedBox(
              height: 8,
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
          ],
        ),
      ),
    );
  }
}
