import 'package:flutter/material.dart';
import 'package:wstore/wstore.dart';

class TasksPageStore extends WStore {
  @override
  TasksPage get widget => super.widget as TasksPage;
}

class TasksPage extends WStoreWidget<TasksPageStore> {
  const TasksPage({
    super.key,
  });

  @override
  TasksPageStore createWStore() => TasksPageStore();

  @override
  Widget build(BuildContext context, TasksPageStore store) {
    return Container();
  }
}
