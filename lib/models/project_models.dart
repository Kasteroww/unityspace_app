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
  final bool favorite;
  final String? color;
  final int? responsibleId;
  final int postponingTaskDayCount;

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
    required this.favorite,
    required this.color,
    required this.responsibleId,
    required this.postponingTaskDayCount,
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
      favorite: map['favorite'] as bool,
      color: map['color'] != null ? map['color'] as String : null,
      responsibleId:
          map['responsibleId'] != null ? map['responsibleId'] as int : null,
      postponingTaskDayCount: map['postponingTaskDayCount'] as int,
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

class Project implements Identifiable {
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
  final bool favorite;
  final String? color;
  final int? responsibleId;
  final int postponingTaskDayCount;

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
    required this.favorite,
    required this.color,
    required this.responsibleId,
    required this.postponingTaskDayCount,
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
      favorite: data.favorite,
      color: data.color,
      responsibleId: data.responsibleId,
      postponingTaskDayCount: data.postponingTaskDayCount,
    );
  }

  Project copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    int? creatorId,
    int? columnId,
    String? order,
    List<ProjectStage>? stages,
    int? taskCount,
    String? memo,
    bool? favorite,
    String? color,
    int? responsibleId,
    int? postponingTaskDayCount,
  }) {
    return Project(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      creatorId: creatorId ?? this.creatorId,
      columnId: columnId ?? this.columnId,
      order: order ?? this.order,
      stages: stages ?? this.stages,
      taskCount: taskCount ?? this.taskCount,
      memo: memo ?? this.memo,
      favorite: favorite ?? this.favorite,
      color: color ?? this.color,
      responsibleId: responsibleId ?? this.responsibleId,
      postponingTaskDayCount:
          postponingTaskDayCount ?? this.postponingTaskDayCount,
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

class UpdateProject {
  final int id;
  final String name;
  final String? color;
  final int? responsibleId;
  final int postponingTaskDayCount;

  UpdateProject({
    required this.id,
    required this.name,
    this.color,
    this.responsibleId,
    this.postponingTaskDayCount = 0,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'color': color,
      'responsibleId': responsibleId,
      'postponingTaskDayCount': postponingTaskDayCount,
    };
  }
}
