import 'package:unityspace/models/i_base_model.dart';
import 'package:unityspace/utils/date_time_converter.dart';

class ProjectResponse {
  final int archiveStageId;
  final int id;
  final String createdAt;
  final String updatedAt;
  final String name;
  final int creatorId;
  final int columnId;
  final String order;
  final List<ProjectStageResponse> stages;
  final int spaceId;
  final List<ProjectEmbedResponse> embeddings;
  final bool showProjectReviewTab;
  final bool timelineViewType;
  final int taskCount;
  final int allTaskCount;
  final String? memo;
  final bool favorite;
  final String? color;
  final int? responsibleId;
  final int postponingTaskDayCount;

  const ProjectResponse({
    required this.archiveStageId,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.creatorId,
    required this.columnId,
    required this.order,
    required this.stages,
    required this.spaceId,
    required this.embeddings,
    required this.showProjectReviewTab,
    required this.timelineViewType,
    required this.taskCount,
    required this.allTaskCount,
    required this.memo,
    required this.favorite,
    required this.color,
    required this.responsibleId,
    required this.postponingTaskDayCount,
  });

  factory ProjectResponse.fromJson(Map<String, dynamic> map) {
    final stagesList = map['stages'] as List<dynamic>;
    final embeddingsList = map['embeddings'] as List<dynamic>;
    return ProjectResponse(
      archiveStageId: map['archiveStageId'] as int,
      id: map['id'] as int,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
      name: map['name'] as String,
      creatorId: map['creatorId'] as int,
      columnId: map['columnId'] as int,
      order: map['order'] as String,
      stages: stagesList
          .map((stage) => ProjectStageResponse.fromJson(stage))
          .toList(),
      spaceId: map['spaceId'] as int,
      embeddings: embeddingsList
          .map((embedding) => ProjectEmbedResponse.fromJson(embedding))
          .toList(),
      showProjectReviewTab: map['showProjectReviewTab'] as bool,
      timelineViewType: map['timelineViewType'] as bool,
      taskCount: map['taskCount'] as int,
      allTaskCount: map['allTaskCount'] as int,
      memo: map['memo'] as String,
      favorite: map['favorite'] as bool,
      color: map['color'] as String?,
      responsibleId: map['responsibleId'] as int?,
      postponingTaskDayCount: map['postponingTaskDayCount'] as int,
    );
  }
}

class ProjectEmbedResponse {
  final int id;
  final int projectId;
  final String name;
  final String url;
  final String category;
  final int order;

  ProjectEmbedResponse({
    required this.id,
    required this.projectId,
    required this.name,
    required this.url,
    required this.category,
    required this.order,
  });

  factory ProjectEmbedResponse.fromJson(Map<String, dynamic> json) {
    return ProjectEmbedResponse(
      id: json['id'],
      projectId: json['projectId'],
      name: json['name'],
      url: json['url'],
      category: json['category'],
      order: json['order'],
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
  final int spaceId;
  final int order;
  final List<ProjectStage> stages;
  final List<ProjectEmbed> embeddings;
  final bool showProjectReviewTab;
  final bool timelineViewType;
  final int taskCount;
  final int allTaskCount;
  final int archiveStageId;
  final String? memo;
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
    required this.spaceId,
    required this.order,
    required this.stages,
    required this.embeddings,
    required this.showProjectReviewTab,
    required this.timelineViewType,
    required this.taskCount,
    required this.allTaskCount,
    required this.archiveStageId,
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
      spaceId: data.spaceId,
      order: int.parse(data.order),
      stages: data.stages.map(ProjectStage.fromResponse).toList(),
      embeddings: data.embeddings
          .map((embedding) => ProjectEmbed.fromResponse(embedding))
          .toList(),
      showProjectReviewTab: data.showProjectReviewTab,
      timelineViewType: data.timelineViewType,
      taskCount: data.taskCount,
      allTaskCount: data.allTaskCount,
      archiveStageId: data.archiveStageId,
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
    String? description,
    int? creatorId,
    int? columnId,
    int? spaceId,
    int? order,
    List<ProjectStage>? stages,
    List<ProjectEmbed>? embeddings,
    bool? showProjectReviewTab,
    bool? timelineViewType,
    int? taskCount,
    int? allTaskCount,
    int? archiveStageId,
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
      spaceId: spaceId ?? this.spaceId,
      order: order ?? this.order,
      stages: stages ?? this.stages,
      embeddings: embeddings ?? this.embeddings,
      showProjectReviewTab: showProjectReviewTab ?? this.showProjectReviewTab,
      timelineViewType: timelineViewType ?? this.timelineViewType,
      taskCount: taskCount ?? this.taskCount,
      allTaskCount: allTaskCount ?? this.allTaskCount,
      archiveStageId: archiveStageId ?? this.archiveStageId,
      memo: memo ?? this.memo,
      favorite: favorite ?? this.favorite,
      color: color ?? this.color,
      responsibleId: responsibleId ?? this.responsibleId,
      postponingTaskDayCount:
          postponingTaskDayCount ?? this.postponingTaskDayCount,
    );
  }
}

class ProjectEmbed {
  final int id;
  final int projectId;
  final String name;
  final String url;
  final String category;
  final int order;

  ProjectEmbed({
    required this.id,
    required this.projectId,
    required this.name,
    required this.url,
    required this.category,
    required this.order,
  });

  factory ProjectEmbed.fromResponse(ProjectEmbedResponse response) {
    return ProjectEmbed(
      id: response.id,
      projectId: response.projectId,
      name: response.name,
      url: response.url,
      category: response.category,
      order: response.order,
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

class ColorType implements Nameable {
  final String? colorHex;

  @override
  final String name;

  const ColorType({required this.colorHex, required this.name});

  ColorType copyWith({
    String? colorHex,
    String? name,
  }) {
    return ColorType(
      colorHex: colorHex ?? this.colorHex,
      name: name ?? this.name,
    );
  }
}

class MarkAsSnailType implements Nameable {
  final MarkAsSnail value;

  @override
  final String name;

  const MarkAsSnailType({required this.value, required this.name});
}

enum MarkAsSnail implements Nameable {
  zero('0'),
  one('1'),
  two('2'),
  three('3'),
  four('4'),
  five('5'),
  six('6'),
  seven('7');

  @override
  final String name;

  const MarkAsSnail(this.name);
}
