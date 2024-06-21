import 'package:unityspace/service/events/notification_events.dart';
import 'package:unityspace/service/exceptions/socket_io_exceptions.dart';
import 'package:unityspace/service/websync/websync_notification_models.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:unityspace/utils/socket_plugin.dart';

void connect() {
  try {
    SocketPlugin().socket.connect();
  } on Exception catch (e) {
    throw WebsyncConnectSocketIoException(exception: e);
  }
}

void disconnect() {
  try {
    SocketPlugin().socket.disconnect();
  } on Exception catch (e) {
    throw WebsyncDisconnectSocketIoException(exception: e);
  }
}

Future<void> onEvent(Map<String, dynamic> data) async {
  final jsonData = NotificationEventResponse.fromJson(data);
  switch (jsonData.event) {
    case 'notification_created':
      await notificationCreated(jsonData.data);
    case 'notification_readed':
      await notificationReadStatusChanged(
        jsonData.data,
      );
    case 'notification_archived':
      await notificationArchived(jsonData.data);
    case 'notification_read_all':
      if (jsonData.data is List) {
        await notificationReadedAll(
          jsonData.data,
        );
      }
    case 'notification_task_name_changed':
      logger.e('${jsonData.data}');
    default:
      logger.e('Websync ${jsonData.event} is unknown');
  }
}
