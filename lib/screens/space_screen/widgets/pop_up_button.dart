import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/screens/space_screen/space_screen.dart';
import 'package:unityspace/screens/widgets/pop_up_button.dart/default_pop_up_button.dart';
import 'package:unityspace/screens/widgets/pop_up_button.dart/pop_up_menu_child.dart';
import 'package:unityspace/utils/localization_helper.dart';

class PopUpSpacesScreenButton extends StatelessWidget {
  final void Function(SpacesScreenTab)? onSelected;
  const PopUpSpacesScreenButton({
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return DefaultPopUpButton(
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<SpacesScreenTab>>[
          //Проекты
          PopupMenuItem<SpacesScreenTab>(
            value: SpacesScreenTab.projects,
            child: PopupMenuItemChild(
              text: localization.projects,
            ),
          ),
          //Задачи
          PopupMenuItem<SpacesScreenTab>(
            value: SpacesScreenTab.tasks,
            child: PopupMenuItemChild(
              text: localization.tasks,
            ),
          ),
          //Регламенты
          PopupMenuItem<SpacesScreenTab>(
            value: SpacesScreenTab.reglaments,
            child: PopupMenuItemChild(
              text: localization.reglaments,
            ),
          ),

          // Участники пространства
          PopupMenuItem<SpacesScreenTab>(
            value: SpacesScreenTab.members,
            child: PopupMenuItemChild(
              text: localization.members,
            ),
          ),
          // Архив проектов
          PopupMenuItem<SpacesScreenTab>(
            value: SpacesScreenTab.projectsArchive,
            child: PopupMenuItemChild(
              text: localization.project_archive,
            ),
          ),
        ];
      },
      child: SizedBox(
        height: 55,
        width: 55,
        child: SvgPicture.asset('assets/icons/settings.svg'),
      ),
    );
  }
}
