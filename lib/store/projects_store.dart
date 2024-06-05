import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/service/project_service.dart' as api;
import 'package:unityspace/utils/helpers.dart';
import 'package:wstore/wstore.dart';

class ProjectsStore extends GStore {
  static ProjectsStore? _instance;

  factory ProjectsStore() => _instance ??= ProjectsStore._();

  ProjectsStore._();

  List<Project> projects = [];

  Map<int, Project?> get projectsMap {
    return createMapById(projects);
  }

  Map<int, ProjectStage?> get stagesMap {
    return createMapById(projects.expand((project) => project.stages).toList());
  }

  Project? getProjectById(int projectId) {
    return projectsMap[projectId];
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
  Future<void> updateProject({
    required int id,
    required String name,
    required int postponingTaskDayCount,
    String? color,
    int? responsibleId,
  }) async {
    final projectData = await api.updateProject(
      id: id,
      name: name,
      postponingTaskDayCount: postponingTaskDayCount,
      color: color,
      responsibleId: responsibleId,
    );
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

  /// Создание элемента tab панели проекта
  Future<void> createProjectEmbed({
    required int projectId,
    required String name,
    required String url,
    required String category,
  }) async {
    final projectData = await api.createProjectEmbed(
      projectId: projectId,
      name: name,
      url: url,
      category: category,
    );
    _createProjectEmbedLocally(projectData);
  }

  void _createProjectEmbedLocally(ProjectEmbedResponse embedResponse) {
    final List<Project> projectsNew = projects.map((project) {
      if (embedResponse.projectId == project.id) {
        final List<ProjectEmbed> embeddingsNew = project.embeddings
          ..add(ProjectEmbed.fromResponse(embedResponse));
        return project.copyWith(embeddings: [...embeddingsNew]);
      } else {
        return project;
      }
    }).toList();
    setStore(() {
      projects = projectsNew;
    });
  }

  /// Отображение элемента tab панели проекта "Документация"
  Future<void> showProjectReviewTab({
    required int projectId,
    required bool show,
  }) async {
    await api.showProjectReviewTab(
      projectId: projectId,
      show: show,
    );
    _showProjectReviewTabLocally(projectId: projectId, show: show);
  }

  void _showProjectReviewTabLocally({
    required int projectId,
    required bool show,
  }) {
    final List<Project> projectsNew = projects.map((project) {
      if (projectId == project.id) {
        return project.copyWith(showProjectReviewTab: show);
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
