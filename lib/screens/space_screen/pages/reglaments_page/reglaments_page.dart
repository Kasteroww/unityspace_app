import 'package:flutter/material.dart';
import 'package:unityspace/models/reglament_models.dart';
import 'package:unityspace/store/reglament_store.dart';
import 'package:wstore/wstore.dart';

class ReglamentsPageStore extends WStore {
  List<Reglament> get reglaments => computedFromStore(
        store: ReglamentsStore(),
        getValue: (store) => store.reglaments ?? [],
        keyName: 'reglaments',
      );

  @override
  ReglamentsPage get widget => super.widget as ReglamentsPage;
}

class ReglamentsPage extends WStoreWidget<ReglamentsPageStore> {
  const ReglamentsPage({
    super.key,
  });

  @override
  ReglamentsPageStore createWStore() => ReglamentsPageStore();

  @override
  Widget build(BuildContext context, ReglamentsPageStore store) {
    return Text('${store.reglaments.length}');
  }
}
