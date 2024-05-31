import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/models/reglament_models.dart';
import 'package:unityspace/screens/space_screen/pages/reglaments_page/reglaments_page.dart';
import 'package:unityspace/screens/space_screen/pages/reglaments_page/widgets/dialogs/move_reglament_dialog.dart';
import 'package:unityspace/screens/space_screen/pages/reglaments_page/widgets/dialogs/rename_reglament_dialog.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class PopUpReglamentButton extends StatelessWidget {
  final Reglament reglament;
  const PopUpReglamentButton({
    required this.reglament,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return PopupMenuButton<String>(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      child: SizedBox(
        height: 25,
        width: 25,
        child: SvgPicture.asset('assets/icons/settings.svg'),
      ),
      itemBuilder: (BuildContext context) {
        return isArchived(
          currentColumnId: reglament.reglamentColumnId,
          archivedColumnId:
              context.wstore<ReglamentsPageStore>().archiveColumnId,
        )
            ? [
                // Перемещение из архива
                PopupMenuItem<String>(
                  onTap: () {
                    showMoveReglamentDialog(
                      context: context,
                      reglamentColumns: context
                          .wstore<ReglamentsPageStore>()
                          .reglamentColumns,
                      columnReglament: reglament,
                    );
                  },
                  child: PopupMenuItemChild(
                    text: localization.restore_from_archive,
                  ),
                ),
                // Удаление реглаента
                PopupMenuItem<String>(
                  onTap: () {
                    context.wstore<ReglamentsPageStore>().tryToDeleteReglament(
                          reglamentId: reglament.id,
                          context: context,
                        );
                  },
                  child: PopupMenuItemChild(
                    text: localization.delete,
                  ),
                ),
              ]
            : [
                // Изменение названия
                PopupMenuItem<String>(
                  onTap: () {
                    showRenameReglamentDialog(context, reglament);
                  },
                  child: PopupMenuItemChild(
                    text: localization.change_the_title,
                  ),
                ),
                // Дулирование регламента
                PopupMenuItem<String>(
                  child: PopupMenuItemChild(
                    text: localization.duplicate_reglament,
                  ),
                ),
                // копирует ссылку на регламент
                PopupMenuItem<String>(
                  onTap: () {
                    context.wstore<ReglamentsPageStore>().copyText(
                          text: context
                              .wstore<ReglamentsPageStore>()
                              .getReglamentLink(reglamentId: reglament.id),
                          successMessage:
                              localization.reglament_link_copied_successfully,
                          copyError: localization.copy_error,
                        );
                  },
                  child: PopupMenuItemChild(
                    text: localization.copy_reglament_link,
                  ),
                ),
                PopupMenuItem<String>(
                  onTap: () {
                    showMoveReglamentDialog(
                      context: context,
                      reglamentColumns: context
                          .wstore<ReglamentsPageStore>()
                          .reglamentColumns,
                      columnReglament: reglament,
                    );
                  },
                  child: PopupMenuItemChild(
                    text: localization.move_reglament,
                  ),
                ),
                PopupMenuItem<String>(
                  onTap: () {
                    context.wstore<ReglamentsPageStore>().moveToArchive(
                          reglamentId: reglament.id,
                        );
                  },
                  child: PopupMenuItemChild(
                    text: localization.send_to_archive,
                  ),
                ),
              ];
      },
    );
  }

  bool isArchived({
    required int currentColumnId,
    required int archivedColumnId,
  }) {
    return currentColumnId == archivedColumnId;
  }
}

class PopupMenuItemChild extends StatelessWidget {
  final String text;
  const PopupMenuItemChild({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 16.41 / 14,
        color: Color.fromRGBO(77, 77, 77, 1),
      ),
    );
  }
}
