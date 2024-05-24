import 'package:unityspace/models/reglament_models.dart';
import 'package:wstore/wstore.dart';
import 'package:unityspace/service/reglament_service.dart' as api;

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

  @override
  void clear() {
    super.clear();
    setStore(() {
      reglaments = null;
    });
  }
}
