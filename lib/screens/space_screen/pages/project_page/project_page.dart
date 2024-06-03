import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/widgets/projects_listview.dart';
import 'package:unityspace/screens/space_screen/widgets/delete_no_rules_dialog.dart';
import 'package:unityspace/screens/widgets/columns_list/column_button.dart';
import 'package:unityspace/screens/widgets/columns_list/columns_list_row.dart';
import 'package:unityspace/store/projects_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

class ProjectsPageStore extends WStore {
  ProjectErrors error = ProjectErrors.none;
  WStoreStatus status = WStoreStatus.init;
  bool isArchivedPage = false;
  late int archiveColumnId;
  late SpaceColumn selectedColumn;

  void selectColumn(final SpaceColumn column) {
    setStore(() {
      selectedColumn = column;
    });
  }

  void selectArchive() {
    setStore(() {
      isArchivedPage = !isArchivedPage;
    });
  }

  void changeProjectColumn(List<int> projectIds, int archiveColumnId) {
    ProjectsStore().changeProjectColumn(projectIds, archiveColumnId);
  }

  void tryToDeleteProject({
    required BuildContext context,
    required int projectId,
  }) {
    if (_checkRulesByDelete()) {
      _deleteProject(projectId);
    } else {
      showDeleteNoRulesDialog(context);
    }
  }

  void _deleteProject(int projectId) {
    ProjectsStore().deleteProject(projectId);
  }

  bool _checkRulesByDelete() {
    final isOwner = UserStore().isOrganizationOwner;
    final isAdmin = UserStore().isAdmin;
    return isOwner || isAdmin;
  }

  void initData(Space space) {
    selectedColumn = space.columns.first;
    archiveColumnId = space.archiveColumnId;
  }

  Future<void> loadData(Space space) async {
    if (status == WStoreStatus.loading) return;
    setStore(() {
      status = WStoreStatus.loading;
      error = ProjectErrors.none;
    });
    try {
      await ProjectsStore().getProjectsBySpaceId(space.id);
      setStore(() {
        status = WStoreStatus.loaded;
      });
    } catch (e, stack) {
      logger.d('on ProjectsPage'
          'ProjectsStore loadData error=$e\nstack=$stack');
      setStore(() {
        status = WStoreStatus.error;
        error = ProjectErrors.loadingDataError;
      });
    }
  }

  List<Project> _getProjectsByColumnId(int id) {
    return projects.where((el) => el.columnId == id).toList();
  }

  void setProjectFavorite(int projectId, bool favorite) {
    ProjectsStore().setProjectFavorite(projectId, favorite);
  }

  List<Project> get projectsByColumn => computed(
        getValue: () => _getProjectsByColumnId(
          isArchivedPage ? archiveColumnId : selectedColumn.id,
        ),
        watch: () => [projects, selectedColumn, isArchivedPage],
        keyName: 'projectsByColumn',
      );

  int get archiveProjectsCount => computed(
        getValue: () => _getProjectsByColumnId(archiveColumnId).length,
        watch: () => [projects],
        keyName: 'archiveProjectsCount',
      );

  List<Project> get projects => computedFromStore(
        store: ProjectsStore(),
        getValue: (store) => store.projects,
        keyName: 'projects',
      );

  @override
  ProjectsPage get widget => super.widget as ProjectsPage;
}

class ProjectsPage extends WStoreWidget<ProjectsPageStore> {
  final Space space;

  const ProjectsPage({
    required this.space,
    super.key,
  });

  @override
  ProjectsPageStore createWStore() => ProjectsPageStore()
    ..loadData(space)
    ..initData(space);

  @override
  Widget build(BuildContext context, ProjectsPageStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.status,
      builderError: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Text(
            switch (store.error) {
              ProjectErrors.none => '',
              ProjectErrors.loadingDataError =>
                localization.problem_uploading_data_try_again
            },
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF111012).withOpacity(0.8),
              fontSize: 20,
              height: 1.2,
            ),
          ),
        );
      },
      builderLoading: (context) {
        return Center(
          child: Lottie.asset(
            AppIcons.mainLoader,
            width: 200,
            height: 200,
          ),
        );
      },
      builder: (context, _) {
        return const SizedBox.shrink();
      },
      builderLoaded: (BuildContext context) {
        return WStoreBuilder<ProjectsPageStore>(
          watch: (store) =>
              [store.projects, store.selectedColumn, store.isArchivedPage],
          store: context.wstore(),
          builder: (context, store) {
            return Column(
              children: [
                if (store.isArchivedPage)
                  Container()
                else
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    constraints: BoxConstraints(
                      maxHeight: height * 0.04,
                      maxWidth: (Platform.isAndroid || Platform.isIOS)
                          ? width * 0.95
                          : width * 0.75,
                    ),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ColumnsListRow(
                          children: [
                            ...space.columns.map(
                              (column) => ColumnButton(
                                title: column.name,
                                onPressed: () {
                                  store.selectColumn(column);
                                },
                                selected: column == store.selectedColumn,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 10,
                      right: width * 0.1,
                    ),
                    constraints: BoxConstraints(
                      maxHeight: height * 0.04,
                      maxWidth: (Platform.isAndroid || Platform.isIOS)
                          ? width * 0.95
                          : width * 0.75,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        elevation: 0,
                      ),
                      onPressed: () {
                        store.selectArchive();
                      },
                      child: WStoreBuilder<ProjectsPageStore>(
                        watch: (store) => [
                          store.projects,
                        ],
                        store: context.wstore(),
                        builder: (context, store) {
                          return Text(
                            store.isArchivedPage
                                ? localization.exit_from_archive
                                : '${localization.projects_in_archive} ${store.archiveProjectsCount}',
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const ProjectsListview(),
              ],
            );
          },
        );
      },
    );
  }
}
