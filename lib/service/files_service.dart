import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:unityspace/models/files_models.dart';
import 'package:unityspace/service/service_exceptions.dart';
import 'package:unityspace/utils/http_plugin.dart';

Future<String> uploadAvatarByChunks({
  required Uint8List file,
}) async {
  try {
    const chunkSize = 1 * 1024 * 1024;

    final responseInitUpload =
        await HttpPlugin().post('/files/initiateUpload', {
      'bucket': 'avatars',
      'type': 'image/png',
      'fileNameInUtf': 'avatar.png',
    });
    final initUpload =
        InitialUploadResponse.fromJson(json.decode(responseInitUpload.body));
    final totalChunks = (file.length / chunkSize).ceil();
    int start = 0;
    int end = 0;
    final List<Future<http.Response>> uploads = [];
    for (int i = 0; i < totalChunks; i++) {
      end = start + chunkSize;
      if (end > file.length) {
        end = file.length;
      }
      final chunk = file.sublist(start, end);
      uploads.add(
        HttpPlugin().sendFileFromMemory('POST', '/files/upload', chunk, {
          'bucket': 'avatars',
          'uploadId': initUpload.uploadId,
          'key': initUpload.key,
          'index': i.toString(),
        }),
      );
      start = end;
    }
    await Future.wait(uploads);
    await HttpPlugin().post('/files/completeUpload', {
      'uploadId': initUpload.uploadId,
      'key': initUpload.key,
      'fileName': 'avatar.png',
      'fileSize': file.length,
      'bucket': 'avatars',
    });
    return initUpload.key;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}
