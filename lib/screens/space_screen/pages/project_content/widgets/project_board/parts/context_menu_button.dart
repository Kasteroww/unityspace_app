import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_board/parts/context_menu_item.dart';
import 'package:unityspace/utils/localization_helper.dart';

class ContextMenuButton extends StatelessWidget {
  const ContextMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return PopupMenuButton<String>(
      elevation: 1,
      child: SvgPicture.asset(AppIcons.settings),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          PopupMenuItem(
            child: ContextMenuItem(
              text: localization.move_it_to_bottom_column,
            ),
          ),
          PopupMenuItem(
            child: ContextMenuItem(
              text: localization.move,
            ),
          ),
          PopupMenuItem(
            child: ContextMenuItem(
              text: localization.copy_task_link,
            ),
          ),
          PopupMenuItem(
            child: ContextMenuItem(
              text: localization.copy_task_number,
            ),
          ),
          PopupMenuItem(
            child: ContextMenuItem(
              text: localization.duplicate_task,
            ),
          ),
          PopupMenuItem(
            child: ContextMenuItem(
              text: localization.to_archive,
            ),
          ),
          PopupMenuItem(
            child: ContextMenuItem(
              text: localization.delete,
              color: Colors.red,
            ),
          ),
        ];
      },
    );
  }
}
