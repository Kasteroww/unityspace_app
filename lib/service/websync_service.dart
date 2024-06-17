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
