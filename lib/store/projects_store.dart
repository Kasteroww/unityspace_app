import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/service/project_service.dart' as api;
import 'package:wstore/wstore.dart';

class Projects with GStoreChangeObjectMixin {
  final Map<int, Project> _projectsMap = {};
  final Map<int, ProjectEmbed> _embeddingsMap = {};
  final Map<int, ProjectStage> _stagesMap = {};

  Projects();

  void add(Project project) {
    _setProject(project);
    incrementObjectChangeCount();
  }

  void addAll(Iterable<Project> all) {
    if (all.isNotEmpty) {
      for (final project in all) {
        _setProject(project);
      }
      incrementObjectChangeCount();
    }
  }

  void remove(int projectId) {
    _removeProject(projectId);
    incrementObjectChangeCount();
  }

  void clear() {
    if (_projectsMap.isNotEmpty) {
      _projectsMap.clear();
      _embeddingsMap.clear();
      _stagesMap.clear();
      incrementObjectChangeCount();
    }
  }

  void _setProject(Project project) {
    _removeProject(project.id);
    _projectsMap[project.id] = project;
    for (final embed in project.embeddings) {
      _embeddingsMap[embed.id] = embed;
    }
    for (final stage in project.stages) {
      _stagesMap[stage.id] = stage;
    }
  }

  void _removeProject(int id) {
    final oldProject = _projectsMap.remove(id);
    if (oldProject != null) {
      for (final embed in oldProject.embeddings) {
        _embeddingsMap.remove(embed.id);
      }
      for (final stage in oldProject.stages) {
        _stagesMap.remove(stage.id);
      }
    }
  }

  Project? operator [](int id) => _projectsMap[id];

  ProjectEmbed? getEmbedById(int embedId) => _embeddingsMap[embedId];

  ProjectStage? getStageById(int stageId) => _stagesMap[stageId];

  Iterable<Project> get iterable => _projectsMap.values;

  List<Project> get list => _projectsMap.values.toList();

  int get length => _projectsMap.length;
}

class ProjectsStore extends GStore {
  static ProjectsStore? _instance;

  factory ProjectsStore() => _instance ??= ProjectsStore._();

  ProjectsStore._();

  Projects projects = Projects();

  Map<int, ProjectEmbed> get embeddingsMap => projects._embeddingsMap;

  Map<int, Project> get projectsMap => projects._projectsMap;

  Map<int, ProjectStage> get stagesMap => projects._stagesMap;

  Project? getProjectById(int projectId) {
    return projectsMap[projectId];
  }

  Future<void> getProjectsBySpaceId(int spaceId) async {
    final projectsData = await api.getProjects(spaceId: spaceId);
    final loadedProjects = projectsData.map(Project.fromResponse);
    setStore(() {
      projects.clear();
      projects.addAll(loadedProjects);
    });
  }

  Future<void> getAllProjects() async {
    final projectsData = await api.getAllProjects();
    final loadedProjects = projectsData.map(Project.fromResponse);
    setStore(() {
      projects.clear();
      projects.addAll(loadedProjects);
    });
  }

  /// Архивация и разархивация Проектов
  Future<void> changeProjectColumn(List<int> projectIds, int columnId) async {
    final projectsData = await api.changeProjectColumn(
      projectIds: projectIds,
      columnId: columnId,
    );
    final loadedProjects = projectsData.map(Project.fromResponse).toList();
    _changeProjectColumnLocally(loadedProjects);
  }

  void _changeProjectColumnLocally(List<Project> loadedProjects) {
    final loadedProjectIds = loadedProjects.map((e) => e.id).toList();
    for (final project in projects.list) {
      if (loadedProjectIds.contains(project.id)) {
        final updatedProject = project.copyWith(
          columnId:
              loadedProjects.firstWhere((e) => e.id == project.id).columnId,
        );
        setStore(() {
          projects.add(updatedProject);
        });
      }
    }
  }

  Future<void> addProject(AddProject project) async {
    final projectsData = await api.addProject(project);
    final newProject = Project.fromResponse(projectsData);
    _addProjectLocally(newProject);
  }

