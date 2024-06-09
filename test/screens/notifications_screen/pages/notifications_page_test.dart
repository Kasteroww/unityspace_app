import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/screens/notifications_screen/pages/notifications_page.dart';
import 'package:unityspace/store/notifications_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/http_plugin.dart';
import 'package:wstore/wstore.dart';

class MockNotificationsStore extends Mock implements NotificationsStore {}

class MockUserStore extends Mock implements UserStore {}

void main() {
  late NotificationPageStore notificationPageStore;
  late MockNotificationsStore mockNotificationsStore;
  late MockUserStore mockUserStore;

  setUp(() {
    mockNotificationsStore = MockNotificationsStore();
    mockUserStore = MockUserStore();
    notificationPageStore = NotificationPageStore(
      notificationsStore: mockNotificationsStore,
      userStore: mockUserStore,
    );
  });

  test('initial values are correct', () {
    expect(notificationPageStore.error, NotificationErrors.none);
    expect(notificationPageStore.status, WStoreStatus.init);
    expect(notificationPageStore.maxPageCount, 1);
  });

  group('getNotifications', () {
    test('getNotificationsData called 1 time', () {
      // arange
      when(() => mockNotificationsStore.getNotificationsData(page: 1))
          .thenAnswer((invocation) async => 1);
      //act
      notificationPageStore.loadData();
      //assert
      verify(() => mockNotificationsStore.getNotificationsData(page: 1))
          .called(1);
    });
  });

  test('notifications loaded correctly', () async {
    // arange
    when(() => mockNotificationsStore.getNotificationsData(page: 1))
        .thenAnswer((invocation) async => 1);
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
