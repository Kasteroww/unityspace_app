class SocketIoException implements Exception {
  final String? message;
  final Object? exception;

  SocketIoException({
    this.message,
    this.exception,
  });
}

class WebsyncConnectSocketIoException extends SocketIoException {
  WebsyncConnectSocketIoException({
    super.message,
    super.exception,
  });
}

class WebsyncDisconnectSocketIoException extends SocketIoException {
  WebsyncDisconnectSocketIoException({
    super.message,
    super.exception,
  });
}
