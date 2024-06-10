import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/dialogs/add_project_dialog.dart';
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

  Space get currentSpace => widget.space;

  /// Получение колонок с Проектами
  List<SpaceColumn> get projectColumns => computed(
        getValue: () => _getColumns(currentSpace: currentSpace),
        watch: () => [currentSpace],
        keyName: 'projectColumns',
      );

  ///Получение проектов из колонки
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
        getValue: (store) => _getProjects(store.projects),
        keyName: 'projects',
      );

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

  ///Сортировка проектов по order
  List<Project> _getProjects(List<Project> projects) {
    projects.sort((a, b) => a.order.compareTo(b.order));
    return projects;
  }

  /// Сортировка колонок проектов по order
  List<SpaceColumn> _getColumns({required Space? currentSpace}) {
    final cols = currentSpace?.columns ?? [];
    cols.sort((a, b) => a.order.compareTo(b.order));
    return cols;
  }

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
            return SafeArea(
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!store.isArchivedPage)
                        Container(
                          height: 46,
                          padding: const EdgeInsets.only(left: 20),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              ColumnsListRow(
                                children: [
                                  ...store.projectColumns.map(
                                    (column) => ColumnButton(
                                      title: column.name,
                                      onTap: () {
                                        store.selectColumn(column);
                                      },
                                      isSelected:
                                          column == store.selectedColumn,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const ProjectsListview(),
                    ],
                  ),
                  Align(
                    alignment: const Alignment(0.9, 1),
                    child: InkWell(
                      onTap: () {
                        showAddProjectDialog(
                          context,
                          store.selectedColumn.id,
                        );
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: ColorConstants.main,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/add_1.svg',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
