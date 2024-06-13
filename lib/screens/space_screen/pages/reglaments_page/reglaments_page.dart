import 'package:flutter/material.dart';
import 'package:unityspace/models/reglament_models.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/resources/constants.dart';
import 'package:unityspace/screens/space_screen/pages/reglaments_page/widgets/dialogs/add_reglament_dialog.dart';
import 'package:unityspace/screens/space_screen/pages/reglaments_page/widgets/reglament_listview.dart';
import 'package:unityspace/screens/space_screen/widgets/delete_no_rules_dialog.dart';
import 'package:unityspace/store/reglaments_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/helpers.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

class ReglamentsPageStore extends WStore {
  late Space currentSpace;
  late SpaceColumn chosenColumn;

  bool isInArchive = false;
  String message = '';

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

  /// Получение регламентов из колонки
  List<Reglament> get archiveReglaments => computed(
        getValue: () => _archivedReglaments(allReglaments, archiveColumnId),
        watch: () => [allReglaments, archiveColumnId],
        keyName: 'archiveReglaments',
      );

  ///id заархивированного регламента
  int get archiveColumnId => currentSpace.archiveReglamentColumnId;

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
    double newOrder = 0,
  }) async {
    final columnId = archiveColumnId;
    await ReglamentsStore().changeReglamentColumnAndOrder(
      reglamentId: reglamentId,
      newColumnId: columnId,
      newOrder: newOrder,
    );
  }

  void tryToDeleteReglament({
    required int reglamentId,
    required BuildContext context,
  }) {
    if (isOwnerOrAdmin) {
      deleteReglament(reglamentId: reglamentId);
    } else {
      showDeleteNoRulesDialog(context);
    }
  }

  void copyText({
    required String text,
    required String successMessage,
    required String copyError,
  }) {
    listenFuture(
      copyToClipboard(text),
      id: 1,
      onData: (_) {
        setStore(() {
          message = successMessage;
        });
      },
      onError: (error, stack) {
        logger.e('copyToClipboard error', error: error, stackTrace: stack);
        setStore(() {
          message = copyError;
        });
      },
    );
  }

  Future<void> deleteReglament({
    required int reglamentId,
  }) async {
    await ReglamentsStore().deleteReglament(reglamentId: reglamentId);
  }

  void changeInArchiveStatus() {
    setStore(() {
      isInArchive = !isInArchive;
    });
  }

  bool get isOwnerOrAdmin => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.isOwnerOrAdmin,
        keyName: 'isOwnerOrAdmin',
      );

  ///Копирование ссылки на регламент
  String getReglamentLink({required int reglamentId}) {
    //Пример: 'https://app.unityspace.ru/spaces/2/reglaments/32627';
    return '${ConstantStrings.unitySpaceAppUrl}/spaces/${currentSpace.id}/reglaments/$reglamentId';
  }

  Map<int, List<Reglament>> _columnReglaments(List<Reglament> spaceReglaments) {
    // Создаем пустую мапу для сгруппированных регламентов
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

  List<Reglament> _archivedReglaments(
    List<Reglament> allReglaments,
    int archiveColumnId,
  ) {
    final List<Reglament> reglaments = allReglaments
        .where((reg) => reg.reglamentColumnId == archiveColumnId)
        .toList();
    reglaments.sort((a, b) => a.order.compareTo(b.order));

    return reglaments;
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
    return WStoreStringListener(
      store: store,
      watch: (store) => store.message,
      reset: (store) => store.message = '',
      onNotEmpty: (context, message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      },
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            WStoreBuilder(
              store: store,
              watch: (store) => [store.chosenColumn, store.isInArchive],
              builder: (context, store) {
                if (store.isInArchive) {
                  return const SizedBox.shrink();
                }
                return SizedBox(
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
                        child: InkWell(
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
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            WStoreBuilder(
              store: store,
              watch: (store) => [
                store.isInArchive,
                store.archiveReglaments,
              ],
              builder: (context, store) {
                return InkWell(
                  onTap: store.changeInArchiveStatus,
                  child: Text(
                    store.isInArchive
                        ? localization.exit_from_archive
                        : '${localization.reglament_count_in_archive}: ${store.archiveReglaments.length}',
                  ),
                );
              },
            ),
            const SizedBox(
              height: 12,
            ),
            WStoreBuilder(
              store: store,
              watch: (store) => [
                store.chosenColumn,
                store.archiveReglaments,
                store.isInArchive,
              ],
              builder: (context, store) {
                return ReglamentListView(
                  columnReglaments: store.isInArchive
                      ? store.archiveReglaments
                      : store.columnReglaments,
                );
              },
            ),
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
      ),
    );
  }
}
