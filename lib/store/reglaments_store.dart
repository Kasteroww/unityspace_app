import 'package:unityspace/models/reglament_models.dart';
import 'package:unityspace/service/reglament_service.dart' as api;
import 'package:unityspace/utils/helpers.dart';
import 'package:wstore/wstore.dart';

class ReglamentsStore extends GStore {
  static ReglamentsStore? _instance;

  factory ReglamentsStore() => _instance ??= ReglamentsStore._();

  ReglamentsStore._();

  List<Reglament>? reglaments;

  FullReglament? fullReglament;

  List<ReglamentQuestion>? questions;

  Map<int, Reglament> get reglamentsMap {
    return createMapById(reglaments);
  }

  ///Создание регламента
  Future<Reglament> createReglament({
    required String name,
    required int columnId,
    required String content,
    double? order,
  }) async {
    final createdReglamentData =
        await api.createReglament(name, columnId, content, order: order);

    final reglament = Reglament.fromResponse(createdReglamentData);
    setStore(() {
      reglaments = _createReglamentLocally(reglament);
    });

    await createReglamentSaveHistory(
      reglamentId: reglament.id,
      comment: 'Создан новый регламент',
      clearUserPassed: false,
    );
    return reglament;
  }

  /// Запись в историю о действии с регламентом
  Future<void> createReglamentSaveHistory({
    required int reglamentId,
    required String comment,
    required bool clearUserPassed,
  }) async {
    await api.createReglamentSaveHistory(
      reglamentId: reglamentId,
      comment: comment,
      clearUsersPassed: clearUserPassed,
    );
  }

  ///Получение всех регламентов
  Future<void> getReglaments() async {
    final reglamentsData = await api.getReglaments();
    final List<Reglament> newReglaments = reglamentsData
        .map((reglamentResponse) => Reglament.fromResponse(reglamentResponse))
        .toList();
    final reglamentsCopy = [...newReglaments];
    setStore(() {
      reglaments = reglamentsCopy;
    });
  }

  Future<void> getReglamentContent({required int reglamentId}) async {
    final reglamentData = await api.getFullReglament(reglamentId);
    setStore(() {
      fullReglament = FullReglament.fromResponse(reglamentData);
    });
  }

  Future<void> getReglamentQuestions({required int reglamentId}) async {
    final reglamentQuestionsData =
        await api.getReglamentsQuesions(reglamentId: reglamentId);
    final List<ReglamentQuestion> newQuestions = reglamentQuestionsData
        .map(
          (reglamentQuestion) =>
              ReglamentQuestion.fromResponse(reglamentQuestion),
        )
        .toList();
    setStore(() {
      questions = [...newQuestions];
    });
  }

  Future<ReglamentQuestion> createReglamentQuestion({
    required int reglamentId,
    required String name,
  }) async {
    final response =
        await api.createReglamentQuestion(name: name, reglamentId: reglamentId);
    final reglamentQuestion = ReglamentQuestion.fromResponse(response);
    questions = _createQuestionLocally(reglamentQuestion);
    return reglamentQuestion;
  }

  Future<ReglamentAnswerResponse> createReglamentAnswer({
    required int reglamentId,
    required int questionId,
    required String name,
  }) async {
    final response = await api.createReglamentAnswer(
      reglamentId: reglamentId,
      questionId: questionId,
      name: name,
    );
    final reglamentAnswer = ReglamentAnswer.fromResponse(response);
    setStore(() {
      questions =
          _createAnswerLocally(answer: reglamentAnswer, questionId: questionId);
    });
    return response;
  }

  Future<void> changeIsRightReglamentAnswerProperty({
    required int reglamentId,
    required int questionId,
    required int answerId,
    required bool isRight,
  }) async {
    final response = await api.changeIsRightReglamentAnswerProperty(
      reglamentId: reglamentId,
      questionId: questionId,
      answerId: answerId,
      isRight: isRight,
    );
    final reglamentAnswer = ReglamentAnswer.fromResponse(response);
    setStore(() {
      questions = _changeRightAnswerLocally(
        questionId: reglamentAnswer.questionId,
        answerId: answerId,
        isRight: reglamentAnswer.isRight,
      );
    });
  }

  Future<void> changeReglamentRequiredProperty({
    required int reglamentId,
    required bool required,
  }) async {
    final requiredRes = await api.changeReglamentRequiredProperty(
      reglamentId: reglamentId,
      required: required,
    );
    reglaments = _changeReglamentRequiredPropertyLocally(
      reglamentId: requiredRes.id,
      required: requiredRes.required,
    );
  }

