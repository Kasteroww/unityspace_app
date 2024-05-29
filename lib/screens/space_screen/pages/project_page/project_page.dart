import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/screens/dialogs/add_project_dialog.dart';
import 'package:unityspace/screens/space_screen/widgets/pop_up_projects_button.dart';
import 'package:unityspace/screens/widgets/columns_list/column_button.dart';
import 'package:unityspace/screens/widgets/columns_list/columns_list_row.dart';
import 'package:unityspace/screens/widgets/tabs_list/tab_button.dart';
import 'package:unityspace/store/project_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/constants.dart';
import 'package:unityspace/utils/errors.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

class ProjectsPageStore extends WStore {
  ProjectErrors error = ProjectErrors.none;
  WStoreStatus status = WStoreStatus.init;
  ProjectStore projectStore;
  bool isArchivedPage = false;
  int archiveProjectsCount = 0;
  int archiveColumnId = 0;

  late SpaceColumn selectedColumn;

  ProjectsPageStore({ProjectStore? projectStore})
      : projectStore = projectStore ?? ProjectStore();

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
    projectStore.changeProjectColumn(projectIds, archiveColumnId);
  }

  void deleteProject(int projectId) {
    projectStore.deleteProject(projectId);
  }

  bool checkRulesByDelete() {
    return (isOwner || isAdmin) ? true : false;
  }

  void selectFirstColumn(List<SpaceColumn> listColumns) {
    selectedColumn = listColumns.first;
  }

  Future<void> loadData(Space space) async {
    if (status == WStoreStatus.loading) return;
    setStore(() {
      status = WStoreStatus.loading;
      error = ProjectErrors.none;
    });
    try {
      await projectStore.getProjectsBySpaceId(space.id);
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

  List<Project> getProjectsByColumnId(int id) {
    final list = projects.where((el) => el.columnId == id).toList();
    return list;
  }

  int getArchiveColumnId(List<SpaceColumn> listColumns) {
    final setColumnsIds = listColumns.map((elem) => elem.id).toSet();
    final setProjectIds = projects.map((elem) => elem.columnId).toSet();
    setStore(() {
      archiveColumnId = setProjectIds.difference(setColumnsIds).first;
    });
    return archiveColumnId;
  }

  int getArchiveProjectsCount(List<SpaceColumn> listColumns) {
    setStore(() {
      archiveColumnId = getArchiveColumnId(listColumns);
      archiveProjectsCount = getProjectsByColumnId(archiveColumnId).length;
    });
    return archiveProjectsCount;
  }

  OrganizationMember? get owner => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.organizationOwner,
        keyName: 'owner',
      );

  bool get isOwner => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.isOrganizationOwner,
        keyName: 'isOwner',
      );

  bool get isAdmin => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.isAdmin,
        keyName: 'isAdmin',
      );

  List<Project> get projects => computedFromStore(
        store: projectStore,
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
    ..selectFirstColumn(space.columns);

  @override
  Widget build(BuildContext context, ProjectsPageStore store) {
    final localization = LocalizationHelper.getLocalizations(context);

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
            ConstantIcons.mainLoader,
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
            store.getArchiveProjectsCount(space.columns);
            final List<Project> listProjects = store.getProjectsByColumnId(
              store.isArchivedPage
                  ? store.archiveColumnId
                  : store.selectedColumn.id,
            );
            return Column(
              children: [
                if (store.isArchivedPage)
                  Container()
                else
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.04,
                      maxWidth: (Platform.isAndroid || Platform.isIOS)
                          ? MediaQuery.of(context).size.width * 0.95
                          : MediaQuery.of(context).size.width * 0.75,
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
                      right: MediaQuery.of(context).size.width * 0.1,
                    ),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.04,
                      maxWidth: (Platform.isAndroid || Platform.isIOS)
                          ? MediaQuery.of(context).size.width * 0.95
                          : MediaQuery.of(context).size.width * 0.75,
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
                          store.archiveProjectsCount,
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: (Platform.isAndroid || Platform.isIOS)
                              ? MediaQuery.of(context).size.width * 0.95
                              : MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  store.isArchivedPage
                                      ? localization.an_archive
                                      : store.selectedColumn.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.separated(
                                itemCount: listProjects.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return ListTile(
                                    title: Text(
                                      listProjects[index].name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    subtitle:
                                        listProjects[index].memo.isNotEmpty
                                            ? Text(
                                                listProjects[index].memo,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : null,
                                    trailing: PopUpProjectsButton(
                                      projectId: listProjects[index].id,
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const Divider(),
                              ),
                            ),
                            if (store.isArchivedPage)
                              Container()
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: TabButton(
                                        title: '+ ${localization.add_project}',
                                        selected: false,
                                        onPressed: () {
                                          showAddProjectDialog(
                                            context,
                                            store.selectedColumn.id,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
