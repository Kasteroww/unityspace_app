class ServiceException implements Exception {
  final String? message;
  final Object? response;

  ServiceException({
    this.message,
    this.response,
  });
}

class EmptyResponseServiceException extends ServiceException {
  EmptyResponseServiceException({
    super.message,
    super.response,
  });
}