  /// Пермещение регламента по Пространствам и
  /// Колонкам регламентов
  Future<void> changeReglamentColumnAndOrder({
    required int reglamentId,
    required int newColumnId,
    required double newOrder,
  }) async {
    final response = await api.changeReglamentColumnAndOrder(
      reglamentId: reglamentId,
      columnId: newColumnId,
      order: newOrder,
    );

    final updatedMap = _changeReglamentColumnLocally(response: response);
    setStore(() {
      reglaments = updatedMap.values.whereType<Reglament>().toList();
    });
  }

  Future<void> renameReglament({
    required int reglamentId,
    required String name,
  }) async {
    final renameRes =
        await api.renameReglament(reglamentId: reglamentId, name: name);
    setStore(() {
      reglaments = _renameReglamentLocally(
        reglamentId: renameRes.id,
        name: renameRes.name,
      );
    });
  }

  Future<void> deleteReglament({required int reglamentId}) async {
    try {
      final deleteResponse =
          await api.deleteReglament(reglamentId: reglamentId);
      setStore(() {
        reglaments = _deleteReglamentLocally(reglamentID: deleteResponse.id);
      });
    } catch (e) {
      if (e == 'Not organization owner') return;
      throw Exception(e);
    }
  }

  List<Reglament> _renameReglamentLocally({
    required int reglamentId,
    required String name,
  }) {
    List<Reglament> newReglaments = reglaments ?? [];
    newReglaments = newReglaments.map((reglament) {
      if (reglament.id == reglamentId) {
        return reglament.copyWith(name: name);
      }
      return reglament;
    }).toList();

    return newReglaments;
  }

  List<Reglament> _deleteReglamentLocally({required int reglamentID}) {
    final newReglaments = reglaments ?? [];
    final reglamentToDelete =
        newReglaments.firstWhere((reglament) => reglament.id == reglamentID);
    if (newReglaments.contains(reglamentToDelete)) {
      newReglaments.remove(reglamentToDelete);
    }
    return [...newReglaments];
  }

  /// Отображение локально в списке того, что регламент создан
  List<Reglament> _createReglamentLocally(Reglament reglament) {
    final List<Reglament> newReglaments = reglaments ?? [];
    if (!newReglaments.contains(reglament)) {
      newReglaments.add(reglament);
      return [...newReglaments];
    } else {
      throw Exception("Can't create reglament locally ");
    }
  }

  /// Отображение локально того, что регламент переместился
  Map<int, Reglament> _changeReglamentColumnLocally({
    required ChangeReglamentColumnAndOrderResponse response,
  }) {
    final reglamentMap = Map<int, Reglament>.from(reglamentsMap);
    final reglament = reglamentMap[response.id];

    if (reglament != null) {
      reglamentMap[response.id] = reglament.copyWith(
        reglamentColumnId: response.columnId,
        order: response.order,
      );
    }
    return reglamentMap;
  }

  List<ReglamentQuestion> _createQuestionLocally(ReglamentQuestion question) {
    final newQuestions = questions ?? [];
    newQuestions.add(question);
    return [...newQuestions];
  }

  List<ReglamentQuestion> _createAnswerLocally({
    required ReglamentAnswer answer,
    required int questionId,
  }) {
    final newQuestions = questions ?? [];
    final questionIndex =
        newQuestions.indexWhere((quest) => quest.id == questionId);
    if (questionIndex == -1) return newQuestions;

    final question = newQuestions[questionIndex];
    final updatedAnswers = List<ReglamentAnswer>.from(question.answers)
      ..add(answer);
    newQuestions[questionIndex] =
        question.copyWith(id: questionId, answers: updatedAnswers);
    return [...newQuestions];
  }

  List<ReglamentQuestion> _changeRightAnswerLocally({
    required int questionId,
    required int answerId,
    required bool isRight,
  }) {
    final List<ReglamentQuestion> newQuestions = questions ?? [];
    final questionIndex =
        newQuestions.indexWhere((question) => question.id == questionId);

    final question = newQuestions[questionIndex];
    final answerIndex =
        question.answers.indexWhere((ans) => ans.id == answerId);

    final updatedAnswers = List<ReglamentAnswer>.from(question.answers);
    updatedAnswers[answerIndex] =
        updatedAnswers[answerIndex].copyWith(isRight: isRight);

    newQuestions[questionIndex] = question.copyWith(answers: updatedAnswers);

    return [...newQuestions];
  }

  List<Reglament> _changeReglamentRequiredPropertyLocally({
    required int reglamentId,
    required bool required,
  }) {
    final newReglaments = reglaments ?? [];
    final reglamentIndex =
        newReglaments.indexWhere((reglament) => reglament.id == reglamentId);
    if (reglamentIndex != -1) {
      newReglaments[reglamentIndex] =
          newReglaments[reglamentIndex].copyWith(required: required);
    }
    return [...newReglaments];
  }

  void empty() {
    setStore(() {
      reglaments = null;
    });
  }
}
