import 'dart:collection';

import 'package:unityspace/models/i_base_model.dart';
import 'package:wstore/wstore.dart';

extension GStoreExtension on GStore {
  List<BaseModel> updateLocally(
      List<BaseModel> list, HashMap<int, BaseModel> map) {
    List<BaseModel> baseList = List<BaseModel>.from(list);
    HashMap<int, BaseModel> baseMap = HashMap<int, BaseModel>.from(map);
    for (BaseModel object in baseList) {
      baseMap[object.id] = object;
    }
    final List<BaseModel> newList =
        baseMap.entries.map((element) => element.value).toList();
    return newList;
  }
}
