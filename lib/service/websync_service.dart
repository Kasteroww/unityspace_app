import 'package:unityspace/utils/socket_plugin.dart';

void connect() {
  SocketPlugin().socket.connect();
}

void disconnect() {
  SocketPlugin().socket.disconnect();
}
