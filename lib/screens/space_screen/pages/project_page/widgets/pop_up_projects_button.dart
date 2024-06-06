import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/widgets/pop_up_projects_item.dart';
import 'package:unityspace/utils/localization_helper.dart';

class PopUpProjectsButton extends StatelessWidget {
  const PopUpProjectsButton({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return PopupMenuButton<String>(
      elevation: 1,
      child: SizedBox(
        height: 24,
        width: 24,
        child: SvgPicture.asset(AppIcons.settings),
      ),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          PopupMenuItem(
            child: PopupProjectsItem(
              text: localization.move_it_to_bottom_column,
            ),
          ),
          PopupMenuItem(
            child: PopupProjectsItem(
              text: localization.move,
            ),
          ),
          PopupMenuItem(
            child: PopupProjectsItem(
              text: localization.copy_task_link,
            ),
          ),
          PopupMenuItem(
            child: PopupProjectsItem(
              text: localization.copy_task_number,
            ),
          ),
          PopupMenuItem(
            child: PopupProjectsItem(
              text: localization.duplicate_task,
            ),
          ),
          PopupMenuItem(
            child: PopupProjectsItem(
              text: localization.to_archive,
            ),
          ),
          PopupMenuItem(
            child: PopupProjectsItem(
              text: localization.delete,
              color: Colors.red,
            ),
          ),
        ];
      },
    );
  }
}
