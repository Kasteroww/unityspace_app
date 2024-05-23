import 'package:unityspace/models/project_models.dart';
import 'package:wstore/wstore.dart';
import 'package:unityspace/service/project_service.dart' as api;

class ProjectStore extends GStore {
  static ProjectStore? _instance;

  factory ProjectStore() => _instance ??= ProjectStore._();

  ProjectStore._();

  List<Project> projects = [];

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

  Future<void> archiveProject(List<int> projectIds, int archiveColumnId) async {
    final projectsData = await api.archiveProject(
        projectIds: projectIds, archiveColumnId: archiveColumnId);
    final project = projectsData.map(Project.fromResponse).toList();
    final projectId = projects.indexWhere((el) => el.id == project.first.id);
    final projectsNew = projects
      ..removeAt(projectId)
      ..add(project.first);
    setStore(() {
      projects = [...projectsNew];
    });
  }

  Future<void> unarchiveProject(int projectId) async {
    setStore(() {
      this.projects = projects;
    });
  }

  @override
  void clear() {
    super.clear();
    setStore(() {
      projects.clear();
    });
  }
}
