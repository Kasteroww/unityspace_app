import 'package:flutter/material.dart';
import 'package:unityspace/screens/space_screen/pages/reglaments_page/reglaments_page.dart';
import 'package:unityspace/screens/space_screen/pages/reglaments_page/widgets/dialogs/move_reglament_dialog.dart';
import 'package:unityspace/screens/space_screen/pages/reglaments_page/widgets/pop_up_reglament_button.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class ReglamentListView extends StatelessWidget {
  const ReglamentListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Expanded(
      child: WStoreBuilder(
        store: context.wstore<ReglamentsPageStore>(),
        watch: (store) => [
          store.reglamentColumns,
          store.columnReglaments,
        ],
        builder: (context, store) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.builder(
                itemCount: store.columnReglaments.length,
                itemBuilder: (BuildContext context, int index) {
                  final columnReglament = store.columnReglaments[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  columnReglament.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              PopUpReglamentButton(
                                popupMenuEntryList: [
                                  PopupMenuItem<String>(
                                    child: PopupMenuItemChild(
                                        text: localization.change_the_title),
                                  ),
                                  PopupMenuItem<String>(
                                    child: PopupMenuItemChild(
                                        text: localization.duplicate_reglament),
                                  ),
                                  PopupMenuItem<String>(
                                    child: PopupMenuItemChild(
                                        text: localization.copy_reglament_link),
                                  ),
                                  PopupMenuItem<String>(
                                    onTap: () {
                                      showMoveReglamentDialog(
                                          context: context,
                                          reglamentColumns:
                                              store.reglamentColumns,
                                          columnReglament: columnReglament);
                                    },
                                    child: PopupMenuItemChild(
                                        text: localization.move_reglament),
                                  ),
                                  PopupMenuItem<String>(
                                    onTap: () {
                                      store.moveToArchive(
                                          reglamentId: columnReglament.id);
                                    },
                                    child: PopupMenuItemChild(
                                        text: localization.send_to_archive),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )),
                  );
                }),
          );
        },
      ),
    );
  }
}
