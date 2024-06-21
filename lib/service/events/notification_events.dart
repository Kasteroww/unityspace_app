import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/service/websync/websync_notification_models.dart';
import 'package:unityspace/store/notifications_store.dart';

Future<void> notificationReadStatusChanged(
  Map<String, dynamic> data,
) async {
  final jsonData = NotificationReadUnreadResponse.fromJson(data);
  final notificationData = NotificationReadUnread.fromResponse(jsonData);
  NotificationsStore().changeReadStatusLocally(
    id: notificationData.id,
    status: notificationData.status,
  );
}

Future<void> notificationReadedAll(
  List data,
) async {
  for (final Map<String, dynamic> map in data) {
    final jsonData = NotificationReadUnreadResponse.fromJson(map);
    final notificationData = NotificationReadUnread.fromResponse(jsonData);
    NotificationsStore().changeReadStatusLocally(
      id: notificationData.id,
      status: false,
    );
  }
}

Future<void> notificationCreated(Map<String, dynamic> data) async {
  final jsonData = NotificationResponse.fromJson(data);
  final notificationData = NotificationModel.fromResponse(jsonData);
  NotificationsStore().updateNotificationsLocally(notificationData);
}

Future<void> notificationArchived(Map<String, dynamic> data) async {
  final jsonData = NotificationResponse.fromJson(data);
  final notificationData = NotificationModel.fromResponse(jsonData);
  NotificationsStore().updateNotificationsLocally(notificationData);
}
