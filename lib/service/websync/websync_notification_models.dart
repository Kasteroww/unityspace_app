import 'package:unityspace/service/exceptions/data_exceptions.dart';

class NotificationEventResponse {
  final String event;
  final dynamic data;

  NotificationEventResponse({required this.event, required this.data});

  factory NotificationEventResponse.fromJson(Map<String, dynamic> map) {
    try {
      return NotificationEventResponse(
        event: map['event'] as String,
        data: map['data'] as dynamic,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class NotificationReadUnreadResponse {
  final int id;
  final bool status;

  NotificationReadUnreadResponse({required this.id, required this.status});

  factory NotificationReadUnreadResponse.fromJson(Map<String, dynamic> map) {
    try {
      return NotificationReadUnreadResponse(
        id: map['id'] as int,
        status: map['status'] as bool,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class NotificationReadUnread {
  final int id;
  final bool status;

  NotificationReadUnread({required this.id, required this.status});

  factory NotificationReadUnread.fromResponse(
    final NotificationReadUnreadResponse data,
  ) {
    return NotificationReadUnread(
      id: data.id,
      status: data.status,
    );
  }
}
