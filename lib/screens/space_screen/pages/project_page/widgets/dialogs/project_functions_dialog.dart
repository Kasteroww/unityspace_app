import 'package:flutter/material.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/widgets/dialogs/move_project_dialog.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/widgets/dialogs/project_properties_dialog.dart';
import 'package:unityspace/screens/space_screen/widgets/delete_no_rules_dialog.dart';
import 'package:unityspace/store/projects_store.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

Future<void> showProjectFunctionsDialog({
  required BuildContext context,
  required Project project,
  required bool isArchivedPage,
  required SpaceColumn selectedColumn,
}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return ProjectFunctionsDialog(
        project: project,
        isArchivedPage: isArchivedPage,
        selectedColumn: selectedColumn,
      );
    },
  );
}

class ProjectFunctionsDialogStore extends WStore {
  SpaceColumn get selectedColumn => widget.selectedColumn;
  bool get isArchivedPage => widget.isArchivedPage;
  int? get archiveColumnId => currentSpace?.archiveColumnId;

  ///Получение конкретного пространства по id
  Space? get currentSpace => computedFromStore(
        store: SpacesStore(),
        getValue: (store) => store.spaces[selectedColumn.spaceId],
        keyName: 'currentSpace',
      );

  ///Смена колонки проекта
  void changeProjectColumn(List<int> projectIds, int? archiveColumnId) {
    if (archiveColumnId != null) {
      ProjectsStore().changeProjectColumn(projectIds, archiveColumnId);
    }
  }

  // Попытка удаления проекта с проверкой условия
  void tryToDeleteProject({
    required BuildContext context,
    required int projectId,
  }) {
    if (isOwnerOrAdmin) {
      _deleteProject(projectId);
    } else {
      showDeleteNoRulesDialog(context);
    }
  }

  void _deleteProject(int projectId) {
    ProjectsStore().deleteProject(projectId);
  }

  bool get isOwnerOrAdmin => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.isOwnerOrAdmin,
        keyName: 'isOwnerOrAdmin',
      );

  void setProjectFavorite(int projectId, bool favorite) {
    ProjectsStore().setProjectFavorite(projectId, favorite);
  }

  @override
  ProjectFunctionsDialog get widget => super.widget as ProjectFunctionsDialog;
}

class ProjectFunctionsDialog extends WStoreWidget<ProjectFunctionsDialogStore> {
  const ProjectFunctionsDialog({
    required this.project,
    required this.isArchivedPage,
    required this.selectedColumn,
    super.key,
  });

  final Project project;
  final bool isArchivedPage;
  final SpaceColumn selectedColumn;
  @override
  ProjectFunctionsDialogStore createWStore() => ProjectFunctionsDialogStore();

  @override
  Widget build(BuildContext context, ProjectFunctionsDialogStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      title: Text(
        project.name,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          height: 20 / 16,
          color: ColorConstants.grey01,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                store.setProjectFavorite(project.id, !project.favorite);
                Navigator.pop(context);
              },
              child: ProjectDialogItem(
                text: project.favorite
                    ? localization.from_favorite
                    : localization.to_favorite,
              ),
            ),
            if (!store.isArchivedPage) ...[
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  showProjectPropertiesDialog(context, project);
                },
                child: ProjectDialogItem(
                  text: localization.project_properties,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  showMoveProjectDialog(
                    context,
                    store.selectedColumn,
                    project.id,
                  );
                },
                child: ProjectDialogItem(
                  text: localization.move_project,
                ),
              ),
              InkWell(
                onTap: () {
                  store
                      .changeProjectColumn([project.id], store.archiveColumnId);
                  Navigator.pop(context);
                },
                child: ProjectDialogItem(
                  text: localization.to_archive,
                ),
              ),
              InkWell(
                onTap: () {
                  store.tryToDeleteProject(
                    context: context,
                    projectId: project.id,
                  );
                  Navigator.pop(context);
                },
                child: ProjectDialogItem(
                  text: localization.delete_project,
                  color: Colors.red,
                ),
              ),
            ] else ...[
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  showMoveProjectDialog(
                    context,
                    store.selectedColumn,
                    project.id,
                  );
                },
                child: ProjectDialogItem(
                  text: localization.from_archive,
                ),
              ),
              InkWell(
                onTap: () {
                  store.tryToDeleteProject(
                    context: context,
                    projectId: project.id,
                  );
                  Navigator.pop(context);
                },
                child: ProjectDialogItem(
                  text: localization.delete_project,
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ProjectDialogItem extends StatelessWidget {
  const ProjectDialogItem({
    required this.text,
    super.key,
    this.color = ColorConstants.grey03,
  });

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 16.41 / 14,
          color: color,
        ),
      ),
    );
  }
}
