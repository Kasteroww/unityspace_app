# Unity Space
Пространства теперь на Android, IOS, Desktop
## Ручная сборка проекта:
### Android:
1. Ввести команду для сборки: 
```bash
flutter build apk --release  
```

### macOS:

1. Ввести команду для сборки: 

```bash
flutter build macos
```

2. Перейти в папку dmg_creator:

```bash
cd installers/dmg_creator
```

3. Ввести команду для генерации dmg файла:

```bash
appdmg ./config.json ./unity_space.dmg
```

### Windows:

1. Ввести команду для сборки:
```bash
flutter build windows
```

2. Установить программу Inno Setup:
- (Ссылка для скачивания) https://jrsoftware.org/isdl.php
- (Видео туториал для работы с Inno Setup) https://www.youtube.com/watch?v=XvwX-hmYv0E&ab_channel=RetroPortalStudio

3. Запустить desktop_inno_script.iss по пути :
```
installers/exe_creator/desktop_inno_script.iss
```


## Правила написания кода

### Локализация
Каждый самостоятельно пишет локализацию для своих виджетов. 

Локализуются все строки, которые видит пользователь.

Вся локализация происходит внутри виджетов, в зоне доступа контекста. Исключение составляют некоторые enums, для их локализации пишется extension.

```dart
extension NotificationGroupLocalization on NotificationGroupType {
  String localize({required AppLocalizations localization}) {
    switch (this) {
      case NotificationGroupType.task:
        return localization.tasks;
      case NotificationGroupType.reglament:
        return localization.reglaments;
      case NotificationGroupType.space:
        return localization.spaces;
      case NotificationGroupType.achievement:
        return localization.achievements;
      case NotificationGroupType.other:
        return localization.other;
    }
  }
}
```

В сторах локализаций быть не должно.

### Стилистическое 

#### Параметры 
Рекомендуется отдавать предпочтение именованным параметрам, особенно в конструкторах. 
```dart
  String localize({required AppLocalizations localization}) {
    // ... body 
  }
```
Это обеспечивает лучшую читаемость кода и снижает вероятность неверной трактовки параметра. 

Исключением могут являться случаи когда параметр один и самоочевиден из названия функции:
```dart
  /// Поиск пользователя по id
  static OrganizationMember? findMemberById(
    // findById принимает id
    int id,
  ) {
    return UserStore().organizationMembersMap[id];
  }
```
```dart
// dateFromDateTime принимает DateTime date
DateTime dateFromDateTime(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
```


### models 

#### поле order
Если в модели есть поле `order`, его нужно конвертировать из `String` в `double` на уровне конструктора `fromResponse` при помощи метода  `convertFromOrderResponse`.

#### Создание собственных моделей 
В ситуациях, когда в веб версии метод возвращает анонимный объект рекомендуется создать для него модель
```ts
export async function searchTasks(
  searchText: string,
  page: number
): Promise<{
  tasks: Task[]
  tasksCount: number
  maxPagesCount: number
}> {
// ... logic
  return {
    tasks: responses.convertTaskResponseToTask(result.tasks),
    maxPagesCount: result.maxPagesCount,
    tasksCount: result.tasksCount
  }
}
```
```dart
class SearchTaskResponse {
  final List<TaskResponse> tasks;
  final int maxPagesCount;
  final int tasksCount;

  SearchTaskResponse({
    required this.tasks,
    required this.maxPagesCount,
    required this.tasksCount,
  });

  // ...methods
}
```
Использование рекордов (records) не рекомендуется из-за их плохой читаемости

#### fromJson
Фабрики `fromJson` должны иметь обработку ошибок парсинга. Все тело фабрики заворачивается в `try-catch`. В блоке `catch` выбрасывается `JsonParsingException` с `message` 'Error parsing Model', ошибкой `e` и стектрейсом `stack`
```dart
class NotificationResponse {
  // ...parameters

  NotificationResponse({
    // ...default constructor
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    try {
      // ... optionally calculating some values
      return NotificationResponse(
        // ... mapping values
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}
```


### services 

Каждая функция заворачивается в `try-catch`. Внутри `catch` проверяется, является ли ошибка `HttpPluginException`. Если нет - ошибка пробрасывается дальше. Если да, то выбрасывается `ServiceException` с `error.message`. 

Некоторые конкретные `HttpPluginException` обрабатываются особо. Для каждой из таких создается отдельный класс, наследующийся от `ServiceException`. Название классу дается в формате `<ServiceName> + <Description> + ServiceException`

`HttpPluginException` не должны обрабатываться нигде, кроме сервисов.

#### параметр order

Если при отправке запроса одним из передаваемых парамтров является `order`, его нужно конвертировать из `double` в `int` при помощи метода `convertToOrderRequest`. 

