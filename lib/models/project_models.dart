import 'package:unityspace/models/i_base_model.dart';
import 'package:unityspace/utils/date_time_converter.dart';

class ProjectResponse {
  final int id;
  final String createdAt;
  final String updatedAt;
  final String name;
  final int creatorId;
  final int columnId;
  final String order;
  final List<ProjectStageResponse> stages;
  final int taskCount;
  final String memo;

  const ProjectResponse({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.creatorId,
    required this.columnId,
    required this.order,
    required this.stages,
    required this.taskCount,
    required this.memo,
  });

  factory ProjectResponse.fromJson(Map<String, dynamic> map) {
    final stagesList = map['stages'] as List<dynamic>;
    return ProjectResponse(
      id: map['id'] as int,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
      name: map['name'] as String,
      creatorId: map['creatorId'] as int,
      columnId: map['columnId'] as int,
      order: map['order'] as String,
      stages: stagesList
          .map((stages) => ProjectStageResponse.fromJson(stages))
          .toList(),
      taskCount: map['taskCount'] as int,
      memo: map['memo'] as String,
    );
  }
}

class ProjectStageResponse {
  final int id;
  final int projectId;
  final String name;
  final String order;

  ProjectStageResponse({
    required this.id,
    required this.projectId,
    required this.name,
    required this.order,
  });

  factory ProjectStageResponse.fromJson(Map<String, dynamic> json) {
    return ProjectStageResponse(
      id: json['id'] as int,
      projectId: json['projectId'] as int,
      name: json['name'] as String,
      order: json['order'] as String,
    );
  }
}

class Project implements BaseModel {
  @override
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final int creatorId;
  final int columnId;
  final String order;
  final List<ProjectStage> stages;
  final int taskCount;
  final String memo;

  Project({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.creatorId,
    required this.columnId,
    required this.order,
    required this.stages,
    required this.taskCount,
    required this.memo,
  });

  factory Project.fromResponse(final ProjectResponse data) {
    return Project(
      id: data.id,
      createdAt: DateTimeConverter.stringToLocalDateTime(data.createdAt),
      updatedAt: DateTimeConverter.stringToLocalDateTime(data.updatedAt),
      name: data.name,
      creatorId: data.creatorId,
      columnId: data.columnId,
      order: data.order,
      stages: data.stages.map(ProjectStage.fromResponse).toList(),
      taskCount: data.taskCount,
      memo: data.memo,
    );
  }
}

class ProjectStage {
  final int id;
  final int projectId;
  final String name;
  final String order;

  ProjectStage({
    required this.id,
    required this.projectId,
    required this.name,
    required this.order,
  });

  factory ProjectStage.fromResponse(ProjectStageResponse data) {
    return ProjectStage(
      id: data.id,
      projectId: data.projectId,
      name: data.name,
      order: data.order,
    );
  }
}

class AddProject {
  final String name;
  final int spaceColumnId;
  final String? color;
  final List<AddProjectStage>? stages;
  final int? responsibleId;
  final int postponingTaskDayCount;

  AddProject({
    required this.name,
    required this.spaceColumnId,
    this.color,
    this.stages,
    this.responsibleId,
    this.postponingTaskDayCount = 0,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'spaceColumnId': spaceColumnId,
      'color': color,
      'stages': stages,
      'responsibleId': responsibleId,
      'postponingTaskDayCount': postponingTaskDayCount,
    };
  }
}

class AddProjectStage {
  final String name;
  final String order;

  AddProjectStage({
    required this.name,
    required this.order,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'order': order,
    };
  }
}
