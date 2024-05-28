import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/screens/space_screen/widgets/delete_no_rules_dialog.dart';
import 'package:unityspace/screens/space_screen/widgets/unarchive_project_dialog.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/project_page.dart';
import 'package:unityspace/screens/space_screen/widgets/pop_up_projects_item.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class PopUpProjectsButton extends StatelessWidget {
  const PopUpProjectsButton({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final store = context.wstore<ProjectsPageStore>();

    return PopupMenuButton<String>(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      child: SizedBox(
        height: 24,
        width: 24,
        child: SvgPicture.asset('assets/icons/settings.svg'),
      ),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          if (!store.isArchivedPage) ...[
            PopupMenuItem(
              onTap: () => showMoveProjectDialog(
                  context, store.selectedColumn, projectId),
              child: PopupProjectsItem(
                text: localization.move_project,
              ),
            ),
            PopupMenuItem(
              onTap: () =>
                  store.changeProjectColumn([projectId], store.archiveColumnId),
              child: PopupProjectsItem(
                text: localization.to_archive,
              ),
            ),
            PopupMenuItem(
              onTap: () => store.checkRulesByDelete()
                  ? store.deleteProject(projectId)
                  : showDeleteNoRulesDialog(context, store.owner),
              child: PopupProjectsItem(
                text: localization.delete_project,
                color: Colors.red,
              ),
            )
          ] else ...[
            PopupMenuItem(
              onTap: () {
                showMoveProjectDialog(context, store.selectedColumn, projectId);
              },
              child: PopupProjectsItem(
                text: localization.from_archive,
              ),
            ),
            PopupMenuItem(
              onTap: () => store.checkRulesByDelete()
                  ? store.deleteProject(projectId)
                  : showDeleteNoRulesDialog(context, store.owner),
              child: PopupProjectsItem(
                text: localization.delete_project,
                color: Colors.red,
              ),
            )
          ],
        ];
      },
    );
  }
}
