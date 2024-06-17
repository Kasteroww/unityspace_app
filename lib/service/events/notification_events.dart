import 'package:unityspace/service/websync/websync_notification_models.dart';
import 'package:unityspace/store/notifications_store.dart';

Future<void> notificationReaded(Map<String, dynamic> data) async {
  final jsonData = NotificationReadUnreadResponse.fromJson(data);
  final notificationData = NotificationReadUnread.fromResponse(jsonData);
  NotificationsStore().readLocally(
    id: notificationData.id,
    status: notificationData.status,
  );
}
