import 'package:unityspace/models/reglament_models.dart';
import 'package:unityspace/service/reglament_service.dart' as api;
import 'package:unityspace/utils/helpers.dart';
import 'package:wstore/wstore.dart';

class ReglamentsStore extends GStore {
  static ReglamentsStore? _instance;

  factory ReglamentsStore() => _instance ??= ReglamentsStore._();

  ReglamentsStore._();

  List<Reglament>? reglaments;

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

  @override
  void clear() {
    super.clear();
    setStore(() {
      reglaments = null;
    });
  }
}
