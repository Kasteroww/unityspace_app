import 'package:unityspace/service/exceptions/http_exceptions.dart';
import 'package:unityspace/utils/http_plugin.dart';

void handleDefaultHttpExceptions(HttpPluginException e) {
  if (e.statusCode == 400) {
    throw RequestFailed400HttpException(e.message, e);
  } else if (e.statusCode == 401) {
    throw Unauthorized401HttpException(e.message, e);
  } else if (e.statusCode == 403) {
    if (e.message == 'You are blocked') {
      throw UserBlocked403HttpException(e.message, e);
    }
    throw AccessForbidden403HttpException(e.message, e);
  } else if (e.statusCode == 404) {
    throw AddressDoesNotExist404HttpException(e.message, e);
  } else if (e.statusCode == 500) {
    if (e.message.contains('554')) {
      throw TooManyRequests500HttpException(e.message, e);
    }
    ServerUnavailable500HttpException(e.message, e);
  }
  throw HttpException(e.message);
}
