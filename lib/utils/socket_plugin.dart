import 'package:socket_io_client/socket_io_client.dart';
import 'package:unityspace/resources/constants.dart';
import 'package:unityspace/service/websync_service.dart';
import 'package:unityspace/store/auth_store.dart';
import 'package:unityspace/utils/logger_plugin.dart';

class SocketPlugin {
  static const serverURL = ConstantLinks.unitySpaceAppServerApi;
  static SocketPlugin? _instance;

  factory SocketPlugin() => _instance ??= SocketPlugin._();

  late final Socket socket;

  SocketPlugin._() {
    socket = io(
      serverURL,
      OptionBuilder()
          .setTransports(['websocket'])
          .setReconnectionDelayMax(10000)
          .disableAutoConnect()
          .setAuth({'token': AuthStore().userAccessToken})
          .build(),
    );

    socketConnect();
    socketDisconnect();
    socketNotification();
  }

  void socketConnect() {
    socket.on('connect', (_) => logger.d('connect: ${socket.id}'));
  }

  void socketDisconnect() {
    socket.on('disconnect', (_) => logger.d('disconnect'));
  }

  void socketNotification() {
    socket.on('notification', (data) async => onEvent(data));
  }

  void socketBroadcast() {
    socket.on('broadcast', (data) async => logger.w(data));
  }
}
