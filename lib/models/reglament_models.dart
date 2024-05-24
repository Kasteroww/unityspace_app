import 'package:unityspace/models/i_base_model.dart';

class UserPassedResponse {
  final String createdAt;
  final int reglamentId;
  final int userId;

  UserPassedResponse({
    required this.createdAt,
    required this.reglamentId,
    required this.userId,
  });

  factory UserPassedResponse.fromJson(Map<String, dynamic> map) {
    return UserPassedResponse(
      createdAt: map['createdAt'] as String,
      reglamentId: map['reglamentId'] as int,
      userId: map['userId'] as int,
    );
  }
}

class DeleteReglamentResponse {
  final int id;

  DeleteReglamentResponse({required this.id});
}

class ReglamentAnswerResponse {
  final String createdAt;
  final int id;
  final bool isRight;
  final String name;
  final int questionId;
  final String updatedAt;

  ReglamentAnswerResponse({
    required this.createdAt,
    required this.id,
    required this.isRight,
    required this.name,
    required this.questionId,
    required this.updatedAt,
  });
}

class ReglamentHistoryResponse {
  final String comment;
  final String createdAt;
  final int id;
  final int userId;

  ReglamentHistoryResponse({
    required this.comment,
    required this.createdAt,
    required this.id,
    required this.userId,
  });
}

class FailedQuestionResponse {
  final int id;
  final String name;

  FailedQuestionResponse({
    required this.id,
    required this.name,
  });
}

class ReglamentCompleteTestResponse {
  final int id;
  final String status;
  final String? createdAt;
  final int userId;
  final List<FailedQuestionResponse> failedQuestions;

  ReglamentCompleteTestResponse({
    required this.id,
    required this.status,
    this.createdAt,
    required this.userId,
    required this.failedQuestions,
  });
}

class CompleteReglamentIntroResponse {
  final int reglamentId;
  final int userId;
  final String createdAt;

  CompleteReglamentIntroResponse({
    required this.reglamentId,
    required this.userId,
    required this.createdAt,
  });
}

class ReglamentQuestionResponse {
  final List<ReglamentAnswerResponse> answers;
  final String createdAt;
  final int id;
  final String name;
  final String order;
  final int reglamentId;
  final String updatedAt;

  ReglamentQuestionResponse({
    required this.answers,
    required this.createdAt,
    required this.id,
    required this.name,
    required this.order,
    required this.reglamentId,
    required this.updatedAt,
  });
}

class RenameReglamentResponse {
  final int id;
  final String name;

  RenameReglamentResponse({
    required this.id,
    required this.name,
  });
}

class ReglamentResponse {
  final String createdAt;
  final int creatorId;
  final int id;
  final String name;
  final String order;
  final int reglamentColumnId;
  final bool required;
  final bool intro;
  final String updatedAt;
  final List<UserPassedResponse> usersPassed;

  ReglamentResponse({
    required this.createdAt,
    required this.creatorId,
    required this.id,
    required this.name,
    required this.order,
    required this.reglamentColumnId,
    required this.required,
    required this.intro,
    required this.updatedAt,
    required this.usersPassed,
  });

  factory ReglamentResponse.fromJson(Map<String, dynamic> map) {
    return ReglamentResponse(
      createdAt: map['createdAt'] as String,
      creatorId: map['creatorId'] as int,
      id: map['id'] as int,
      name: map['name'] as String,
      order: map['order'] as String,
      reglamentColumnId: map['reglamentColumnId'] as int,
      required: map['required'] as bool,
      intro: map['intro'] as bool,
      updatedAt: map['updatedAt'] as String,
      usersPassed: List<UserPassedResponse>.from(
        (map['usersPassed'] as List).map<UserPassedResponse>(
          (x) => UserPassedResponse.fromJson(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}

class ChangeReglamentIntroResponse {
  final int id;
  final bool intro;

  ChangeReglamentIntroResponse({
    required this.id,
    required this.intro,
  });
}

class ClearReglamentUsersPassedResponse {
  final int id;

  ClearReglamentUsersPassedResponse({required this.id});
}

class SearchReglamentResponse extends ReglamentResponse {
  final int spaceId;

  SearchReglamentResponse({
    required super.createdAt,
    required super.creatorId,
    required super.id,
    required super.name,
    required super.order,
    required super.reglamentColumnId,
    required super.required,
    required super.intro,
    required super.updatedAt,
    required super.usersPassed,
    required this.spaceId,
  });
}

class ChangeReglamentColumnAndOrderResponse {
  final int id;
  final int columnId;
  final BigInt order;

  ChangeReglamentColumnAndOrderResponse({
    required this.id,
    required this.columnId,
    required this.order,
  });
}

class GetSearchReglaments {
  final List<SearchReglamentResponse> reglaments;
  final int reglamentsCount;
  final int maxPagesCount;

  GetSearchReglaments({
    required this.reglaments,
    required this.reglamentsCount,
    required this.maxPagesCount,
  });
}

class UpdateReglamentContentResponse {
  final int id;
  final String content;

  UpdateReglamentContentResponse({
    required this.id,
    required this.content,
  });
}

class ReglamentRequiredResponse {
  final int id;
  final bool required;

  ReglamentRequiredResponse({
    required this.id,
    required this.required,
  });
}

class FullReglamentResponse {
  final String content;
  final String createdAt;
  final int creatorId;
  final List<int> editorIds;
  final int id;
  final String lastEditDate;
  final String name;
  final String order;
  final String updatedAt;

  FullReglamentResponse({
    required this.content,
    required this.createdAt,
    required this.creatorId,
    required this.editorIds,
    required this.id,
    required this.lastEditDate,
    required this.name,
    required this.order,
    required this.updatedAt,
  });
}

class Reglament implements BaseModel {
  @override
  final int id;
  final String createdAt;
  final int creatorId;
  final String name;
  final String order;
  final int reglamentColumnId;
  final bool required;
  final bool intro;
  final String updatedAt;
  final List<UserPassedResponse> usersPassed;

  Reglament({
    required this.createdAt,
    required this.creatorId,
    required this.id,
    required this.name,
    required this.order,
    required this.reglamentColumnId,
    required this.required,
    required this.intro,
    required this.updatedAt,
    required this.usersPassed,
  });

  factory Reglament.fromResponse(final ReglamentResponse data) {
    return Reglament(
        createdAt: data.createdAt,
        creatorId: data.creatorId,
        id: data.id,
        name: data.name,
        order: data.order,
        reglamentColumnId: data.reglamentColumnId,
        required: data.required,
        intro: data.intro,
        updatedAt: data.updatedAt,
        usersPassed: data.usersPassed);
  }
}
