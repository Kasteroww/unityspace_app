import 'package:unityspace/service/data_exceptions.dart';

class NotificationEventResponse {
  final String event;
  final Map<String, dynamic> data;

  NotificationEventResponse({required this.event, required this.data});

  factory NotificationEventResponse.fromJson(Map<String, dynamic> map) {
    try {
      return NotificationEventResponse(
        event: map['event'] as String,
        data: map['data'] as Map<String, dynamic>,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class NotificationEvent {
  final String event;
  final Map<String, dynamic> data;

  NotificationEvent({required this.event, required this.data});

  factory NotificationEvent.fromResponse(
    final NotificationEventResponse responseData,
  ) {
    return NotificationEvent(
      event: responseData.event,
      data: responseData.data,
    );
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
