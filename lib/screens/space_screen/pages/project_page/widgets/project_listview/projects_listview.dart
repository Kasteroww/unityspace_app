import 'package:flutter/material.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/project_page.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/widgets/dialogs/project_functions_dialog.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/widgets/project_info_top.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/widgets/project_listview/parts/project_card_info.dart';
import 'package:wstore/wstore.dart';

class ProjectsByColumnListView extends StatelessWidget {
  const ProjectsByColumnListView({super.key});

  @override
  Widget build(BuildContext context) {
    return WStoreBuilder(
      store: context.wstore<ProjectsPageStore>(),
      watch: (store) => [
        store.selectedColumn,
        store.projectsWithUsersByColumn,
      ],
      builder: (context, store) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Column(
              children: [
                // Вершина с именем проекта и кнопкой архива
                ProjectInfoTop(
                  archiveProjectsCount: store.archiveProjectsCount,
                  columnName: store.selectedColumn.name,
                  isInArchive: store.isArchivedPage,
                  onArchiveButtonTap: () => store.selectArchive(),
                ),
                // Расширяющаяся карточка со списком проектов
                Flexible(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 4,
                        left: 12,
                        right: 12,
                        bottom: 22,
                      ),
                      // Список проектов
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: store.projectsWithUsersByColumn.length,
                        itemBuilder: (BuildContext context, int index) {
                          final projectWithUsersOnline =
                              store.projectsWithUsersByColumn[index];
                          return InkWell(
                            key: ValueKey(projectWithUsersOnline.project.id),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/project',
                                arguments: {
                                  'projectId':
                                      projectWithUsersOnline.project.id,
                                },
                              );
                            },
                            onLongPress: () {
                              showProjectFunctionsDialog(
                                context: context,
                                project: projectWithUsersOnline.project,
                                isArchivedPage: store.isArchivedPage,
                                selectedColumn: store.selectedColumn,
                              );
                            },
                            child: ProjectCardInfo(
                              projectWithUsersOnline: projectWithUsersOnline,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