#### Примеры
<details>
<summary> </summary>

1. Обработка `HttpPluginException` 
```dart
Future<UserResponse> removeUserAvatar() async {
    // блок логики завернут в try-catch
  try {
    final response = await HttpPlugin().patch('/user/removeAvatar');
    final jsonData = json.decode(response.body);
    final result = UserResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    // проверка, является ли исключение исключением `HttpPlugin`
    if (e is HttpPluginException) {
        // выбрасывается `ServiceException` с сообщением ошибки
      throw ServiceException(e.message);
    }
    // если ошибка не имеет отношения к `HttpPlugin` - она пробрасывается дальше
    rethrow;
  }
}
```

2. Обработка отдельных ошибок 
```dart
Future<OrganizationResponse> getOrganizationData() async {
  try {
    final response = await HttpPlugin().get('/user/organization');
    final jsonData = json.decode(response.body);
    final result = OrganizationResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
        // в случае ошибки с кодом 401 `Unauthorized` выбрасывается исключение `UserUnauthorizedServiceException`
      if (e.statusCode == 401) {
        throw UserUnauthorizedServiceException();
      }
      // во всех остальных случаях как и раньше выбрасывается `ServiceException` в сообщением ошибки
      throw ServiceException(e.message);
    }
    rethrow;
  }
}
```

```dart
Future<OnlyTokensResponse> setUserPassword(
  final String oldPassword,
  final String newPassword,
) async {
  try {
    final response = await HttpPlugin().patch('/user/password', {
      'oldPassword': oldPassword,
      'password': newPassword,
    });
    final jsonData = json.decode(response.body);
    final result = OnlyTokensResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
        // если сообщение об ошибке содержит message "Credentials incorrect" выбрасывается `UserIncorrectOldPasswordServiceException`
      if (e.message == 'Credentials incorrect') {
        throw UserIncorrectOldPasswordServiceException();
      }
      throw ServiceException(e.message);
    }
    rethrow;
  }
}

```

3. Структура названия 
```dart
// из services/auth_service.dart
Future<RegisterResponse> register({
  required final String email,
  required final String password,
}) async {
  try {
    final response = await HttpPlugin().post('/auth/register', {
      'email': email,
      'password': password,
    });
    final jsonData = json.decode(response.body);
    final result = RegisterResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    if (e is HttpPluginException) {
      if (e.message == 'User is already exists') {
        // название сервиса + описание + ServiceException 
        // Auth + UserAlreadyExists + ServiceException
        throw AuthUserAlreadyExistsServiceException();
      }
      if (e.message == 'incorrect or non-exist Email') {
        // Auth + IncorrectEmail + ServiceException
        throw AuthIncorrectEmailServiceException();
      }
      if (e.statusCode == 500 && e.message.contains('554')) {
        // Auth + TooManyMessages + ServiceException
        throw AuthTooManyMessagesServiceException();
      }
      throw ServiceException(e.message);
    }
    rethrow;
  }
}
```

4. Обработка ошибок запроса в сторах 
```dart
// из services/auth_service.dart
Future<OnlyTokensResponse> refreshAccessToken({
  required final String refreshToken,
}) async {
  try {
    final response = await HttpPlugin().get('/auth/refresh', {
      'refreshToken': refreshToken,
    });
    final jsonData = json.decode(response.body);
    final result = OnlyTokensResponse.fromJson(jsonData);
    return result;
  } catch (e) {
    //обработка 401 'Unauthorized' происходит в сервисе
    if (e is HttpPluginException) {
      if (e.statusCode == 401) {
        throw AuthUnauthorizedServiceException();
      }
      throw ServiceException(e.message);
    }
    rethrow;
  }
}


// из store/auth_store.dart
  Future<bool> refreshUserToken() async {
    if (_refreshUserTokenCompleteEvent.isCompleted == false) {
      return await _refreshUserTokenCompleteEvent.future;
    }
    _refreshUserTokenCompleteEvent = Completer<bool>();
    final refreshToken = _currentTokens.refreshToken;
    if (refreshToken.isEmpty) {
      _refreshUserTokenCompleteEvent.complete(false);
      return false;
    }
    try {
      final tokens = await api.refreshAccessToken(refreshToken: refreshToken);
      await setUserTokens(tokens.accessToken, tokens.refreshToken);
      _refreshUserTokenCompleteEvent.complete(true);
      return true;
    } catch (e, __) {
        // проверка на авторизацию ожидает AuthUnauthorizedServiceException
      if (e is AuthUnauthorizedServiceException) {
        // токен протух - удялем - разлогин
        await removeUserTokens();
      }
      _refreshUserTokenCompleteEvent.complete(false);
      return false;
    }
  }
```
</details>