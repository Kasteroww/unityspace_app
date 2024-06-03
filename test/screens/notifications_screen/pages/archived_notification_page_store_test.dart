import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/screens/notifications_screen/pages/archived_notifications_page.dart';
import 'package:unityspace/store/notifications_store.dart';
import 'package:unityspace/utils/http_plugin.dart';
import 'package:wstore/wstore.dart';

class MockNotificationsStore extends Mock implements NotificationsStore {}

void main() {
  late ArchivedNotificationPageStore notificationPageStore;
  late MockNotificationsStore mockNotificationsStore;

  setUp(() {
    mockNotificationsStore = MockNotificationsStore();
    notificationPageStore = ArchivedNotificationPageStore(
      notificationsStore: mockNotificationsStore,
    );
  });

  test('initial values are correct', () {
    expect(notificationPageStore.isArchived, true);
    expect(notificationPageStore.error, NotificationErrors.none);
    expect(notificationPageStore.status, WStoreStatus.init);
    expect(notificationPageStore.maxPageCount, 1);
  });

  group('getNotifications', () {
    test('getNotificationsData called 1 time', () {
      // arange
      when(
        () => mockNotificationsStore.getNotificationsData(
          page: 1,
          isArchived: notificationPageStore.isArchived,
        ),
      ).thenAnswer((invocation) async => 1);
      //act
      notificationPageStore.loadData();
      //assert
      verify(
        () => mockNotificationsStore.getNotificationsData(
          page: 1,
          isArchived: true,
        ),
      ).called(1);
    });
  });

  test('notifications loaded correctly', () async {
    // arange
    when(
      () => mockNotificationsStore.getNotificationsData(
        page: 1,
        isArchived: notificationPageStore.isArchived,
      ),
    ).thenAnswer((invocation) async => 1);
    //act
    await notificationPageStore.loadData();
    //assert
    expect(notificationPageStore.maxPageCount, 1);
    expect(notificationPageStore.error, NotificationErrors.none);
    expect(notificationPageStore.status, WStoreStatus.loaded);
  });

  test('сorrect error messages', () {
    // arange
    when(() => mockNotificationsStore.getNotificationsData(page: 1)).thenThrow(
      const HttpPluginException(
        -1,
        "Failed host lookup: 'server.unityspace.ru'",
        'ClientException',
      ),
    );
    //act
    notificationPageStore.loadData();
    //assert
    expect(notificationPageStore.error, NotificationErrors.loadingDataError);
    expect(notificationPageStore.status, WStoreStatus.error);
  });
}
