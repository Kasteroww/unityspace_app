import 'package:unityspace/service/data_exceptions.dart';

class InitialUploadResponse {
  final String uploadId;
  final String key;

  const InitialUploadResponse({
    required this.uploadId,
    required this.key,
  });

  factory InitialUploadResponse.fromJson(Map<String, dynamic> map) {
    try {
      return InitialUploadResponse(
        uploadId: map['uploadId'] as String,
        key: map['key'] as String,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}
