import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/screens/widgets/columns_list/column_button.dart';
import 'package:unityspace/screens/widgets/columns_list/columns_list_row.dart';
import 'package:unityspace/store/project_store.dart';
import 'package:unityspace/utils/constants.dart';
import 'package:unityspace/utils/errors.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

class ProjectsPageStore extends WStore {
  ProjectErrors error = ProjectErrors.none;
  WStoreStatus status = WStoreStatus.init;
  ProjectStore projectStore;
  late SpaceColumn selectedColumn;

  ProjectsPageStore({ProjectStore? projectStore})
      : projectStore = projectStore ?? ProjectStore();

  void selectColumn(final SpaceColumn column) {
    setStore(() {
      selectedColumn = column;
    });
  }

  Future<void> loadData(int spaceId, List<SpaceColumn> listColumns) async {
    if (status == WStoreStatus.loading) return;
    setStore(() {
      status = WStoreStatus.loading;
      error = ProjectErrors.none;
    });
    try {
      await projectStore.getProjectsData(spaceId);
      setStore(() {
        selectedColumn = listColumns.first;
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

  getProjects(int id) {
    return projectStore.projects
        .where((el) => el.columnId == selectedColumn.id)
        .toList();
  }

  List<Project> get projects => computedFromStore(
        store: projectStore,
        getValue: (store) => store.projects,
        keyName: 'projects',
      );

  @override
  ProjectsPage get widget => super.widget as ProjectsPage;
}

class ProjectsPage extends WStoreWidget<ProjectsPageStore> {
  final int spaceId;
  final List<SpaceColumn> listColumns;

  const ProjectsPage({
    super.key,
    required this.spaceId,
    required this.listColumns,
  });

  @override
  ProjectsPageStore createWStore() =>
      ProjectsPageStore()..loadData(spaceId, listColumns);

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
              ProjectErrors.none => "",
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
          watch: (store) => [store.selectedColumn],
          store: context.wstore<ProjectsPageStore>(),
          builder: (context, store) {
            final listProjects = store.getProjects(store.selectedColumn.id);
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.04,
                      maxWidth: (Platform.isAndroid || Platform.isIOS)
                          ? MediaQuery.of(context).size.width * 0.95
                          : MediaQuery.of(context).size.width * 0.75),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ColumnsListRow(
                        children: [
                          ...listColumns.map(
                            (column) => ColumnButton(
                              title: column.name,
                              onPressed: () {
                                store.selectColumn(column);
                              },
                              selected: column == store.selectedColumn,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 300,
                        height: 600,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        constraints: BoxConstraints(
                            maxWidth: (Platform.isAndroid || Platform.isIOS)
                                ? MediaQuery.of(context).size.width * 0.95
                                : MediaQuery.of(context).size.width * 0.75),
                        child: ListView.separated(
                          itemCount: listProjects.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text(
                                listProjects[index].name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 18),
                              ),
                              subtitle: listProjects[index].memo.isNotEmpty
                                  ? Text(
                                      listProjects[index].memo,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : null,
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(),
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
