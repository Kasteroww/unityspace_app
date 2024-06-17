import 'package:unityspace/models/model_interfaces.dart';
import 'package:unityspace/service/exceptions/data_exceptions.dart';
import 'package:unityspace/utils/helpers.dart';

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
    try {
      return UserPassedResponse(
        createdAt: map['createdAt'] as String,
        reglamentId: map['reglamentId'] as int,
        userId: map['userId'] as int,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class DeleteReglamentResponse {
  final int id;

  DeleteReglamentResponse({required this.id});

  factory DeleteReglamentResponse.fromJson(Map<String, dynamic> map) {
    try {
      return DeleteReglamentResponse(
        id: map['id'] as int,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
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
  factory ReglamentAnswerResponse.fromJson(Map<String, dynamic> map) {
    try {
      return ReglamentAnswerResponse(
        createdAt: map['createdAt'] as String,
        id: map['id'] as int,
        isRight: map['isRight'] as bool,
        name: map['name'] as String,
        questionId: map['questionId'] as int,
        updatedAt: map['updatedAt'] as String,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class ReglamentAnswer {
  final String createdAt;
  final int id;
  final bool isRight;
  final String name;
  final int questionId;
  final String updatedAt;

  ReglamentAnswer({
    required this.createdAt,
    required this.id,
    required this.isRight,
    required this.name,
    required this.questionId,
    required this.updatedAt,
  });
  factory ReglamentAnswer.fromResponse(ReglamentAnswerResponse data) {
    return ReglamentAnswer(
      createdAt: data.createdAt,
      id: data.id,
      isRight: data.isRight,
      name: data.name,
      questionId: data.questionId,
      updatedAt: data.updatedAt,
    );
  }

  ReglamentAnswer copyWith({
    String? createdAt,
    int? id,
    bool? isRight,
    String? name,
    int? questionId,
    String? updatedAt,
  }) {
    return ReglamentAnswer(
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      isRight: isRight ?? this.isRight,
      name: name ?? this.name,
      questionId: questionId ?? this.questionId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
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
    required this.userId,
    required this.failedQuestions,
    this.createdAt,
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

  factory ReglamentQuestionResponse.fromJson(Map<String, dynamic> map) {
    try {
      return ReglamentQuestionResponse(
        answers: (map['answers'] as List<dynamic>)
            .map((answerJson) => ReglamentAnswerResponse.fromJson(answerJson))
            .toList(),
        createdAt: map['createdAt'] as String,
        id: map['id'] as int,
        name: map['name'] as String,
        order: map['order'] as String,
        reglamentId: map['reglamentId'] as int,
        updatedAt: map['updatedAt'] as String,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class ReglamentQuestion {
  final List<ReglamentAnswer> answers;
  final String createdAt;
  final int id;
  final String name;
  final double order;
  final int reglamentId;
  final String updatedAt;
  ReglamentQuestion({
    required this.answers,
    required this.createdAt,
    required this.id,
    required this.name,
    required this.order,
    required this.reglamentId,
    required this.updatedAt,
  });
  factory ReglamentQuestion.fromResponse(ReglamentQuestionResponse data) {
    final List<ReglamentAnswer> answers =
        data.answers.map((i) => ReglamentAnswer.fromResponse(i)).toList();
    return ReglamentQuestion(
      answers: answers,
      createdAt: data.createdAt,
      id: data.id,
      name: data.name,
      order: convertFromOrderResponse(int.parse(data.order)),
      reglamentId: data.reglamentId,
      updatedAt: data.updatedAt,
    );
  }

  ReglamentQuestion copyWith({
    List<ReglamentAnswer>? answers,
    String? createdAt,
    int? id,
    String? name,
    double? order,
    int? reglamentId,
    String? updatedAt,
  }) {
    return ReglamentQuestion(
      answers: answers ?? this.answers,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      reglamentId: reglamentId ?? this.reglamentId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RenameReglamentResponse {
  final int id;
  final String name;

  RenameReglamentResponse({
    required this.id,
    required this.name,
  });

  factory RenameReglamentResponse.fromJson(Map<String, dynamic> map) {
    try {
      return RenameReglamentResponse(
        id: map['id'] as int,
        name: map['name'] as String,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
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
    try {
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
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
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
  final double order;

  ChangeReglamentColumnAndOrderResponse({
    required this.id,
    required this.columnId,
    required this.order,
  });

  factory ChangeReglamentColumnAndOrderResponse.fromJson(
    Map<String, dynamic> map,
  ) {
    return ChangeReglamentColumnAndOrderResponse(
      id: map['id'] as int,
      columnId: map['columnId'] as int,
      order: convertFromOrderResponse(int.parse(map['order'])),
    );
  }
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

  factory ReglamentRequiredResponse.fromJson(Map<String, dynamic> map) {
    try {
      return ReglamentRequiredResponse(
        id: map['id'] as int,
        required: map['required'] as bool,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
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
  factory FullReglamentResponse.fromJson(Map<String, dynamic> map) {
    try {
      return FullReglamentResponse(
        content: map['content'] as String,
        createdAt: map['createdAt'] as String,
        creatorId: map['creatorId'] as int,
        editorIds: List<int>.from(map['editorIds']),
        id: map['id'] as int,
        lastEditDate: map['lastEditDate'] as String,
        name: map['name'] as String,
        order: map['order'] as String,
        updatedAt: map['updatedAt'] as String,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class FullReglament {
  final String content;
  final String createdAt;
  final int creatorId;
  final List<int> editorIds;
  final int id;
  final String lastEditDate;
  final String name;
  final double order;
  final String updatedAt;

  FullReglament({
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

  factory FullReglament.fromResponse(FullReglamentResponse data) {
    try {
      return FullReglament(
        content: data.content,
        createdAt: data.createdAt,
        creatorId: data.creatorId,
        editorIds: data.editorIds,
        id: data.id,
        lastEditDate: data.lastEditDate,
        name: data.name,
        order: convertFromOrderResponse(int.parse(data.order)),
        updatedAt: data.updatedAt,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class Reglament implements Identifiable {
  @override
  final int id;
  final String createdAt;
  final int creatorId;
  final String name;
  final double order;
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
      order: convertFromOrderResponse(int.parse(data.order)),
      reglamentColumnId: data.reglamentColumnId,
      required: data.required,
      intro: data.intro,
      updatedAt: data.updatedAt,
      usersPassed: data.usersPassed,
    );
  }

  Reglament copyWith({
    int? id,
    String? createdAt,
    int? creatorId,
    String? name,
    double? order,
    int? reglamentColumnId,
    bool? required,
    bool? intro,
    String? updatedAt,
    List<UserPassedResponse>? usersPassed,
  }) {
    return Reglament(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      creatorId: creatorId ?? this.creatorId,
      name: name ?? this.name,
      order: order ?? this.order,
      reglamentColumnId: reglamentColumnId ?? this.reglamentColumnId,
      required: required ?? this.required,
      intro: intro ?? this.intro,
      updatedAt: updatedAt ?? this.updatedAt,
      usersPassed: usersPassed ?? this.usersPassed,
    );
  }
}

class DuplicatedReglament {
  final String name;
  final int reglamentColumnId;
  final double order;
  final String content;
  final bool required;

  DuplicatedReglament({
    required this.name,
    required this.reglamentColumnId,
    required this.order,
    required this.content,
    required this.required,
  });
}
