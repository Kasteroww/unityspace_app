import 'package:flutter/material.dart';
import 'package:unityspace/utils/localization_helper.dart';

import 'package:wstore/wstore.dart';

class AddStageButtonStore extends WStore {
  bool isAddingStage = false;

  void startAddingStage() {
    setStore(() {
      isAddingStage = true;
    });
  }

  void stopAddingStage() {
    setStore(() {
      isAddingStage = false;
    });
  }

  @override
  AddStageButton get widget => super.widget as AddStageButton;
}

class AddStageButton extends WStoreWidget<AddStageButtonStore> {
  final void Function(String name) onSubmitted;
  const AddStageButton({
    required this.onSubmitted,
    super.key,
  });

  @override
  AddStageButtonStore createWStore() => AddStageButtonStore();

  @override
  Widget build(BuildContext context, AddStageButtonStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreBuilder(
      store: store,
      watch: (store) => [
        store.isAddingStage,
      ],
      builder: (context, store) {
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, right: 12),
            child: InkWell(
              onTap: store.startAddingStage,
              child: store.isAddingStage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 180,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: TextField(
                          autofocus: true,
                          onSubmitted: (value) {
                            onSubmitted(value);
                            store.stopAddingStage();
                          },
                        ),
                      ),
                    )
                  : Text('+ ${localization.add_column}'),
            ),
          ),
        );
      },
    );
  }
}
