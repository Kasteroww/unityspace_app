import 'dart:collection';

import 'package:unityspace/models/i_base_model.dart';
import 'package:wstore/wstore.dart';

extension GStoreExtension on GStore {
  List<Identifiable> updateLocally(
    List<Identifiable> list,
    HashMap<int, Identifiable> map,
  ) {
    final List<Identifiable> baseList = List<Identifiable>.from(list);
    final HashMap<int, Identifiable> baseMap =
        HashMap<int, Identifiable>.from(map);
    for (final Identifiable object in baseList) {
      baseMap[object.id] = object;
    }
    final List<Identifiable> newList =
        baseMap.entries.map((element) => element.value).toList();
    return newList;
  }
}
