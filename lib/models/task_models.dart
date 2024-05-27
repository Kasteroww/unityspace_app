import 'dart:core';

import 'package:unityspace/models/i_base_model.dart';
import 'package:unityspace/utils/date_time_converter.dart';

enum TaskChangesTypes {
  // Вы создали задачу #291039
  createTask(0),
  // Вы изменили название задачи на название задачи изменен
  changeName(1),
  // Вы изменили описание задачи
  changeDescription(2),
  // Вы добавили исполнителя к задаче - Марина Бухановская
  changeResponsible(3),
  // Вы переместили задачу в колонку "В работе" в проекте "flutt
  changeStage(4),
  // Вы изменили цвет задачи на [square with color]
  changeColor(5),
  // Вы изменили статус задачи на "Отклонено"
  changeStatus(6),
  // Вы перенесли задачу на новую дату 17.05.2024
  changeDate(7),
  // Вы оставили комментарий "send message"
  sendMessage(8),
  // Вы добавили к задаче ярлык #new_tag
  addTag(9),
  // Вы удалили у задачи ярлык #new_tag
  deleteTag(10),
  // Вы удалили задачу
  deleteTask(11),
  // Требует внимания
  changeBlockReason(12),
  // Вы изменили обложку у задачи
  addCover(13),
  // Вы удалили обложку задачи
  deleteCover(14),
  // Задача просрочена и на ней нет исполнителя!
  overdueTaskNoResponsible(15),
  // Задача просрочена
  overdueTaskWithResponsible(16),
  // Вы изменили важность задачи на {state}
  changeImportance(17),
  // Новый коммит по задаче: {commitName}
  commit(18),
  // Вы добавили задачу в проект "Проект"
  addStage(19),
  // Вы убрали задачу из проекта "Проект"
  deleteStage(20),
  // Вы исключили члена пространства Иван Петров
  removeMember(21),
  // Вы добавили исполнителя к задаче - "Иван Петров"
  addResponsible(22),
  // Вы убрали исполнителя с задачи - "Иван Петров"
  removeResponsible(23),
  defaultValue(-1),
  ;

  final int value;

  const TaskChangesTypes(this.value);
}

class Task implements BaseModel {
  @override
  final int id;
  final String name;
  final List<TaskStages> stages;
  final String? color;
  final DateTime createdAt;
  final int creatorId;
  final List<int> tags;
  final List<int> responsibleUsersId;
  final bool hasMessages;
  final bool hasDescription;
  final int status;
  final DateTime? dateBegin;
  final DateTime? dateEnd;
  final DateTime dateMove;
  final TaskImportance importance;
  final String? dateStatusChanged;
  final String? blockReason;
  final List<int> members;
  final TaskCover? cover;

  Task({
    required this.id,
    required this.name,
    required this.stages,
    required this.color,
    required this.createdAt,
    required this.creatorId,
    required this.tags,
    required this.responsibleUsersId,
    required this.hasMessages,
    required this.hasDescription,
    required this.status,
    required this.dateBegin,
    required this.dateEnd,
    required this.dateMove,
    required this.importance,
    required this.dateStatusChanged,
    required this.blockReason,
    required this.members,
    required this.cover,
  });

  factory Task.fromResponse(TaskResponse response) {
    return Task(
        id: response.id,
        name: response.name,
        stages: response.stages,
        color: response.color,
        createdAt: DateTimeConverter.stringToLocalDateTime(response.createdAt),
        creatorId: response.creatorId,
        tags: response.tags,
        responsibleUsersId: response.responsibleUserId,
        hasMessages: response.hasMessages,
        hasDescription: response.hasDescription,
        status: response.status,
        dateBegin: response.dateBegin != null
            ? DateTimeConverter.stringToLocalDateTime(response.dateBegin!)
            : null,
        dateEnd: response.dateEnd != null
            ? DateTimeConverter.stringToLocalDateTime(response.dateEnd!)
            : null,
        dateMove: DateTimeConverter.stringToLocalDateTime(response.dateMove!),
        importance: response.importance,
        dateStatusChanged: response.dateStatusChanged,
        blockReason: response.blockReason,
        members: response.members,
        cover: response.cover);
  }
}

enum TaskStatuses {
  inWork(0),
  completed(1),
  rejected(2);

  final int value;

  const TaskStatuses(this.value);
}

enum TaskImportance {
  high(1),
  normal(0),
  low(-1);

  final int value;

  const TaskImportance(this.value);
}

class TaskCover {
  final int id;
  final String dominantColor;
  final int height;
  final String pictureUid;
  final int taskId;
  final int width;
  final String? fullLink;

  TaskCover({
    required this.id,
    required this.dominantColor,
    required this.height,
    required this.pictureUid,
    required this.taskId,
    required this.width,
    required this.fullLink,
  });

  factory TaskCover.fromJson(Map<String, dynamic> json) {
    return TaskCover(
      id: json['id'] as int,
      dominantColor: json['dominantColor'] as String,
      height: json['height'] as int,
      pictureUid: json['pictureUid'] as String,
      taskId: json['taskId'] as int,
      width: json['width'] as int,
      fullLink: json['fullLink'] as String?,
    );
  }
}

class TaskStages {
  final int stageId;
  final int order;
  final int projectId;

  TaskStages({
    required this.stageId,
    required this.order,
    required this.projectId,
  });

