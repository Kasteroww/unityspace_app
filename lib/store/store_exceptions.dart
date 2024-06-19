class StoreException implements Exception {
  StoreException({
    this.message,
    this.data,
  });
  final String? message;
  final Object? data;
}

class UpdatingNonexistentEntityStoreException extends StoreException {
  UpdatingNonexistentEntityStoreException({super.message, super.data});
}