  void _addProjectLocally(Project newProject) {
    setStore(() {
      projects.add(newProject);
    });
  }

  Future<void> deleteProject(int projectId) async {
    await api.deleteProject(projectId);
    _deleteProjectLocally(projectId);
  }

  void _deleteProjectLocally(int projectId) {
    setStore(() {
      projects.remove(projectId);
    });
  }

  /// Добавление Проекта в избранное и Удаление
  Future<void> setProjectFavorite(int projectId, bool favorite) async {
    await api.setProjectFavorite(
      projectId: projectId,
      favorite: favorite,
    );
    _setProjectFavoriteLocally(projectId, favorite);
  }

  void _setProjectFavoriteLocally(int projectId, bool favorite) {
    final project = projects[projectId];
    if (project != null) {
      setStore(() {
        projects.add(project.copyWith(favorite: favorite));
      });
    }
  }

  Future<void> createStage({
    required int projectId,
    required String name,
    required double order,
  }) async {
    final response = await api.createProjectStage(
      projectId: projectId,
      name: name,
      order: order,
    );
    final newStage = ProjectStage.fromResponse(response);
    _createProjectStageLocally(newStage);
  }

  void _createProjectStageLocally(ProjectStage stage) {
    final project = projects[stage.projectId];
    if (project != null) {
      final newStages = project.stages..add(stage);
      setStore(() {
        projects.add(project.copyWith(stages: newStages));
      });
    }
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
    final loadedProject = Project.fromResponse(projectData);
    _updateProjectLocally(loadedProject);
  }

  void _updateProjectLocally(Project loadedProject) {
    final project = projects[loadedProject.id];
    if (project != null) {
      final updatedProject = project.copyWith(
        name: loadedProject.name,
        color: loadedProject.color,
        responsibleId: loadedProject.responsibleId,
        postponingTaskDayCount: loadedProject.postponingTaskDayCount,
      );
      setStore(() {
        projects.add(updatedProject);
      });
    }
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
    final loadedEmbed = ProjectEmbed.fromResponse(projectData);
    _createProjectEmbedLocally(loadedEmbed);
  }

  void _createProjectEmbedLocally(ProjectEmbed embed) {
    final project = projects[embed.projectId];
    if (project != null) {
      final newEmbeddings = project.embeddings..add(embed);
      setStore(() {
        projects.add(project.copyWith(embeddings: [...newEmbeddings]));
      });
    }
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
    final project = projects[projectId];
    if (project != null) {
      setStore(() {
        projects.add(project.copyWith(showProjectReviewTab: show));
      });
    }
  }

  /// Обновление элемента tab панели проекта
  Future<void> updateProjectEmbed(ProjectEmbed embed) async {
    await api.updateProjectEmbed(embed);
    _updateProjectEmbedLocally(embed);
  }

  void _updateProjectEmbedLocally(ProjectEmbed embed) {
    final projectEmbed = projects.getEmbedById(embed.id);
    final project = projects[embed.projectId];
    if (projectEmbed != null && project != null) {
      final listEmbeddings = project.embeddings.map((embedding) {
        if (embedding.id == embed.id) {
          return projectEmbed.copyWith(name: embed.name, url: embed.url);
        } else {
          return embedding;
        }
      }).toList();
      setStore(() {
        projects.add(project.copyWith(embeddings: listEmbeddings));
      });
    }
  }

  /// Удаление элемента tab панели проекта
  Future<void> deleteProjectEmbed({
    required int projectId,
    required int embedId,
  }) async {
    await api.deleteProjectEmbed(projectId: projectId, embedId: embedId);
    _deleteProjectEmbedLocally(projectId: projectId, embedId: embedId);
  }

  void _deleteProjectEmbedLocally({
    required int projectId,
    required int embedId,
  }) {
    final project = projects[projectId];
    if (project != null) {
      final newEmbeddings =
          project.embeddings.where((embed) => embed.id != embedId).toList();
      setStore(() {
        projects.add(project.copyWith(embeddings: newEmbeddings));
      });
    }
  }

  @override
  void clear() {
    super.clear();
    setStore(() {
      projects.clear();
    });
  }
}