  factory TaskStages.fromJson(Map<String, dynamic> json) {
    return TaskStages(
      stageId: json['stageId'] as int,
      order: int.parse(json['order'] as String),
      projectId: json['projectId'] as int,
    );
  }
}

class TaskResponse {
  final int id;
  final String name;
  final String? color;
  final List<TaskStages> stages;
  final TaskImportance importance;
  final String createdAt;
  final int creatorId;
  final List<int> tags;
  final List<int> responsibleUserId;
  final bool hasMessages;
  final bool hasDescription;
  final int status;
  final String? dateBegin;
  final String? dateEnd;
  final String? dateStatusChanged;
  final String? blockReason;
  final String? dateMove;
  final List<int> members;
  final TaskCover? cover;

  TaskResponse({
    required this.id,
    required this.name,
    required this.color,
    required this.stages,
    required this.importance,
    required this.createdAt,
    required this.creatorId,
    required this.tags,
    required this.responsibleUserId,
    required this.hasMessages,
    required this.hasDescription,
    required this.status,
    required this.dateBegin,
    required this.dateEnd,
    required this.dateStatusChanged,
    required this.blockReason,
    required this.dateMove,
    required this.members,
    required this.cover,
  });

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    return TaskResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      color: json['color'] as String?,
      stages: (json['stages'] as List<dynamic>)
          .map((e) => TaskStages.fromJson(e as Map<String, dynamic>))
          .toList(),
      importance: TaskImportance.values.firstWhere(
          (type) => type.value == json['importance'] as int,
          orElse: () => TaskImportance.normal),
      createdAt: json['createdAt'] as String,
      creatorId: json['creatorId'] as int,
      tags: (json['tags'] as List<dynamic>).map((e) => e as int).toList(),
      responsibleUserId: (json['responsibleUserId'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      hasMessages: json['hasMessages'] as bool,
      hasDescription: json['hasDescription'] as bool,
      status: json['status'] as int,
      dateBegin: json['dateBegin'] as String?,
      dateEnd: json['dateEnd'] as String?,
      dateStatusChanged: json['dateStatusChanged'] as String?,
      blockReason: json['blockReason'] as String?,
      dateMove: json['dateMove'] as String?,
      members: (json['members'] as List<dynamic>).map((e) => e as int).toList(),
      cover: json['cover'] != null
          ? TaskCover.fromJson(json['cover'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TaskResponses {
  final List<TaskResponse> tasks;

  TaskResponses({
    required this.tasks,
  });

  factory TaskResponses.fromJson(List<dynamic> json) {
    return TaskResponses(
      tasks: json
          .map((e) => TaskResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TaskHistory implements BaseModel {
  @override
  final int id;
  final String? state;
  final int taskId;
  final TaskChangesTypes type;
  final DateTime updateDate;
  final int userId;
  final String? projectName;
  final String? taskName;
  final String? commitName;

  TaskHistory({
    required this.id,
    required this.state,
    required this.taskId,
    required this.type,
    required this.updateDate,
    required this.userId,
    required this.projectName,
    required this.taskName,
    required this.commitName,
  });

  factory TaskHistory.fromResponse(TaskHistoryResponse response) {
    return TaskHistory(
      id: response.id,
      state: response.state,
      taskId: response.taskId,
      type: TaskChangesTypes.values.firstWhere(
          (type) => type.value == response.type,
          orElse: () => TaskChangesTypes.defaultValue),
      updateDate: DateTimeConverter.stringToLocalDateTime(response.updateDate),
      userId: response.userId,
      projectName: response.projectName,
      taskName: response.taskName,
      commitName: response.commitName,
    );
  }
}

class MyTaskHistoryResponse {
  final int maxPageCount;
  final List<TaskHistoryResponse> history;
  final List<TaskResponse> tasks;
  MyTaskHistoryResponse(
      {required this.maxPageCount, required this.history, required this.tasks});

  factory MyTaskHistoryResponse.fromJson(Map<String, dynamic> map) {
    final historyList = map['history'] as List<dynamic>;
    final tasksList = map['tasks'] as List<dynamic>;

    return MyTaskHistoryResponse(
        maxPageCount: map['maxPagesCount'] as int,
        history: historyList
            .map((history) => TaskHistoryResponse.fromJson(history))
            .toList(),
        tasks: tasksList.map((task) => TaskResponse.fromJson(task)).toList());
  }
}

class TaskHistoryResponse {
  final int id;
  final String updateDate;
  final int taskId;
  final String? taskName;
  final int userId;
  final int type;
  final String? state;
  final String? projectName;
  final String? commitName;

  TaskHistoryResponse(
      {required this.id,
      required this.updateDate,
      required this.taskId,
      required this.taskName,
      required this.userId,
      required this.type,
      required this.state,
      required this.projectName,
      required this.commitName});

  factory TaskHistoryResponse.fromJson(Map<dynamic, dynamic> map) {
    return TaskHistoryResponse(
      id: map['id'] as int,
      updateDate: map['updateDate'] as String,
      taskId: map['taskId'] as int,
      taskName: map['taskName'] as String?,
      userId: map['userId'] as int,
      type: map['type'] as int,
      state: map['state'] as String?,
      projectName: map['projectName'] as String?,
      commitName: map['commitName'] as String?,
    );
  }
}
