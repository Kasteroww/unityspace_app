import 'package:wstore/wstore.dart';

class TaskMessagesStore extends GStore {
  static TaskMessagesStore? _instance;

  factory TaskMessagesStore() => _instance ??= TaskMessagesStore._();

  TaskMessagesStore._();

  void empty() {
    setStore(() {});
  }
}
