import 'package:unityspace/models/files_models.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/service/exceptions/data_exceptions.dart';

class EditMessageResponse {
  final int deleted;
  final List<FileUploadResponse> files;
  final int id;
  final int senderId;
  final int taskId;
  final String text;
  final String createdAt;
  final String updatedAt;
  final int? messageReplyId;

  EditMessageResponse({
    required this.deleted,
    required this.files,
    required this.id,
    required this.senderId,
    required this.taskId,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    required this.messageReplyId,
  });

  factory EditMessageResponse.fromJson(Map<String, dynamic> json) {
    try {
      return EditMessageResponse(
        deleted: json['deleted'] as int,
        files: (json['files'] as List<dynamic>)
            .map((e) => FileUploadResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
        id: json['id'] as int,
        senderId: json['senderId'] as int,
        taskId: json['taskId'] as int,
        text: json['text'] as String,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
        messageReplyId: json['messageReplyId'] as int?,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class FileTypeResponse {
  final int id;
  final int size;
  final String createdAt;
  final String fileName;
  final String link;

  FileTypeResponse({
    required this.id,
    required this.size,
    required this.createdAt,
    required this.fileName,
    required this.link,
  });

  factory FileTypeResponse.fromJson(Map<String, dynamic> json) {
    try {
      return FileTypeResponse(
        id: json['id'] as int,
        size: json['size'] as int,
        createdAt: json['createdAt'] as String,
        fileName: json['fileName'] as String,
        link: json['link'] as String,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class MessageResponse {
  final String createdAt;
  final int deleted;
  final int id;
  final int senderId;
  final int taskId;
  final String text;
  final String updatedAt;
  final List<FileTypeResponse> files;
  final int? messageReplyId;

  MessageResponse({
    required this.createdAt,
    required this.deleted,
    required this.id,
    required this.senderId,
    required this.taskId,
    required this.text,
    required this.updatedAt,
    required this.files,
    required this.messageReplyId,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    try {
      return MessageResponse(
        createdAt: json['createdAt'] as String,
        deleted: json['deleted'] as int,
        id: json['id'] as int,
        senderId: json['senderId'] as int,
        taskId: json['taskId'] as int,
        text: json['text'] as String,
        updatedAt: json['updatedAt'] as String,
        files: (json['files'] as List<dynamic>)
            .map((e) => FileTypeResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
        messageReplyId: json['messageReplyId'] as int?,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class SendMessageResponse {
  final MessageResponse message;
  final TaskHistoryResponse history;

  SendMessageResponse({
    required this.message,
    required this.history,
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    try {
      return SendMessageResponse(
        message:
            MessageResponse.fromJson(json['message'] as Map<String, dynamic>),
        history: TaskHistoryResponse.fromJson(
          json['history'] as Map<String, dynamic>,
        ),
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class OneFileUploadResponse {
  final int id;
  final String fileName;
  final String link;
  final int size;
  final String createdAt;
  final String updatedAt;

  OneFileUploadResponse({
    required this.id,
    required this.fileName,
    required this.link,
    required this.size,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OneFileUploadResponse.fromJson(Map<String, dynamic> json) {
    try {
      return OneFileUploadResponse(
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
