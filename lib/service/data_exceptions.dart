class DataException implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  DataException(this.message, [this.cause, this.stackTrace]);

  @override
  String toString() {
    if (cause == null) return message;
    return '$message: $cause\n$stackTrace';
  }
}

class LoadDataException extends DataException {
  LoadDataException(super.message, [super.cause, super.stackTrace]);
}

class JsonParsingException extends DataException {
  JsonParsingException(super.message, [super.cause, super.stackTrace]);
}
