import 'package:flutter/material.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/project_page.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/widgets/dialogs/project_functions_dialog.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/widgets/project_info_top.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/widgets/project_listview/parts/project_card_info.dart';
import 'package:wstore/wstore.dart';

class ProjectsListview extends StatelessWidget {
  const ProjectsListview({super.key});

  @override
  Widget build(BuildContext context) {
    return WStoreBuilder(
      store: context.wstore<ProjectsPageStore>(),
      watch: (store) => [
        store.selectedColumn,
        store.projectsByColumn,
      ],
      builder: (context, store) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Column(
              children: [
                ProjectInfoTop(
                  archiveProjectsCount: store.archiveProjectsCount,
                  columnName: store.selectedColumn.name,
                  isInArchive: store.isArchivedPage,
                  onArchiveButtonTap: () => store.selectArchive(),
                ),
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
                        left: 12,
                        right: 12,
                        bottom: 22,
                        top: 20,
                      ),
                      child: ListView.separated(
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(
                          height: 16,
                        ),
                        shrinkWrap: true,
                        itemCount: store.projectsByColumn.length,
                        itemBuilder: (BuildContext context, int index) {
                          final project = store.projectsByColumn[index];
                          return InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/project',
                                arguments: {
                                  'projectId': store.projectsByColumn[index].id,
                                },
                              );
                            },
                            onLongPress: () {
                              showProjectFunctionsDialog(
                                context: context,
                                project: project,
                                isArchivedPage: store.isArchivedPage,
                                selectedColumn: store.selectedColumn,
                              );
                            },
                            child: ProjectCardInfo(
                              key: ValueKey(project.id),
                              project: project,
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
