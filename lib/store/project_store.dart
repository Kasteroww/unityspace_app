import 'package:unityspace/models/project_models.dart';
import 'package:wstore/wstore.dart';
import 'package:unityspace/service/project_service.dart' as api;

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
        projectIds: projectIds, columnId: columnId);
    setStore(() {
      projects = _changeProjectColumnLocally(projectsData, projects);
    });
  }

  List<Project> _changeProjectColumnLocally(
      List<ProjectResponse> projectsResponse, List<Project> projects) {
    final projectsIdsResponse = projectsResponse.map((e) => e.id).toList();
    return projects.map((project) {
      if (projectsIdsResponse.contains(project.id)) {
        return project.copyWith(
            columnId: projectsResponse
                .where((e) => e.id == project.id)
                .first
                .columnId);
      } else {
        return project;
      }
    }).toList();
  }

  Future<void> addProject(AddProject project) async {
    final projectsData = await api.addProject(project);
    setStore(() {
      projects = _addProjectLocally(projectsData, projects);
    });
  }

  List<Project> _addProjectLocally(
      ProjectResponse projectResponse, List<Project> projects) {
    return projects..add(Project.fromResponse(projectResponse));
  }

  @override
  void clear() {
    super.clear();
    setStore(() {
      projects = [];
    });
  }
}
