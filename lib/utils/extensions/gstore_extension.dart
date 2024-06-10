import 'package:unityspace/models/model_interfaces.dart';
import 'package:wstore/wstore.dart';

extension GStoreExtension<T extends Identifiable> on GStore {
  List<T> updateLocally(
    List<T> list,
    Map<int, T> map,
  ) {
    for (final T object in list) {
      map[object.id] = object;
    }
    return List<T>.from(map.entries.map((element) => element.value));
  }

  List<T> deleteLocally(
    T record,
    Map<int, T> map,
  ) {
    map.remove(record.id);
    return List<T>.from(map.entries.map((element) => element.value));
  }
}
