import 'package:flutter/material.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class AddTaskButtonStore extends WStore {
  bool isAddingTask = false;

  void startAddingTask() {
    setStore(() {
      isAddingTask = true;
    });
  }

  void stopAddingTask() {
    setStore(() {
      isAddingTask = false;
    });
  }

  @override
  AddTaskButton get widget => super.widget as AddTaskButton;
}

class AddTaskButton extends WStoreWidget<AddTaskButtonStore> {
  final void Function(String name) onSubmitted;
  const AddTaskButton({
    required this.onSubmitted,
    super.key,
  });

  @override
  AddTaskButtonStore createWStore() => AddTaskButtonStore();

  @override
  Widget build(BuildContext context, AddTaskButtonStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreBuilder(
      store: store,
      watch: (store) => [
        store.isAddingTask,
      ],
      builder: (context, store) {
        return InkWell(
          onTap: store.startAddingTask,
          child: ColoredBox(
            color: Colors.blue,
            child: Center(
              child: store.isAddingTask
                  ? TextField(
                      autofocus: true,
                      onSubmitted: (value) {
                        onSubmitted(value);
                        store.stopAddingTask();
                      },
                    )
                  : Text('+ ${localization.add_task}'),
            ),
          ),
        );
      },
    );
  }
}
