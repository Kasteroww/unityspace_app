import 'dart:convert';

import 'package:unityspace/models/notification_models.dart';
import 'package:unityspace/service/service_exceptions.dart';
import 'package:unityspace/utils/http_plugin.dart';

Future<PaginatedNotifications> getNotificationsOnPage({
  required int page,
}) async {
  try {
    final response = await HttpPlugin().get('/notifications/$page');
    final jsonData = json.decode(response.body);
    final result = PaginatedNotifications.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<PaginatedNotifications> getArchivedNotificationsOnPage({
  required int page,
}) async {
  try {
    final response = await HttpPlugin().get('/notifications/archived/$page');
    final jsonData = json.decode(response.body);
    final result = PaginatedNotifications.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<List<NotificationResponse>> readNotification({
  required List<int> notificationIds,
  required bool status,
}) async {
  try {
    final response = await HttpPlugin().patch(
      '/notifications/read-many',
      {'notificationIds': notificationIds, 'unread': status},
    );
    final List jsonData = json.decode(response.body);
    return jsonData
        .map((element) => NotificationResponse.fromJson(element))
        .toList();
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<List<NotificationResponse>> archiveNotification({
  required List<int> notificationIds,
  required bool isArchived,
}) async {
  try {
    final response = await HttpPlugin().patch(
      '/notifications/archive-many',
      {'notificationIds': notificationIds, 'archived': isArchived},
    );
    final List jsonData = json.decode(response.body);
    return jsonData
        .map((element) => NotificationResponse.fromJson(element))
        .toList();
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<List<NotificationResponse>> unarchiveNotification({
  required int notificationId,
  required bool archived,
}) async {
  try {
    final response = await HttpPlugin().patch(
      '/notifications/$notificationId/unarchive',
    );
    final List jsonData = json.decode(response.body);
    return jsonData
        .map((element) => NotificationResponse.fromJson(element))
        .toList();
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<List<NotificationResponse>> readAllNotifications() async {
  try {
    final response = await HttpPlugin().patch(
      '/notifications/read',
    );
    final List jsonData = json.decode(response.body);
    return jsonData
        .map((element) => NotificationResponse.fromJson(element))
        .toList();
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<List<NotificationResponse>> archiveAllNotifications() async {
  final response = await HttpPlugin().patch(
    '/notifications/archive',
  );
  try {
    final List jsonData = json.decode(response.body);
    return jsonData
        .map((element) => NotificationResponse.fromJson(element))
        .toList();
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<DeleteNotificationsResponse> deleteAllNotifications() async {
  try {
    final response = await HttpPlugin().patch(
      '/notifications/delete',
    );
    final jsonData = json.decode(response.body);
    return DeleteNotificationsResponse.fromJson(jsonData);
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

Future<DeleteNotificationsResponse> deleteNotification({
  required List<int> notificationIds,
}) async {
  try {
    final response = await HttpPlugin().delete('notifications/delete-many', {
      'notificationIds': notificationIds,
    });
    final jsonData = json.decode(response.body);
    return DeleteNotificationsResponse.fromJson(jsonData);
  } catch (e) {
    if (e is HttpPluginException) {
      throw ServiceException(e.message);
    }
    rethrow;
  }
}
