import 'package:unityspace/service/events/notification_events.dart';
import 'package:unityspace/service/websync/websync_notification_models.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:unityspace/service/exceptions/socket_io_exceptions.dart';
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
  final responseData = NotificationEvent.fromResponse(jsonData);
  return switch (responseData.event) {
    'notification_readed' => await notificationReaded(responseData.data),
    _ => logger.e('Websync ${responseData.event} is unknown'),
  };
}
