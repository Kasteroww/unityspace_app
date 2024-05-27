import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:unityspace/models/reglament_models.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/store/reglament_store.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:wstore/wstore.dart';

class ReglamentsPageStore extends WStore {
  int spaceId = 0;
  late SpaceColumn chosenColumn;

  ///Получение ВСЕХ регламентов из стора
  List<Reglament> get allReglaments => computedFromStore(
        store: ReglamentsStore(),
        getValue: (store) => ReglamentsStore().reglaments ?? [],
        keyName: 'allReglaments',
      );

  /// Получение ныненшнего пространства
  Space? get currentSpace => computedFromStore(
        store: SpacesStore(),
        getValue: (store) => SpacesStore()
            .spaces
            ?.firstWhereOrNull((space) => space.id == spaceId),
        keyName: 'space',
      );

  /// Получение колонок с Регламентами
  List<SpaceColumn> get reglamentColumns => computed(
      getValue: () => _getColumns(currentSpace: currentSpace),
      watch: () => [currentSpace],
      keyName: 'reglamentColumns');

  /// Получение регламентов из колонки
  List<Reglament> get columnReglaments => computed(
      getValue: () =>
          _getReglaments(reglaments: allReglaments, chosenColumn: chosenColumn),
      watch: () => [allReglaments, chosenColumn],
      keyName: 'columnReglaments');

  void chooseColumn({required SpaceColumn newChosenColumn}) {
    setStore(() {
      chosenColumn = newChosenColumn;
    });
  }

  void initValues({required int spaceId}) {
    this.spaceId = spaceId;
    chosenColumn = reglamentColumns.first;
  }

  Map<int, List<Reglament>> _columnReglaments(List<Reglament> spaceReglaments) {
    // Создаем пустую карту для сгруппированных регламентов
    final Map<int, List<Reglament>> columnReglaments = {};

    // Группируем регламенты по reglamentColumnId
    for (var reglament in spaceReglaments) {
      if (columnReglaments.containsKey(reglament.reglamentColumnId)) {
        columnReglaments[reglament.reglamentColumnId]!.add(reglament);
      } else {
        columnReglaments[reglament.reglamentColumnId] = [reglament];
      }
    }

    // Сортируем регламенты внутри каждой колонки по полю order
    for (var column in columnReglaments.keys) {
      columnReglaments[column]!.sort((a, b) => a.order.compareTo(b.order));
    }

    return columnReglaments;
  }

  List<SpaceColumn> _getColumns({required Space? currentSpace}) {
    var cols = currentSpace?.reglamentColumns ?? [];
    cols.sort((a, b) => a.order.compareTo(b.order));
    return cols;
  }

  List<Reglament> _getReglaments(
      {required List<Reglament> reglaments,
      required SpaceColumn chosenColumn}) {
    var reglamentsMap = _columnReglaments(reglaments);
    return reglamentsMap[chosenColumn.id] ?? [];
  }

  @override
  ReglamentsPage get widget => super.widget as ReglamentsPage;
}

class ReglamentsPage extends WStoreWidget<ReglamentsPageStore> {
  final int spaceId;
  const ReglamentsPage({
    super.key,
    required this.spaceId,
  });

  @override
  ReglamentsPageStore createWStore() =>
      ReglamentsPageStore()..initValues(spaceId: spaceId);

  @override
  Widget build(BuildContext context, ReglamentsPageStore store) {
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: store.reglamentColumns.length,
              itemBuilder: (BuildContext context, int index) {
                final reglamentColumn = store.reglamentColumns[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: WStoreBuilder(
                      store: store,
                      watch: (store) => [
                            store.chosenColumn,
                          ],
                      builder: (context, store) {
                        return InkWell(
                          onTap: () {
                            store.chooseColumn(
                                newChosenColumn: reglamentColumn);
                          },
                          child: Text(
                            reglamentColumn.name,
                            style: TextStyle(
                                color: reglamentColumn == store.chosenColumn
                                    ? Colors.red
                                    : Colors.blue),
                          ),
                        );
                      }),
                );
              }),
        ),
        Expanded(
            child: WStoreBuilder(
                store: store,
                watch: (store) => [
                      store.columnReglaments,
                    ],
                builder: (context, store) {
                  return ListView.builder(
                      itemCount: store.columnReglaments.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Text(store.columnReglaments[index].name);
                      });
                }))
      ],
    );
  }
}
