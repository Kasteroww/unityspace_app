import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:unityspace/store/auth_store.dart';

class HttpPluginException implements Exception {
  final int statusCode;
  final String message;
  final String error;

  const HttpPluginException(this.statusCode, this.message, this.error);

  @override
  String toString() {
    return 'HttpPluginException{statusCode: $statusCode, message: $message, error: $error}';
  }
}

class HttpPlugin {
  static const baseURL = 'https://server.unityspace.ru';

  static HttpPlugin? _instance;

  factory HttpPlugin() => _instance ??= HttpPlugin._();

  final http.Client _client = http.Client();
  late final String _host;
  late final String _scheme;
  final Map<String, String> _headers = {};

  HttpPlugin._() {
    final uri = Uri.parse(baseURL);
    _host = uri.host;
    _scheme = uri.scheme;
  }

  void setAuthorizationHeader(final String authorization) {
    if (authorization.isEmpty) {
      _headers.remove('Authorization');
      return;
    }
    _headers['Authorization'] = authorization;
  }

  Future<http.Response> post(final String url,
      [final Map<String, dynamic>? data,
      Map<String, dynamic>? queryParameters]) {
    return send('POST', url, data, queryParameters);
  }

  Future<http.Response> patch(
    final String url, [
    final Map<String, dynamic>? data,
  ]) {
    return send('PATCH', url, data);
  }

  Future<http.Response> delete(
    final String url, [
    final Map<String, dynamic>? data,
  ]) {
    return send('DELETE', url, data);
  }

  Future<http.Response> get(
    final String url, [
    Map<String, dynamic>? queryParameters,
  ]) {
    return send('GET', url, null, queryParameters);
  }

  Future<http.Response> send(
    final String method,
    final String url, [
    final Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  ]) async {
    try {
      if (data != null) {
        logger.d('$method REQUEST to $url with data = $data');
      } else if (queryParameters != null) {
        logger.d('$method REQUEST to $url with params = $queryParameters');
      } else {
        logger.d('$method REQUEST to $url');
      }
      var request = _makeRequest(method, url, data, queryParameters);
      var responseStream = await _client.send(request);
      var response = await http.Response.fromStream(responseStream);
      if (response.statusCode == 401 && url != '/auth/refresh') {
        // это не запрос на обновление токена и токен протух
        // пытаемся обновить и послать запрос заново
        final needSendAgain = await AuthStore().refreshUserToken();
        if (needSendAgain) {
          if (data != null) {
            logger.d('RETRY $method REQUEST to $url with data = $data');
          } else if (queryParameters != null) {
            logger.d(
                'RETRY $method REQUEST to $url with params = $queryParameters');
          } else {
            logger.d('RETRY $method REQUEST to $url');
          }
          // заново собираем изначальный заброс (токены авторизации обновились)
          request = _makeRequest(method, url, data, queryParameters);
          responseStream = await _client.send(request);
          response = await http.Response.fromStream(responseStream);
        }
      }
      logger.d(
        '$method RESPONSE from $url\nstatus = ${response.statusCode}\nbody = ${response.body}',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      }
      final jsonData = json.decode(response.body);
      final message = jsonData['message'];
      throw HttpPluginException(
        response.statusCode,
        message is List<dynamic>
            ? message.firstOrNull?.toString() ?? 'unknown'
            : message?.toString() ?? 'unknown',
        jsonData['error']?.toString() ?? 'unknown',
      );
    } catch (e) {
      logger.d('$method RESPONSE from $url exception = ${e.toString()}');
      if (e is http.ClientException) {
        throw HttpPluginException(-1, e.message, 'ClientException');
      }
      rethrow;
    }
  }

  Future<http.Response> sendFileFromMemory(
    final String method,
    final String url,
    final List<int> file, [
    final Map<String, String>? fields,
  ]) async {
    try {
      if (fields != null) {
        logger.d('$method FILE REQUEST to $url with fields = $fields');
      } else {
        logger.d('$method FILE REQUEST to $url');
      }
      var request = _makeRequestFile(method, url, file, fields);
      var responseStream = await _client.send(request);
      var response = await http.Response.fromStream(responseStream);
      if (response.statusCode == 401 && url != '/auth/refresh') {
        // это не запрос на обновление токена и токен протух
        // пытаемся обновить и послать запрос заново
        final needSendAgain = await AuthStore().refreshUserToken();
        if (needSendAgain) {
          if (fields != null) {
            logger
                .d('RETRY $method FILE REQUEST to $url with fields = $fields');
          } else {
            logger.d('RETRY $method FILE REQUEST to $url');
          }
          // заново собираем изначальный заброс (токены авторизации обновились)
          request = _makeRequestFile(method, url, file, fields);
          responseStream = await _client.send(request);
          response = await http.Response.fromStream(responseStream);
        }
      }
      logger.d(
        '$method FILE RESPONSE from $url\nstatus = ${response.statusCode}\nbody = ${response.body}',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      }
      final jsonData = json.decode(response.body);
      final message = jsonData['message'];
      throw HttpPluginException(
        response.statusCode,
        message is List<dynamic>
            ? message.firstOrNull?.toString() ?? 'unknown'
            : message?.toString() ?? 'unknown',
        jsonData['error']?.toString() ?? 'unknown',
      );
    } catch (e) {
      logger.d('$method FILE RESPONSE from $url exception = ${e.toString()}');
      if (e is http.ClientException) {
        throw HttpPluginException(-1, e.message, 'ClientException');
      }
      rethrow;
    }
  }

  http.Request _makeRequest(
    final String method,
    final String url,
    final Map<String, dynamic>? data,
    final Map<String, dynamic>? queryParameters,
  ) {
    final uri = _scheme == 'https'
        ? Uri.https(_host, url, queryParameters)
        : Uri.http(_host, url, queryParameters);
    final request = http.Request(method, uri);
    http.MultipartFile;
    http.MultipartRequest;
    request.headers.addAll(_headers);
    if (data != null) {
      request.headers['Content-Type'] = 'application/json; charset=UTF-8';
      request.body = jsonEncode(data);
    }
    return request;
  }

  http.MultipartRequest _makeRequestFile(
    final String method,
    final String url,
    final List<int> fileData,
    final Map<String, String>? fields,
  ) {
    final uri =
        _scheme == 'https' ? Uri.https(_host, url) : Uri.http(_host, url);
    final request = http.MultipartRequest(method, uri);
    fields?.forEach((key, value) {
      request.fields[key] = value;
    });
    final file = http.MultipartFile.fromBytes(
      'file',
      fileData,
      filename: 'file',
    );
    request.files.add(file);
    request.headers.addAll(_headers);
    return request;
  }
}
