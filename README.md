[![Codemagic build status](https://api.codemagic.io/apps/667049ceac2945fd7b7162e3/667049ceac2945fd7b7162e2/status_badge.svg)](https://codemagic.io/app/667049ceac2945fd7b7162e3/667049ceac2945fd7b7162e2/latest_build)
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

## Настройка рабочего окружения 

### Версии flutter и dart

Текущая версия, которая должня быть установлена - flutter 3.22.2, dart 3.4.3, devtools 2.34.3. Смена версий производится у всех одновременно, по согласованию. 

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

#### обработка ошибок

Тело каждой функции, обращающейся к серверу, заворачивается в `try-catch`. 

Если функция использует `HttpPlugin`, то внутри `catch` проверяется, является ли ошибка `HttpPluginException`. Если нет - ошибка пробрасывается дальше. Если ошибка - это `HttpPluginException`, то сначала обрабатываются ошибки, специфичные для этой функции. Для каждой из таких создается отдельный класс, наследующийся от `HttpException`. Название классу дается в формате `<ServiceName> + <Description> + HttpException`. После них вызывается `handleDefaultHttpExceptions(e)`, обарабатывающая исключения, общие для всех сервисов. 

Если функция использует `SocketPlugin`, то выбрасываются ошибки `SocketIoException`. 

Для обработки случаев, когда `HttpPlugin` не выбросил ошибку, но результат запроса не соответствует ожидаемому (например, если у респонса пустое тело когда ожидались данные), используются `ServiceException`. 

`HttpPluginException` не должны обрабатываться нигде, кроме сервисов.



##### Примеры
<details>
<summary> </summary>

1. Обработка `HttpPluginException` 
```dart
Future<void> signOut({
  required final String refreshToken,
  required final int globalUserId,
}) async {
  try {
    // body
  } catch (e) {
    if (e is HttpPluginException) {
      handleDefaultHttpExceptions(e);
    }
    rethrow;
  }
}
```

2. Обработка специфичных для запроса ошибок 
```dart
Future<OnlyTokensResponse> login({
  required final String email,
  required final String password,
}) async {
  try {
    // body
  } catch (e) {
    if (e is HttpPluginException) {
      if (e.message == 'Credentials incorrect') {
        throw AuthIncorrectCredentialsHttpException(e.message);
      }
      handleDefaultHttpExceptions(e);
    }
    rethrow;
  }
}
```

3. Обработка ошибок в функциях, использующих `SocketPlugin`
```dart
void disconnect() {
  try {
    SocketPlugin().socket.disconnect();
  } on Exception catch (e) {
    throw WebsyncDisconnectSocketIoException(exception: e);
  }
}
```

4. Использование `ServiceException`
```dart
Future<TaskResponse> moveTask({
  // params
}) async {
  try {
    // body
    final task = result['task'];
    if (task == null) {
      throw EmptyResponseServiceException(
        message: '''
                  Failed to move task between stages. 
                  Expected JSON response with task details, 
                  but received an empty response.
                  ''',
        response: response,
      );
    }
    return TaskResponse.fromJson(task);
  } catch (e) {
    // HttpPlugin handling
  }
}
```
</details>

#### параметр order

Если при отправке запроса одним из передаваемых парамтров является `order`, его нужно конвертировать из `double` в `int` при помощи метода `convertToOrderRequest`. 
