import 'package:flutter/material.dart';

import 'package:unityspace/models/notification_models.dart';

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
      child: Container(
        width: width,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 80,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(217, 217, 217, 1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text(notificationsGroup.title)
            ],
          ),
        ),
      ),
    );
  }
}
