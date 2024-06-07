import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/screens/space_screen/space_screen.dart';
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

    return PopupMenuButton<SpacesScreenTab>(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
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

class PopupMenuItemChild extends StatelessWidget {
  final String text;
  const PopupMenuItemChild({
    required this.text,
    super.key,
  });

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
