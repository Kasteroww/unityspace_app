import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/project_page.dart';
import 'package:unityspace/screens/space_screen/widgets/pop_up_projects_item.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class PopUpProjectsButton extends StatelessWidget {
  const PopUpProjectsButton({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final store = context.wstore<ProjectsPageStore>();

    return PopupMenuButton<String>(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      child: SizedBox(
        height: 24,
        width: 24,
        child: SvgPicture.asset('assets/icons/settings.svg'),
      ),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          if (!store.isArchivedPage) ...[
            PopupMenuItem(
              onTap: () => store.archiveProject([id], store.archiveColumnId),
              child: PopupProjectsItem(
                text: localization.to_archive,
              ),
            ),
          ] else ...[
            PopupMenuItem(
              onTap: null,
              child: PopupProjectsItem(
                text: localization.from_archive,
              ),
            ),
          ],
        ];
      },
    );
  }
}
