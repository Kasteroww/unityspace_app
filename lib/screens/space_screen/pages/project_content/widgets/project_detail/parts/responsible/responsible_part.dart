import 'package:flutter/material.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/project_action_tile.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/parts/responsible/dialogs/responsible_dialog.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/project_detail.dart';
import 'package:unityspace/screens/widgets/user_avatar_widget.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class ResponsiblePart extends StatelessWidget {
  const ResponsiblePart({
    required this.spaceId,
    required this.taskId,
    super.key,
  });

  final int? spaceId;
  final int? taskId;

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final store = context.wstore<ProjectDetailStore>();
    return ProjectActionTile(
      label: localization.responsible,
      trailing: store.responsibleUsers.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: store.responsibleUsers.map(
                    (element) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: InkWell(
                          key: ValueKey(element),
                          onTap: () => showResponsibleDialog(
                            context: context,
                            spaceId: spaceId,
                            taskId: taskId,
                            currentResponsibleId: element,
                          ),
                          child: Row(
                            children: [
                              UserAvatarWidget(
                                id: element,
                                width: 24,
                                height: 24,
                                fontSize: 15,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                store.responsibleUsers.isNotEmpty
                                    ? store.spaceMembers
                                        .firstWhere((el) => el.id == element)
                                        .name
                                    : '-',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
                InkWell(
                  onTap: () => showResponsibleDialog(
                    context: context,
                    spaceId: spaceId,
                    taskId: taskId,
                  ),
                  child: Text(
                    localization.add_member,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            )
          : const Row(
              children: [
                Icon(Icons.photo_outlined),
                Text(
                  '-',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
      onTap: () => showResponsibleDialog(
        context: context,
        spaceId: spaceId,
        taskId: taskId,
        currentResponsibleId: store.responsibleUsers.isNotEmpty
            ? store.responsibleUsers.first
            : null,
      ),
    );
  }
}
