import 'package:unityspace/models/project_models.dart';
import 'package:wstore/wstore.dart';
import 'package:unityspace/service/project_service.dart' as api;

class ProjectStore extends GStore {
  static ProjectStore? _instance;

  factory ProjectStore() => _instance ??= ProjectStore._();

  ProjectStore._();

  List<Project> projects = [];

  Future<void> getProjectsData(int spaceId) async {
    final projectsData = await api.getProjects(spaceId: spaceId);
    final projects = projectsData.map(Project.fromResponse).toList();
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
