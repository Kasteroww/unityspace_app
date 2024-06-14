import 'package:flutter/material.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/models/task_models.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_input_field.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_with_buttons.dart';
import 'package:unityspace/screens/widgets/user_avatar_widget.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/task_detail_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

Future<void> showResponsibleDialog({
  required BuildContext context,
  required int spaceId,
  required int taskId,
  int? currentResponsibleId,
}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return ResponsibleDialog(
        spaceId: spaceId,
        taskId: taskId,
        currentResponsibleId: currentResponsibleId,
      );
    },
  );
}

class ResponsibleDialogStore extends WStore {
  String searchQuery = '';

  Task? get task => computedFromStore(
        store: TaskDetailStore(),
        getValue: (store) => store.task,
        keyName: 'task',
      );

  List<int>? get responsibleUsers => computed(
        getValue: () => task?.responsibleUsersId,
        watch: () => [task],
        keyName: 'responsibleUsers',
      );

  Spaces get spaces => computedFromStore(
        store: SpacesStore(),
        getValue: (store) => store.spaces,
        keyName: 'spaces',
      );

  Space? get space => computed(
        watch: () => [spaces],
        getValue: () => spaces[widget.spaceId],
        keyName: 'space',
      );

  List<SpaceMember> get spaceMembers => computed(
        watch: () => [space, responsibleUsers, searchQuery],
        getValue: () => _filteredSpaceMemberList(space?.members),
        keyName: 'spaceMembers',
      );

  void onChanged(String? value) {
    if (value == null || value.isEmpty) return;
    setStore(() {
      searchQuery = value;
    });
  }

  void addTaskResponsible({
    required int taskId,
    required int responsibleId,
  }) {
    TaskDetailStore().addTaskResponsible(
      taskId: taskId,
      responsibleId: responsibleId,
    );
  }

  void deleteTaskResponsible({
    required int taskId,
    required int responsibleId,
  }) {
    TaskDetailStore().deleteTaskResponsible(
      taskId: taskId,
      responsibleId: responsibleId,
    );
  }

  void updateTaskResponsible({
    required int taskId,
    required int currentResponsibleId,
    required int responsibleId,
  }) {
    TaskDetailStore().updateTaskResponsible(
      taskId: taskId,
      currentResponsibleId: currentResponsibleId,
      responsibleId: responsibleId,
    );
  }

  /// Возвращает список отфильтрованных участников пространства
  List<SpaceMember> _filteredSpaceMemberList(
    List<SpaceMember>? spaceMembers,
  ) {
    if (spaceMembers == null) return [];

    final filteredMembers = spaceMembers.where(
      (member) {
        final lowerCaseQuery = searchQuery.toLowerCase();
        return member.name.toLowerCase().contains(lowerCaseQuery) ||
            member.email.toLowerCase().contains(lowerCaseQuery);
      },
    ).toList();

    if (responsibleUsers != null) {
      return filteredMembers
          .where((element) => !responsibleUsers!.contains(element.id))
          .toList();
    }

    return filteredMembers;
  }

  @override
  ResponsibleDialog get widget => super.widget as ResponsibleDialog;
}

class ResponsibleDialog extends WStoreWidget<ResponsibleDialogStore> {
  const ResponsibleDialog({
    required this.taskId,
    required this.spaceId,
    this.currentResponsibleId,
    super.key,
  });

  final int taskId;
  final int spaceId;
  final int? currentResponsibleId;

  @override
  ResponsibleDialogStore createWStore() => ResponsibleDialogStore();

  @override
  Widget build(BuildContext context, ResponsibleDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreBuilder(
      store: store,
      watch: (store) => [
        store.task,
        store.responsibleUsers,
        store.spaceMembers,
      ],
      builder: (context, store) {
        return AppDialogWithButtons(
          title: localization.responsible,
          primaryButtonText: localization.add_member,
          secondaryButtonText:
              store.responsibleUsers!.isEmpty ? '' : localization.reset_member,
          onPrimaryButtonPressed: () {},
          onSecondaryButtonPressed: () {
            if (currentResponsibleId != null) {
              store.deleteTaskResponsible(
                taskId: taskId,
                responsibleId: currentResponsibleId!,
              );
            }
            Navigator.of(context).pop();
          },
          children: [
            AddDialogInputField(
              labelText: localization.responsible,
              onChanged: store.onChanged,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: store.spaceMembers.length,
                itemBuilder: (BuildContext context, int index) {
                  final element = store.spaceMembers[index];
                  return InkWell(
                    key: ValueKey(element.id),
                    onTap: () {
                      if (currentResponsibleId != null) {
                        store.updateTaskResponsible(
                          taskId: taskId,
                          currentResponsibleId: currentResponsibleId!,
                          responsibleId: element.id,
                        );
                      } else {
                        store.addTaskResponsible(
                          taskId: taskId,
                          responsibleId: element.id,
                        );
                      }

                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          UserAvatarWidget(
                            id: element.id,
                            width: 36,
                            height: 36,
                            fontSize: 18,
                          ),
                          const SizedBox(width: 15),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  element.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  element.email,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
