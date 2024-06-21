import 'package:unityspace/service/exceptions/data_exceptions.dart';

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

class FileUploadResponse {
  final int id;
  final String fileName;
  final String link;
  final int size;
  final String createdAt;
  final String updatedAt;

  FileUploadResponse({
    required this.id,
    required this.fileName,
    required this.link,
    required this.size,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    try {
      return FileUploadResponse(
        id: json['id'] as int,
        fileName: json['fileName'] as String,
        link: json['link'] as String,
        size: json['size'] as int,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}
