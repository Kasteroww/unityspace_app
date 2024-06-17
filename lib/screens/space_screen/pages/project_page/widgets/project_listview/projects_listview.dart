import 'package:flutter/material.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/project_page.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/widgets/dialogs/project_functions_dialog.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/widgets/project_listview/parts/project_card_info.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class ProjectsByColumnListView extends StatelessWidget {
  const ProjectsByColumnListView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreBuilder(
      store: context.wstore<ProjectsPageStore>(),
      watch: (store) => [
        store.selectedColumn,
        store.projectsWithUsersByColumn,
      ],
      builder: (context, store) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.topCenter,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: CustomScrollView(
                  shrinkWrap: true,
                  slivers: [
                    // Вершина с именем проекта
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 12, right: 12, top: 24),
                        child: Text(
                          maxLines: 3,
                          store.isArchivedPage
                              ? localization.an_archive
                              : store.selectedColumn.name,
                          style: const TextStyle(
                            fontSize: 20,
                            color: ColorConstants.grey02,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // Расширяющаяся карточка со списком проектов
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 4,
                          left: 12,
                          right: 12,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
