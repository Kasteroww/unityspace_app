import 'package:flutter/material.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/widgets/background_image.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/widgets/project_action_button.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/widgets/project_columns.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/widgets/project_listview/projects_listview.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/widgets/skeleton_project_board.dart';
import 'package:unityspace/store/projects_store.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

class ProjectWithUsersOnline {
  Project project;
  List<int> userIds;

  ProjectWithUsersOnline({
    required this.project,
    required this.userIds,
  });
}

class ProjectsPageStore extends WStore {
  ProjectErrors error = ProjectErrors.none;
  WStoreStatus status = WStoreStatus.init;
  bool isArchivedPage = false;
  late int archiveColumnId;
  late SpaceColumn selectedColumn;

  Space get initialCurrentSpace => widget.space;

  ///Получение конкретного пространства по id
  Space? get currentSpace => computedFromStore(
        store: SpacesStore(),
        getValue: (store) => store.spaces[initialCurrentSpace.id],
        keyName: 'currentSpace',
      );

  /// Ссылка на кастомный бэкграунд
  String? get customBackGroundLink => computed(
        getValue: () {
          return currentSpace?.customBackground;
        },
        watch: () => [currentSpace],
        keyName: 'customBackGroundLink',
      );

  /// Id бекграунда
  int? get backgroundId => computed(
        getValue: () {
          return currentSpace?.backgroundId;
        },
        watch: () => [currentSpace],
        keyName: 'backgroundId',
      );

  /// Получение колонок с Проектами
  List<SpaceColumn> get projectColumns => computed(
        getValue: () => _getColumns(currentSpace: currentSpace),
        watch: () => [currentSpace],
        keyName: 'projectColumns',
      );

  /// Получение проектов из колонки
  List<ProjectWithUsersOnline> get projectsWithUsersByColumn => computed(
        getValue: () => _getProjectsByColumnId(
          isArchivedPage ? archiveColumnId : selectedColumn.id,
        ),
        watch: () => [projects, selectedColumn, isArchivedPage],
        keyName: 'projectsByColumn',
      );

  /// Получение количества проектов в архивной колонке
  int get archiveProjectsCount => computed(
        getValue: () => _getProjectsByColumnId(archiveColumnId).length,
        watch: () => [projects],
        keyName: 'archiveProjectsCount',
      );

  ///Получение проектов
  List<Project> get projects => computedFromStore(
        store: ProjectsStore(),
        getValue: (store) => _getProjects(store.projects.list),
        keyName: 'projects',
      );

  void selectColumn(final SpaceColumn column) {
    setStore(() {
      selectedColumn = column;
    });
  }

  /// Нужно ли отобразить колонки в пространтсве
  bool get isNeedToShowColumns => computed(
        getValue: () => !isArchivedPage && projectColumns.length > 1,
        watch: () => [isArchivedPage, projectColumns.length],
        keyName: 'isNeedToShowArchive',
      );

  void selectArchive() {
    setStore(() {
      isArchivedPage = !isArchivedPage;
    });
  }

  bool get isOwnerOrAdmin => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.isOwnerOrAdmin,
        keyName: 'isOwnerOrAdmin',
      );

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

  List<ProjectWithUsersOnline> _getProjectsByColumnId(int id) {
    return projects
        .where((project) => project.columnId == id)
        .map((project) => ProjectWithUsersOnline(project: project, userIds: []))
        .toList();
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
    return WStoreBuilder<ProjectsPageStore>(
      watch: (store) => [
        store.customBackGroundLink,
        store.backgroundId,
      ],
      builder: (context, store) {
        return Stack(
          children: [
            BackgroundImage(
              url: store.customBackGroundLink,
              id: store.backgroundId,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ProjectColumnsListView(),
                // Подгружаются непосредственно колонки с проектами
                WStoreStatusBuilder(
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
                    return const SkeletonProjectBoard();
                  },
                  builder: (context, _) {
                    return const SizedBox.shrink();
                  },
                  builderLoaded: (BuildContext context) {
                    return const ProjectsByColumnListView();
                  },
                ),
              ],
            ),
            ProjectActionButton(
              spaceId: store.currentSpace?.id,
              columnId: store.selectedColumn.id,
            ),
          ],
        );
      },
    );
  }
}
