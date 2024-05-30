import 'package:unityspace/models/reglament_models.dart';
import 'package:unityspace/service/reglament_service.dart' as api;
import 'package:unityspace/utils/helpers.dart';
import 'package:wstore/wstore.dart';

class ReglamentsStore extends GStore {
  static ReglamentsStore? _instance;

  factory ReglamentsStore() => _instance ??= ReglamentsStore._();

  ReglamentsStore._();

  List<Reglament>? reglaments;

  ///Создание регламента
  Future<void> createReglament({
    required String name,
    required int columnId,
    required String content,
  }) async {
    final createdReglamentData =
        await api.createReglament(name, columnId, content);

    final reglament = Reglament.fromResponse(createdReglamentData);
    setStore(() {
      reglaments = _createReglamentLocally(reglament);
    });
    await createReglamentSaveHistory(
      reglamentId: reglament.id,
      comment: 'Создан новый регламент',
      clearUserPassed: false,
    );
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

  /// Пермещение регламента по Пространствам и
  /// Колонкам регламентов
  Future<void> changeReglamentColumnAndOrder({
    required int reglamentId,
    required int newColumnId,
    required int newOrder,
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
  Map<int, Reglament?> _changeReglamentColumnLocally({
    required ChangeReglamentColumnAndOrderResponse response,
  }) {
    final reglamentMap = createMapById(reglaments);
    final reglament = reglamentMap[response.id];

    if (reglament != null) {
      reglamentMap[response.id] = reglament.copyWith(
        reglamentColumnId: response.columnId,
        order: response.order,
      );
    }
    return reglamentMap;
  }

  @override
  void clear() {
    super.clear();
    setStore(() {
      reglaments = null;
    });
  }
}
