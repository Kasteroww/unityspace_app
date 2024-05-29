import 'package:collection/collection.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/service/project_service.dart' as api;
import 'package:wstore/wstore.dart';

class ProjectStore extends GStore {
  static ProjectStore? _instance;

  factory ProjectStore() => _instance ??= ProjectStore._();

  ProjectStore._();

  List<Project> projects = [];

  Map<int, Project?> get projectsMap {
    if (projects == []) return {};
    return projects.fold<Map<int, Project?>>(
      {},
      (acc, project) {
        acc[project.id] = project;
        return acc;
      },
    );
  }

  Project? getProjectById(int projectId) {
    return projects.firstWhereOrNull((project) => project.id == projectId);
  }

  Future<void> getProjectsBySpaceId(int spaceId) async {
    final projectsData = await api.getProjects(spaceId: spaceId);
    final projects = projectsData.map(Project.fromResponse).toList();
    setStore(() {
      this.projects = projects;
    });
  }

  Future<void> getAllProjects() async {
    final projectsData = await api.getAllProjects();
    final projects = projectsData.map(Project.fromResponse).toList();
    setStore(() {
      this.projects = projects;
    });
  }

  /// Архивация и разархивация Проектов
  Future<void> changeProjectColumn(List<int> projectIds, int columnId) async {
    final projectsData = await api.changeProjectColumn(
      projectIds: projectIds,
      columnId: columnId,
    );
    setStore(() {
      projects = _changeProjectColumnLocally(projectsData, projects);
    });
  }

  List<Project> _changeProjectColumnLocally(
    List<ProjectResponse> projectsResponse,
    List<Project> projects,
  ) {
    final projectsIdsResponse = projectsResponse.map((e) => e.id).toList();
    return projects.map((project) {
      if (projectsIdsResponse.contains(project.id)) {
        return project.copyWith(
          columnId:
              projectsResponse.where((e) => e.id == project.id).first.columnId,
        );
      } else {
        return project;
      }
    }).toList();
  }

  Future<void> addProject(AddProject project) async {
    final projectsData = await api.addProject(project);
    setStore(() {
      projects = [..._addProjectLocally(projectsData, projects)];
    });
  }

  List<Project> _addProjectLocally(
    ProjectResponse projectResponse,
    List<Project> projects,
  ) {
    return projects..add(Project.fromResponse(projectResponse));
  }

  Future<void> deleteProject(int projectId) async {
    await api.deleteProject(projectId);
    setStore(() {
      projects = [..._deleteProjectLocally(projectId, projects)];
    });
  }

  List<Project> _deleteProjectLocally(int projectId, List<Project> projects) {
    return projects..removeWhere((project) => project.id == projectId);
  }

  /// Добавление Проекта в избранное и Удаление
  Future<void> setProjectFavorite(int projectId, bool favorite) async {
    await api.setProjectFavorite(
      projectId: projectId,
      favorite: favorite,
    );
    _setProjectFavoriteLocally(projectId, favorite);
  }

  void _setProjectFavoriteLocally(
    int projectId,
    bool favorite,
  ) {
    final projectsNew = projects.map((project) {
      if (projectId == project.id) {
        return project.copyWith(
          favorite: favorite,
        );
      } else {
        return project;
      }
    }).toList();
    setStore(() {
      projects = projectsNew;
    });
  }

  /// Изменение названия, цвета, ответственного Проекта
  /// и через сколько отмечать задачи Проекта как неактивные
  Future<void> updateProject(UpdateProject project) async {
    final projectData = await api.updateProject(project: project);
    _updateProjectLocally(projectData);
  }

  void _updateProjectLocally(ProjectResponse projectResponse) {
    final projectsNew = projects.map((project) {
      if (projectResponse.id == project.id) {
        return project.copyWith(
          name: projectResponse.name,
          color: projectResponse.color,
          responsibleId: projectResponse.responsibleId,
          postponingTaskDayCount: projectResponse.postponingTaskDayCount,
        );
      } else {
        return project;
      }
    }).toList();
    setStore(() {
      projects = projectsNew;
    });
  }

  @override
  void clear() {
    super.clear();
    setStore(() {
      projects = [];
    });
  }
}
