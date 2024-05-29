import 'package:flutter/material.dart';
import 'package:unityspace/models/reglament_models.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/screens/space_screen/pages/reglaments_page/widgets/dialogs/add_reglament_dialog.dart';
import 'package:unityspace/screens/space_screen/pages/reglaments_page/widgets/reglament_listview.dart';
import 'package:unityspace/store/reglament_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class ReglamentsPageStore extends WStore {
  late Space currentSpace;
  late SpaceColumn chosenColumn;

  ///Получение ВСЕХ регламентов из стора
  List<Reglament> get allReglaments => computedFromStore(
        store: ReglamentsStore(),
        getValue: (store) => ReglamentsStore().reglaments ?? [],
        keyName: 'allReglaments',
      );

  /// Получение колонок с Регламентами
  List<SpaceColumn> get reglamentColumns => computed(
        getValue: () => _getColumns(currentSpace: currentSpace),
        watch: () => [currentSpace],
        keyName: 'reglamentColumns',
      );

  /// Получение регламентов из колонки
  List<Reglament> get columnReglaments => computed(
        getValue: () => _getReglaments(
          reglaments: allReglaments,
          chosenColumn: chosenColumn,
        ),
        watch: () => [allReglaments, chosenColumn],
        keyName: 'columnReglaments',
      );

  /// Выбрать колонку
  void chooseColumn({required SpaceColumn newChosenColumn}) {
    setStore(() {
      chosenColumn = newChosenColumn;
    });
  }

  void initValues({required Space space}) {
    currentSpace = space;
    chosenColumn = reglamentColumns.first;
  }

  Future<void> moveToArchive({
    required int reglamentId,
    int newOrder = 0,
  }) async {
    final archiveIdColumn = archiveColumnId();
    await ReglamentsStore().changeReglamentColumnAndOrder(
      reglamentId: reglamentId,
      newColumnId: archiveIdColumn,
      newOrder: newOrder,
    );
  }

  int archiveColumnId() {
    return currentSpace.archiveReglamentColumnId;
  }

  Map<int, List<Reglament>> _columnReglaments(List<Reglament> spaceReglaments) {
    // Создаем пустую карту для сгруппированных регламентов
    final Map<int, List<Reglament>> columnReglaments = {};

    // Группируем регламенты по reglamentColumnId
    for (final reglament in spaceReglaments) {
      if (columnReglaments.containsKey(reglament.reglamentColumnId)) {
        columnReglaments[reglament.reglamentColumnId]?.add(reglament);
      } else {
        columnReglaments[reglament.reglamentColumnId] = [reglament];
      }
    }

    // Сортируем регламенты внутри каждой колонки по полю order
    for (final column in columnReglaments.keys) {
      columnReglaments[column]?.sort((a, b) => a.order.compareTo(b.order));
    }

    return columnReglaments;
  }

  List<SpaceColumn> _getColumns({required Space? currentSpace}) {
    final cols = currentSpace?.reglamentColumns ?? [];
    cols.sort((a, b) => a.order.compareTo(b.order));
    return cols;
  }

  List<Reglament> _getReglaments({
    required List<Reglament> reglaments,
    required SpaceColumn chosenColumn,
  }) {
    final reglamentsMap = _columnReglaments(reglaments);
    return reglamentsMap[chosenColumn.id] ?? [];
  }

  @override
  ReglamentsPage get widget => super.widget as ReglamentsPage;
}

class ReglamentsPage extends WStoreWidget<ReglamentsPageStore> {
  final Space space;
  const ReglamentsPage({
    required this.space,
    super.key,
  });

  @override
  ReglamentsPageStore createWStore() =>
      ReglamentsPageStore()..initValues(space: space);

  @override
  Widget build(BuildContext context, ReglamentsPageStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: store.reglamentColumns.length,
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(
                  width: 4,
                );
              },
              itemBuilder: (BuildContext context, int index) {
                final reglamentColumn = store.reglamentColumns[index];
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: WStoreBuilder(
                    store: store,
                    watch: (store) => [
                      store.chosenColumn,
                    ],
                    builder: (context, store) {
                      return InkWell(
                        onTap: () {
                          store.chooseColumn(
                            newChosenColumn: reglamentColumn,
                          );
                        },
                        child: Text(
                          reglamentColumn.name,
                          style: TextStyle(
                            color: reglamentColumn == store.chosenColumn
                                ? Colors.red
                                : Colors.blue,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const ReglamentListView(),
          InkWell(
            onTap: () {
              showAddReglamentDialog(context, store.chosenColumn.id);
            },
            child: Container(
              height: 40,
              width: width,
              color: Colors.blue,
              child: Center(
                child: Text(
                  '+ ${localization.add_reglament}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
